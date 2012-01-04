package com.mindrocks.monads.instances;

import haxe.macro.Expr;
import haxe.macro.Context;
import com.mindrocks.monads.Monad;

/**
 * ...
 * @author sledorze
 */

typedef Error = Dynamic
typedef NodeC<R,A> = (Error -> A -> R) -> R

@:native("NodeM") class NodeM {

          
  public static function specialOpt(m : MonadOp, position : Position) : MonadOp {
    #if macro
    var optimized = Monad.genOptimize(m, position);
    return prepend_FunctionCall(optimized, position);
  }
  
  public static function prepend_FunctionCall(m : MonadOp, position : Position) : MonadOp  {
    function mk(e : ExprDef) return { pos : position, expr : e };

    function manage(e : MonadOp, name : String, body : MonadOp, f : MonadOp -> String -> MonadOp -> MonadOp) {
      var body = prepend_FunctionCall(body, position);
      
      var newE = 
        switch (e) {
          case MExp(e):
            var func = {
              args : [ { name : '_', opt : false, type : null, value : null } ],
              ret : null,
              expr : mk(EReturn(e)),
              params : []
            };            
            MExp(mk(EFunction(null, func)));
          default: e;
        };
      return f(newE, name, body);
    }
    
    switch (m) {
      case MFlatMap(e, bindName, body):
        return manage(e, bindName, body, MFlatMap); // MFlatMap(newE, bindName, body);

      case MMap(e, bindName, body):
        return manage(e, bindName, body, MMap); // MFlatMap(newE, bindName, body);
      
      default:
        return m;
    }
    #else
    return null;
    #end
  }
  
  @:macro public static function dO(body : Expr) return
    Monad.dO("NodeM", body, Context, specialOpt)

  inline static public function ret <A,R>(i:A):NodeC<R,A>
    return function(cont) return cont(null, i)

  static public function flatMap <A, B, R>(m:NodeC<R,A>, k: A -> NodeC<R,B>): NodeC<R,B>
    return function(cont : Error -> B -> R) {
      return m(function(err, a) {
        if (err != null)
          return cont(err, null);
        else
          return k(a)(cont);
      });
    }

  static public function map <A, B, R>(m:NodeC<R,A>, k: A -> B): NodeC<R,B>
    return function(cont : Error -> B -> R)
      return m(function (err, a) {
        if (err != null)
          return cont(err, null);
        else
          return cont(null, k(a));
      })
}

