package com.mindrocks.monads;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
// import haxe.macro.Type;

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
  MIf(cond : Expr, ethen : MonadOp, eelse : MonadOp);
#end
}

#if haxe3
typedef Option<T> = haxe.ds.Option<T>;
#else
enum Option<T> {
   None;
   Some(v : T);
}
#end

/**
 * Use ret, map and flatMap by convention (map being required when standards optimizations are used).
 */
class Monad {

  public static function noOpt(m : MonadOp, position : Position) : MonadOp
    return m;
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

  macro public static function dO(exp : Expr) {
  #if macro
    function mk(e : ExprDef) return { pos : Context.currentPos(), expr : e };
    switch (exp.expr) {
      case EBlock(exprs):
        switch (exprs[0].expr) {
          case EBinop(OpLte, _, e2):

            switch (e2.expr) {
              case EReturn(_):
                Context.error("First value use 'return'.  Monad type need to be explicitely specified.", exprs[0].pos);
              case _:
                var retrieveMonad = mk(ECall(mk(EField(e2, "monad")), []));
                var monadType = Context.typeof(retrieveMonad);
                
                switch (monadType) {
                  case TType(defRef, params) :
                    var monadName = (defRef.get().name).split("#")[1]; // not very nice
                    return mk(ECall(mk(EField(mk(EConst(#if haxe3 CIdent #else CType #end(monadName))), "dO")), [exp]));

                  case _ :
                    Context.error('type $monadType has no Monad ', exprs[0].pos);
                    return null;
                }
              
            }

          default:
        }

      default:
    }
  #end
    return exp;
  }

  static var validNames : Map<String,Bool> = new Map<String,Bool>();

  public static function _dO(monadTypeName : String, body : Expr, context : Dynamic, optimize : MonadOp -> Position -> MonadOp = null) {
    #if macro
    if (optimize == null)
      optimize = genOptimize;


    var monadRef =
      #if haxe3
      Lambda.fold(monadTypeName.split("."), function(a, b) {
        return b != null ? {expr:EField(b, a), pos:b.pos} : macro $i{a};
      }, null).expr;
      #else
      EConst(CType(monadTypeName));
      #end      

    var position : Position = context.currentPos();
    function mk(e : ExprDef) return { pos : position, expr : e };

    // We do not rely on the Monad definition because we want to be open to 'using' based extensions
    function isAValidName(name : String) {
      var completeName = monadRef + name;
      var res = validNames.get(completeName);
      if (res == null) {
        validNames.set(
          completeName,
          try {
            context.typeof(mk(EField(mk(monadRef), name)));
            true;
          } catch (e : Dynamic) {
            false;
          }
        );
        return isAValidName(name);
      } else {
        return res;
      }
    }


    function tryPromoteExpression(e : Expr) : MonadOp {
      switch (e.expr) {
        case EReturn(exp) :
          switch(exp.expr) {
            case EBlock(_):
              return MCall("ret", [mk(ECall(mk(EField(mk(EConst(#if haxe3 CIdent #else CType #end("Monad"))), "dO")), [exp]))]);
            default:
              return MCall("ret", [exp]);
          }
		
		case EIf(econd, ethen, eelse):
			return MIf(econd, tryPromoteExpression(ethen), tryPromoteExpression(eelse));

        case ECall( { expr : EConst(CIdent(name)), pos : _ }, params) if (isAValidName(name)) :
			return MCall(name, params); // valid; we should issue a monad call then.
        default:
      }
      return MExp(e);
    }

    // fix operator precedence such as in
    // a <= "abc" == "abc" ? b : c
    // there might be more cases
    function findOpLte(e:Expr):{e:Expr, ?name:String}{
      function mk(e2 : ExprDef) return { pos : e.pos, expr : e2 };
      switch (e.expr) {
        case EBinop(OpLte, { expr : EConst(CIdent(name)), pos : _ }, rightExpr) :
          return { name: name, e: rightExpr };
        case EBinop(op, leftExpr, rightExpr) :
          var x = findOpLte(leftExpr);
          if (x.name != null){
            return {
              name: x.name,
              e: mk(EBinop(op, x.e, rightExpr))
            }
          }
        case ETernary(econd, eif, eelse):
          var x = findOpLte(econd);
          if (x.name != null){
            return {
              name: x.name,
              e: mk(EIf(x.e, eif, eelse)),
            };
          }
        default:
      }
      return {e: e};
    }

    function transform(e : Expr, nextOpt : Option<MonadOp>) : Option<MonadOp> {

      function flatMapThis(e : MonadOp, name : String) {
        switch (nextOpt) {
          case Some(next): return MFlatMap(e, name, next);
          case None : return e;
        }
      }

      var x = findOpLte(e);
      if (x.name == null){
        return Some(flatMapThis(tryPromoteExpression(e), "_"));
      } else {
        var e = tryPromoteExpression(x.e);
        return Some(flatMapThis(e, x.name));
      }
    }

    function toExpr(m : MonadOp) : Expr {
      switch (m) {
        case MExp(e) : return e;

        case MFlatMap(e, bindName, body) :
          var rest = mk(EReturn(toExpr(body)));
          var func = mk(EFunction(null, { args : [ { name : bindName, type : null, opt : false, value : null } ], ret : null, expr : rest, params : [] } ));
          return mk(ECall(mk(EField(mk(monadRef), "flatMap")), [toExpr(e), func]));

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
		
		case MIf(econd, ethen, eelse):
		  return mk(EIf(econd, toExpr(ethen), toExpr(eelse)));
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
