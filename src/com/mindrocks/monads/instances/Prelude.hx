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
    Monad._dO("OptionM", body, Context)
    
  public static function monad<T>(o : Option<T>)
    return OptionM
  
  inline public static function ret<T>(x : T) return
    Some(x)
  
  inline public static function map < T, U > (o : Option<T>, f : T -> U) : Option<U> {
    switch (o) {
      case Some(x) : return Some(f(x));
      default : return None;
    }
  }

  inline public static function flatMap<T, U>(o : Option<T>, f : T -> Option<U>) : Option<U> {
    switch (o) {
      case Some(x) : return f(x);
      default : return None;
    }
  }
}

@:native("Array_Monad") class ArrayM {

  @:macro public static function dO(body : Expr) return
    Monad._dO("ArrayM", body, Context)

  public static function monad<T>(o : Array<T>)
    return ArrayM

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

  public static function monad<S,T>(o : State<S,T>)
    return StateM

  @:macro public static function dO(body : Expr) return
    Monad._dO("StateM", body, Context, Monad.noOpt)

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

  public static function monad<T,U>(o : RC<T,U>)
    return ContM

  @:macro public static function dO(body : Expr) return
    Monad._dO("ContM", body, Context)

  static public function ret <A,R>(i:A):RC<R,A>
    return function(cont) return cont(i)

  static public function flatMap <A, B, R>(m:RC<R,A>, k: A -> RC<R,B>): RC<R,B>
    return function(cont : B -> R)
      return m(function(a) return k(a)(cont))

  static public function map <A, B, R>(m:RC<R,A>, k: A -> B): RC<R,B>
    return function(cont : B -> R)
      return m(function (a) return cont(k(a)))
}

