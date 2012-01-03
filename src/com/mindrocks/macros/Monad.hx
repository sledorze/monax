package com.mindrocks.macros;

import haxe.macro.Context;
import haxe.macro.Expr;

/**
 * ...
 * @author sledorze
 */

 /**
  * AST used for transformations (includes optimizations).
  */
enum MonadOp {
#if macro
  MExp(e : Expr);
  MMap(e : MonadOp, bindName : String, body : MonadOp);
  MFlatMap(e : MonadOp, bindName : String, body : MonadOp);
  
  MCall(name : String, params : Array<Expr>);
  MFuncApp(paramName : String, body : MonadOp, app : MonadOp);
#end
}

enum Option<T> {
   None;
   Some(v : T);
}
 
/**
 * Use ret, map and flatMap by convention (map being required when standards optimizations are used).
 */
class Monad {
  
  public static function noOpt(m : MonadOp, position : Position) : MonadOp
    return m
  #if macro
  public static function genOptimize(m : MonadOp, position : Position) : MonadOp {
    function mk(e : ExprDef) return { pos : position, expr : e };
    switch(m) {
      case MFlatMap(e, bindName, body):
        var body = genOptimize(body, position);
        var e = genOptimize(e, position);
        
        switch (e) {
          case MCall(name, params):
            switch (name) {
              case "ret": return /*optimize(*/MFuncApp(bindName, body, MExp(params[0]))/*, position)*/;
              default :
            }            
          default:
            switch (body) {
              case MCall(name, params):
                switch (name) {
                  case "ret": return /*optimize(*/MMap(e, bindName, MExp(params[0]))/*, position)*/;
                  default :
                }
              default:
            }
        }
        
        return MFlatMap(e, bindName, body);
        
      default:
        return m;
    }
  }
  #end

  public static function dO(monadTypeName : String, body : Expr, context : Dynamic, optimize : MonadOp -> Position -> MonadOp = null) {
    #if macro
    if (optimize == null)
      optimize = genOptimize;
    
    var monadRef = EConst(CType(monadTypeName));
    var position : Position = context.currentPos();
    function mk(e : ExprDef) return { pos : position, expr : e };

    function tryPromoteExpression(e : Expr) : MonadOp {
      switch (e.expr) {        
        case ECall(exp, params) :
          switch (exp.expr) {
            case EConst(const):
              switch (const) {
                case CIdent(name):
                  try {
                    context.typeof(exp);
                  } catch (e : Dynamic) {
                    return MCall(name, params);
                  }
                default:
              }
            default:
          }
        default:
      }
      return MExp(e);
    }
    
    function transform(e : Expr, nextOpt : Option<MonadOp>) : Option<MonadOp> {
      
      function flatMapThis(e : MonadOp, name : String) {
        switch (nextOpt) {
          case Some(next): return MFlatMap(e, name, next);
          case None : return e;
        }
      }
      
      switch (e.expr) {
        case EBinop(op, l, rightExpr) :
          switch (op) {
            case OpLte:              
              switch (l.expr) {
                case EConst(c) :
                  switch (c) {
                    case CIdent(name) :
                      var e = tryPromoteExpression(rightExpr);
                      return Some(flatMapThis(e, name));
                    default :
                  }
                default :
              }                  
            default :
          }        
        default:
      }      
      return Some(flatMapThis(tryPromoteExpression(e), "_"));
    }
    
    function toExpr(m : MonadOp) : Expr {
      switch (m) {
        case MExp(e) : return e;
        
        case MFlatMap(e, bindName, body) :
          var rest = mk(EReturn(toExpr(body)));
          var func = mk(EFunction(null, { args : [ { name : bindName, type : null, opt : false, value : null } ], ret : null, expr : rest, params : [] } ));
          var res = mk(ECall(mk(EField(mk(monadRef), "flatMap")), [toExpr(e), func]));
          return res;
          
        case MMap(e, bindName, body) :
          var rest = mk(EReturn(toExpr(body)));
          var func = mk(EFunction(null, { args : [ { name : bindName, type : null, opt : false, value : null } ], ret : null, expr : rest, params : [] } ));
          var res = mk(ECall(mk(EField(mk(monadRef), "map")), [toExpr(e), func]));
          return res;
          
        case MCall(name, params) :
          return mk(ECall(mk(EField(mk(monadRef), name)), params));

        case MFuncApp(paramName, body, app):
          var body = mk(EReturn(toExpr(body)));
          var func = mk(EFunction(null, { args : [ { name : paramName, type : null, opt : false, value : null } ], ret : null, expr : body, params : [] } ));
          return mk(ECall(func, [toExpr(app)]));
      }
    }
    
    switch (body.expr) {
      case EBlock(exprs):
        exprs.reverse();
        switch(Lambda.fold(exprs, transform, None)) {
          case Some(monad): return mk(EBlock([toExpr(optimize(monad, position))]));
          default:
        }
      default :
    };
    return body;
    #end
  }
}
