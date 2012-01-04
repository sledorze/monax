package com.mindrocks.monads.instances;

import haxe.macro.Expr;
import haxe.macro.Context;

import com.mindrocks.monads.Monad;



/**
 * ...
 * @author sledorze
 */
 
@:native("Option_Monad") class OptionM {
    
  @:macro public static function dO(body : Expr) return
    Monad.dO("OptionM", body, Context)

  inline public static function ret<T>(x : T) return
    Some(x)
  
  inline public static function map < T, U > (x : Option<T>, f : T -> U) : Option<U> {
    switch x {
      case Some(x) : return Some(f(x));
      default : return None;
    }
  }

  inline public static function flatMap<T, U>(x : Option<T>, f : T -> Option<U>) : Option<U> {
    switch (x) {
      case Some(x) : return f(x);
      default : return None;
    }
  }
}

@:native("Array_Monad") class ArrayM {
  @:macro public static function dO(body : Expr) return
  Monad.dO("ArrayM", body, Context)

  inline public static function ret<T>(x : T) return
    [x]
  
  inline public static function flatMap<T, U>(xs : Array<T>, f : T -> Array<U>) : Array<U> {
    var res = [];
    for (x in xs) {
      for (y in f(x)) {
        res.push(y);  
      }      
    }
    return res;
  }
  
  inline public static function map<T, U>(xs : Array<T>, f : T -> U) : Array<U> {
    var res = [];
    for (x in xs) {
      res.push(f(x));
    }
    return res;
  }
}

typedef State<S,T> = S -> {state:S, value:T};

@:native("ST_Monad") class StateM {

  @:macro public static function dO(body : Expr) return
    Monad.dO("StateM", body, Context, Monad.noOpt)

  static public function ret <S,T>(i:T):State<S,T> {
    return function(s:S){ return {state:s, value:i}; };
  }

  static public function flatMap <S,T,SU, U>(a:State<S,T>, f: T -> State<S,U>):State<S,U>{
    return function(state){
      var s = a(state);
      return f(s.value)(s.state);
    }
  }

  static public function gets <S>():State<S,S>{
    return function(s:S){
        return {
          state: s,
          value: s
        };
    };
  }

  static public function puts <S,T>(s:S):State<S,T>{
    return function(_:S){
        return {
          state: s,
          value: null
        };
    };
  }

  static public inline function runState <S,T>(f:State<S,T>, s:S):T{
    return f(s).value;
  }
  
}


typedef RC<R,A> = (A -> R) -> R

@:native("Cont_Monad") class ContM {

  @:macro public static function dO(body : Expr) return
    Monad.dO("ContM", body, Context)

  static public function ret <A,R>(i:A):RC<R,A>
    return function(cont) return cont(i)

  static public function flatMap <A, B, R>(m:RC<R,A>, k: A -> RC<R,B>): RC<R,B>
    return function(cont : B -> R)
      return m(function(a) return k(a)(cont))

  static public function map <A, B, R>(m:RC<R,A>, k: A -> B): RC<R,B>
    return function(cont : B -> R)
      return m(function (a) return cont(k(a)))
}


typedef Error = Dynamic
typedef NodeC<R,A> = (Error -> A -> R) -> R

@:native("NodeM") class NodeM {

  public static function specialOpt(m : MonadOp, position : Position) : MonadOp {
    #if macro
    var optimized = Monad.genOptimize(m, position);
    function mk(e : ExprDef) return { pos : position, expr : e };

    switch (optimized) {
      case MFlatMap(e, bindName, body):
        var body = specialOpt(body, position);
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
        return MFlatMap(newE, bindName, body);

      case MMap(e, bindName, body):
        var body = specialOpt(body, position);
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
        return MMap(newE, bindName, body);
      
      default:
        return optimized;
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
    
    // return m(function(err, a) return k(a)(cont));

  static public function map <A, B, R>(m:NodeC<R,A>, k: A -> B): NodeC<R,B>
    return function(cont : Error -> B -> R)
      return m(function (err, a) {
        if (err != null)
          return cont(err, null);
        else
          return cont(null, k(a));
      })
}
