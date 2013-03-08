(function () { "use strict";
var $estr = function() { return js.Boot.__string_rec(this,''); };
function $extend(from, fields) {
	function inherit() {}; inherit.prototype = from; var proto = new inherit();
	for (var name in fields) proto[name] = fields[name];
	return proto;
}
var MonadTest = function() {
};
MonadTest.__name__ = ["MonadTest"];
MonadTest.main = function() {
	new MonadTest().compilationTest();
	new NodeJsMonadTest().compilationTest();
}
MonadTest.prototype = {
	compilationTest: function() {
		var res = (function($this) {
			var $r;
			var $e = (com.mindrocks.monads.Option.Some(55));
			switch( $e[1] ) {
			case 1:
				var o_eSome_0 = $e[2];
				$r = com.mindrocks.monads.Option.Some(o_eSome_0 * 2 + o_eSome_0);
				break;
			default:
				$r = com.mindrocks.monads.Option.None;
			}
			return $r;
		}(this));
		var nested = (function($this) {
			var $r;
			var $e = (com.mindrocks.monads.Option.Some([10,20]));
			switch( $e[1] ) {
			case 1:
				var o_eSome_0 = $e[2];
				$r = (function(v) {
					return com.mindrocks.monads.Option.Some(Array_Monad.map(v,function(x) {
						return x + 2;
					}));
				})(o_eSome_0);
				break;
			default:
				$r = com.mindrocks.monads.Option.None;
			}
			return $r;
		}(this));
		console.log("Nested " + Std.string(nested));
		massive.munit.Assert.isTrue((function($this) {
			var $r;
			var $e = (res);
			switch( $e[1] ) {
			case 0:
				$r = false;
				break;
			case 1:
				var res_eSome_0 = $e[2];
				$r = res_eSome_0 == 165;
				break;
			}
			return $r;
		}(this)),{ fileName : "MonadTest.hx", lineNumber : 50, className : "MonadTest", methodName : "compilationTest"});
		var res2 = Array_Monad.flatMap([0,1,2],function(a) {
			return Array_Monad.flatMap([10,20,30],function(b) {
				return [a + b + 1000];
			});
		});
		var expected = [1010,1020,1030,1011,1021,1031,1012,1022,1032];
		var equals = res2.length == expected.length;
		if(equals) {
			var _g1 = 0, _g = res2.length;
			while(_g1 < _g) {
				var i = _g1++;
				equals = equals && res2[i] == expected[i];
			}
		}
		massive.munit.Assert.isTrue(equals,{ fileName : "MonadTest.hx", lineNumber : 72, className : "MonadTest", methodName : "compilationTest"});
		var res3 = (ST_Monad.flatMap(ST_Monad.gets(),function(passedState) {
			return ST_Monad.flatMap(ST_Monad.puts("2"),function(_) {
				return ST_Monad.flatMap(ST_Monad.gets(),function(state) {
					return ST_Monad.ret("passed state: " + passedState + " new state: " + state);
				});
			});
		}))("1").value;
		massive.munit.Assert.areEqual(res3,"passed state: 1 new state: 2",{ fileName : "MonadTest.hx", lineNumber : 82, className : "MonadTest", methodName : "compilationTest"});
		var dummyReadFile = function(cont) {
			var fileContents = "dummy-content";
			return cont(fileContents);
		};
		var res4 = ((function(headline) {
			return Cont_Monad.map(dummyReadFile,function(filecontents) {
				return Std.string(headline) + "\n" + filecontents;
			});
		})(52))(function(x) {
			return x;
		});
		massive.munit.Assert.areEqual(res4,"52\ndummy-content",{ fileName : "MonadTest.hx", lineNumber : 96, className : "MonadTest", methodName : "compilationTest"});
	}
	,__class__: MonadTest
}
var NodeJsMonadTest = function() {
};
NodeJsMonadTest.__name__ = ["NodeJsMonadTest"];
NodeJsMonadTest.prototype = {
	compilationTest: function() {
		var db = new DB();
		var getLengthViaEither = NodeM.flatMap(function(_) {
			return db.collection("avatars",com.mindrocks.monads.instances.NodeJsEitherCB.either(_));
		},function(coll) {
			return NodeM.flatMap(function(_) {
				return (function($this) {
					var $r;
					var $e = (coll);
					switch( $e[1] ) {
					case 1:
						var coll_eRight_0 = $e[2];
						$r = coll_eRight_0.all("",_);
						break;
					case 0:
						$r = null;
						break;
					}
					return $r;
				}(this));
			},function(avatars) {
				return NodeM.map(function(_) {
					return avatars[0].size(com.mindrocks.monads.instances.NodeJsEitherCB.single(_));
				},function(size) {
					return size;
				});
			});
		});
		var getLength = NodeM.flatMap(function(_) {
			return db.collection("avatars",_);
		},function(coll1) {
			return NodeM.flatMap(function(_) {
				return coll1.all("",_);
			},function(avatars1) {
				return NodeM.map(function(_) {
					return avatars1[0].size(com.mindrocks.monads.instances.NodeJsEitherCB.single(_));
				},function(size) {
					return size;
				});
			});
		});
		getLength(function(err,res) {
			massive.munit.Assert.areEqual(2,res,{ fileName : "NodeJsMonadTest.hx", lineNumber : 47, className : "NodeJsMonadTest", methodName : "compilationTest"});
		});
		getLength(function(err,res) {
			massive.munit.Assert.areEqual(2,res,{ fileName : "NodeJsMonadTest.hx", lineNumber : 48, className : "NodeJsMonadTest", methodName : "compilationTest"});
		});
		massive.munit.Assert.areEqual(2,DB.nbCalls,{ fileName : "NodeJsMonadTest.hx", lineNumber : 49, className : "NodeJsMonadTest", methodName : "compilationTest"});
	}
	,__class__: NodeJsMonadTest
}
var Obj = function(name) {
	this.name = name;
};
Obj.__name__ = ["Obj"];
Obj.prototype = {
	size: function(cb) {
		cb(2);
	}
	,__class__: Obj
}
var Collection = function() {
	this.objs = [new Obj("a"),new Obj("b")];
};
Collection.__name__ = ["Collection"];
Collection.prototype = {
	all: function(name,cb) {
		cb(null,this.objs);
	}
	,__class__: Collection
}
var DB = function() {
	this.coll = new Collection();
};
DB.__name__ = ["DB"];
DB.prototype = {
	collection: function(name,cb) {
		DB.nbCalls++;
		cb(null,this.coll);
	}
	,__class__: DB
}
var Std = function() { }
Std.__name__ = ["Std"];
Std.string = function(s) {
	return js.Boot.__string_rec(s,"");
}
var ValueType = { __ename__ : true, __constructs__ : ["TNull","TInt","TFloat","TBool","TObject","TFunction","TClass","TEnum","TUnknown"] }
ValueType.TNull = ["TNull",0];
ValueType.TNull.toString = $estr;
ValueType.TNull.__enum__ = ValueType;
ValueType.TInt = ["TInt",1];
ValueType.TInt.toString = $estr;
ValueType.TInt.__enum__ = ValueType;
ValueType.TFloat = ["TFloat",2];
ValueType.TFloat.toString = $estr;
ValueType.TFloat.__enum__ = ValueType;
ValueType.TBool = ["TBool",3];
ValueType.TBool.toString = $estr;
ValueType.TBool.__enum__ = ValueType;
ValueType.TObject = ["TObject",4];
ValueType.TObject.toString = $estr;
ValueType.TObject.__enum__ = ValueType;
ValueType.TFunction = ["TFunction",5];
ValueType.TFunction.toString = $estr;
ValueType.TFunction.__enum__ = ValueType;
ValueType.TClass = function(c) { var $x = ["TClass",6,c]; $x.__enum__ = ValueType; $x.toString = $estr; return $x; }
ValueType.TEnum = function(e) { var $x = ["TEnum",7,e]; $x.__enum__ = ValueType; $x.toString = $estr; return $x; }
ValueType.TUnknown = ["TUnknown",8];
ValueType.TUnknown.toString = $estr;
ValueType.TUnknown.__enum__ = ValueType;
var Type = function() { }
Type.__name__ = ["Type"];
Type.getClassName = function(c) {
	var a = c.__name__;
	return a.join(".");
}
Type["typeof"] = function(v) {
	var _g = typeof(v);
	switch(_g) {
	case "boolean":
		return ValueType.TBool;
	case "string":
		return ValueType.TClass(String);
	case "number":
		if(Math.ceil(v) == v % 2147483648.0) return ValueType.TInt;
		return ValueType.TFloat;
	case "object":
		if(v == null) return ValueType.TNull;
		var e = v.__enum__;
		if(e != null) return ValueType.TEnum(e);
		var c = v.__class__;
		if(c != null) return ValueType.TClass(c);
		return ValueType.TObject;
	case "function":
		if(v.__name__ || v.__ename__) return ValueType.TObject;
		return ValueType.TFunction;
	case "undefined":
		return ValueType.TNull;
	default:
		return ValueType.TUnknown;
	}
}
Type.enumEq = function(a,b) {
	if(a == b) return true;
	try {
		if(a[0] != b[0]) return false;
		var _g1 = 2, _g = a.length;
		while(_g1 < _g) {
			var i = _g1++;
			if(!Type.enumEq(a[i],b[i])) return false;
		}
		var e = a.__enum__;
		if(e != b.__enum__ || e == null) return false;
	} catch( e ) {
		return false;
	}
	return true;
}
var com = {}
com.mindrocks = {}
com.mindrocks.monads = {}
com.mindrocks.monads.MonadOp = { __ename__ : true, __constructs__ : [] }
com.mindrocks.monads.Option = { __ename__ : true, __constructs__ : ["None","Some"] }
com.mindrocks.monads.Option.None = ["None",0];
com.mindrocks.monads.Option.None.toString = $estr;
com.mindrocks.monads.Option.None.__enum__ = com.mindrocks.monads.Option;
com.mindrocks.monads.Option.Some = function(v) { var $x = ["Some",1,v]; $x.__enum__ = com.mindrocks.monads.Option; $x.toString = $estr; return $x; }
com.mindrocks.monads.Monad = function() { }
com.mindrocks.monads.Monad.__name__ = ["com","mindrocks","monads","Monad"];
com.mindrocks.monads.Monad.noOpt = function(m,position) {
	return m;
}
com.mindrocks.monads.Monad._dO = function(monadTypeName,body,context,optimize) {
}
com.mindrocks.monads.instances = {}
com.mindrocks.monads.instances.Either = { __ename__ : true, __constructs__ : ["Left","Right"] }
com.mindrocks.monads.instances.Either.Left = function(a) { var $x = ["Left",0,a]; $x.__enum__ = com.mindrocks.monads.instances.Either; $x.toString = $estr; return $x; }
com.mindrocks.monads.instances.Either.Right = function(b) { var $x = ["Right",1,b]; $x.__enum__ = com.mindrocks.monads.instances.Either; $x.toString = $estr; return $x; }
com.mindrocks.monads.instances.NodeJsEitherCB = function() { }
com.mindrocks.monads.instances.NodeJsEitherCB.__name__ = ["com","mindrocks","monads","instances","NodeJsEitherCB"];
com.mindrocks.monads.instances.NodeJsEitherCB.either = function(f) {
	return function(err,v) {
		if(err == null) f(null,com.mindrocks.monads.instances.Either.Right(v)); else f(null,com.mindrocks.monads.instances.Either.Left(err));
	};
}
com.mindrocks.monads.instances.NodeJsEitherCB.single = function(f) {
	return function(v) {
		f(null,v);
	};
}
var NodeM = function() { }
NodeM.__name__ = ["NodeM"];
NodeM.monad = function(o) {
	return NodeM;
}
NodeM.specialOpt = function(m,position) {
	return null;
}
NodeM.ret = function(i) {
	return function(cont) {
		return cont(null,i);
	};
}
NodeM.flatMap = function(m,k) {
	return function(cont) {
		return m(function(err,a) {
			if(err != null) return cont(err,null); else return (k(a))(cont);
		});
	};
}
NodeM.map = function(m,k) {
	return function(cont) {
		return m(function(err,a) {
			if(err != null) return cont(err,null); else return cont(null,k(a));
		});
	};
}
var Option_Monad = function() { }
Option_Monad.__name__ = ["Option_Monad"];
Option_Monad.monad = function(o) {
	return Option_Monad;
}
Option_Monad.ret = function(x) {
	return com.mindrocks.monads.Option.Some(x);
}
Option_Monad.map = function(o,f) {
	var $e = (o);
	switch( $e[1] ) {
	case 1:
		var o_eSome_0 = $e[2];
		return com.mindrocks.monads.Option.Some(f(o_eSome_0));
	default:
		return com.mindrocks.monads.Option.None;
	}
}
Option_Monad.flatMap = function(o,f) {
	var $e = (o);
	switch( $e[1] ) {
	case 1:
		var o_eSome_0 = $e[2];
		return f(o_eSome_0);
	default:
		return com.mindrocks.monads.Option.None;
	}
}
var Array_Monad = function() { }
Array_Monad.__name__ = ["Array_Monad"];
Array_Monad.monad = function(o) {
	return Array_Monad;
}
Array_Monad.ret = function(x) {
	return [x];
}
Array_Monad.flatMap = function(xs,f) {
	var res = [];
	var _g = 0;
	while(_g < xs.length) {
		var x = xs[_g];
		++_g;
		var _g1 = 0, _g2 = f(x);
		while(_g1 < _g2.length) {
			var y = _g2[_g1];
			++_g1;
			res.push(y);
		}
	}
	return res;
}
Array_Monad.map = function(xs,f) {
	var res = [];
	var _g = 0;
	while(_g < xs.length) {
		var x = xs[_g];
		++_g;
		res.push(f(x));
	}
	return res;
}
var ST_Monad = function() { }
ST_Monad.__name__ = ["ST_Monad"];
ST_Monad.monad = function(o) {
	return ST_Monad;
}
ST_Monad.ret = function(i) {
	return function(s) {
		return { state : s, value : i};
	};
}
ST_Monad.flatMap = function(a,f) {
	return function(state) {
		var s = a(state);
		return (f(s.value))(s.state);
	};
}
ST_Monad.gets = function() {
	return function(s) {
		return { state : s, value : s};
	};
}
ST_Monad.puts = function(s) {
	return function(_) {
		return { state : s, value : null};
	};
}
ST_Monad.runState = function(f,s) {
	return f(s).value;
}
var Cont_Monad = function() { }
Cont_Monad.__name__ = ["Cont_Monad"];
Cont_Monad.monad = function(o) {
	return Cont_Monad;
}
Cont_Monad.ret = function(i) {
	return function(cont) {
		return cont(i);
	};
}
Cont_Monad.flatMap = function(m,k) {
	return function(cont) {
		return m(function(a) {
			return (k(a))(cont);
		});
	};
}
Cont_Monad.map = function(m,k) {
	return function(cont) {
		return m(function(a) {
			return cont(k(a));
		});
	};
}
var haxe = {}
haxe.ds = {}
haxe.ds.StringMap = function() {
	this.h = { };
};
haxe.ds.StringMap.__name__ = ["haxe","ds","StringMap"];
haxe.ds.StringMap.prototype = {
	__class__: haxe.ds.StringMap
}
var js = {}
js.Boot = function() { }
js.Boot.__name__ = ["js","Boot"];
js.Boot.__string_rec = function(o,s) {
	if(o == null) return "null";
	if(s.length >= 5) return "<...>";
	var t = typeof(o);
	if(t == "function" && (o.__name__ || o.__ename__)) t = "object";
	switch(t) {
	case "object":
		if(o instanceof Array) {
			if(o.__enum__) {
				if(o.length == 2) return o[0];
				var str = o[0] + "(";
				s += "\t";
				var _g1 = 2, _g = o.length;
				while(_g1 < _g) {
					var i = _g1++;
					if(i != 2) str += "," + js.Boot.__string_rec(o[i],s); else str += js.Boot.__string_rec(o[i],s);
				}
				return str + ")";
			}
			var l = o.length;
			var i;
			var str = "[";
			s += "\t";
			var _g = 0;
			while(_g < l) {
				var i1 = _g++;
				str += (i1 > 0?",":"") + js.Boot.__string_rec(o[i1],s);
			}
			str += "]";
			return str;
		}
		var tostr;
		try {
			tostr = o.toString;
		} catch( e ) {
			return "???";
		}
		if(tostr != null && tostr != Object.toString) {
			var s2 = o.toString();
			if(s2 != "[object Object]") return s2;
		}
		var k = null;
		var str = "{\n";
		s += "\t";
		var hasp = o.hasOwnProperty != null;
		for( var k in o ) { ;
		if(hasp && !o.hasOwnProperty(k)) {
			continue;
		}
		if(k == "prototype" || k == "__class__" || k == "__super__" || k == "__interfaces__" || k == "__properties__") {
			continue;
		}
		if(str.length != 2) str += ", \n";
		str += s + k + " : " + js.Boot.__string_rec(o[k],s);
		}
		s = s.substring(1);
		str += "\n" + s + "}";
		return str;
	case "function":
		return "<function>";
	case "string":
		return o;
	default:
		return String(o);
	}
}
js.Boot.__interfLoop = function(cc,cl) {
	if(cc == null) return false;
	if(cc == cl) return true;
	var intf = cc.__interfaces__;
	if(intf != null) {
		var _g1 = 0, _g = intf.length;
		while(_g1 < _g) {
			var i = _g1++;
			var i1 = intf[i];
			if(i1 == cl || js.Boot.__interfLoop(i1,cl)) return true;
		}
	}
	return js.Boot.__interfLoop(cc.__super__,cl);
}
js.Boot.__instanceof = function(o,cl) {
	try {
		if(o instanceof cl) {
			if(cl == Array) return o.__enum__ == null;
			return true;
		}
		if(js.Boot.__interfLoop(o.__class__,cl)) return true;
	} catch( e ) {
		if(cl == null) return false;
	}
	switch(cl) {
	case Int:
		return Math.ceil(o%2147483648.0) === o;
	case Float:
		return typeof(o) == "number";
	case Bool:
		return o === true || o === false;
	case String:
		return typeof(o) == "string";
	case Dynamic:
		return true;
	default:
		if(o == null) return false;
		if(cl == Class && o.__name__ != null) return true; else null;
		if(cl == Enum && o.__ename__ != null) return true; else null;
		return o.__enum__ == cl;
	}
}
var massive = {}
massive.haxe = {}
massive.haxe.Exception = function(message,info) {
	this.message = message;
	this.info = info;
	this.type = massive.haxe.util.ReflectUtil.here({ fileName : "Exception.hx", lineNumber : 70, className : "massive.haxe.Exception", methodName : "new"}).className;
};
massive.haxe.Exception.__name__ = ["massive","haxe","Exception"];
massive.haxe.Exception.prototype = {
	toString: function() {
		var str = this.type + ": " + this.message;
		if(this.info != null) str += " at " + this.info.className + "#" + this.info.methodName + " (" + this.info.lineNumber + ")";
		return str;
	}
	,__class__: massive.haxe.Exception
}
massive.haxe.util = {}
massive.haxe.util.ReflectUtil = function() { }
massive.haxe.util.ReflectUtil.__name__ = ["massive","haxe","util","ReflectUtil"];
massive.haxe.util.ReflectUtil.here = function(info) {
	return info;
}
massive.munit = {}
massive.munit.Assert = function() { }
massive.munit.Assert.__name__ = ["massive","munit","Assert"];
massive.munit.Assert.isTrue = function(value,info) {
	massive.munit.Assert.assertionCount++;
	if(value != true) massive.munit.Assert.fail("Expected TRUE but was [" + Std.string(value) + "]",info);
}
massive.munit.Assert.isFalse = function(value,info) {
	massive.munit.Assert.assertionCount++;
	if(value != false) massive.munit.Assert.fail("Expected FALSE but was [" + Std.string(value) + "]",info);
}
massive.munit.Assert.isNull = function(value,info) {
	massive.munit.Assert.assertionCount++;
	if(value != null) massive.munit.Assert.fail("Value [" + Std.string(value) + "] was not NULL",info);
}
massive.munit.Assert.isNotNull = function(value,info) {
	massive.munit.Assert.assertionCount++;
	if(value == null) massive.munit.Assert.fail("Value [" + Std.string(value) + "] was NULL",info);
}
massive.munit.Assert.isNaN = function(value,info) {
	massive.munit.Assert.assertionCount++;
	if(!Math.isNaN(value)) massive.munit.Assert.fail("Value [" + value + "]  was not NaN",info);
}
massive.munit.Assert.isNotNaN = function(value,info) {
	massive.munit.Assert.assertionCount++;
	if(Math.isNaN(value)) massive.munit.Assert.fail("Value [" + value + "] was NaN",info);
}
massive.munit.Assert.isType = function(value,type,info) {
	massive.munit.Assert.assertionCount++;
	if(!js.Boot.__instanceof(value,type)) massive.munit.Assert.fail("Value [" + Std.string(value) + "] was not of type: " + Type.getClassName(type),info);
}
massive.munit.Assert.isNotType = function(value,type,info) {
	massive.munit.Assert.assertionCount++;
	if(js.Boot.__instanceof(value,type)) massive.munit.Assert.fail("Value [" + Std.string(value) + "] was of type: " + Type.getClassName(type),info);
}
massive.munit.Assert.areEqual = function(expected,actual,info) {
	massive.munit.Assert.assertionCount++;
	var equal = (function($this) {
		var $r;
		var _g = Type["typeof"](expected);
		$r = (function($this) {
			var $r;
			switch( (_g)[1] ) {
			case 7:
				$r = Type.enumEq(expected,actual);
				break;
			default:
				$r = expected == actual;
			}
			return $r;
		}($this));
		return $r;
	}(this));
	if(!equal) massive.munit.Assert.fail("Value [" + Std.string(actual) + "] was not equal to expected value [" + Std.string(expected) + "]",info);
}
massive.munit.Assert.areNotEqual = function(expected,actual,info) {
	massive.munit.Assert.assertionCount++;
	var equal = (function($this) {
		var $r;
		var _g = Type["typeof"](expected);
		$r = (function($this) {
			var $r;
			switch( (_g)[1] ) {
			case 7:
				$r = Type.enumEq(expected,actual);
				break;
			default:
				$r = expected == actual;
			}
			return $r;
		}($this));
		return $r;
	}(this));
	if(equal) massive.munit.Assert.fail("Value [" + Std.string(actual) + "] was equal to value [" + Std.string(expected) + "]",info);
}
massive.munit.Assert.areSame = function(expected,actual,info) {
	massive.munit.Assert.assertionCount++;
	if(expected != actual) massive.munit.Assert.fail("Value [" + Std.string(actual) + "] was not the same as expected value [" + Std.string(expected) + "]",info);
}
massive.munit.Assert.areNotSame = function(expected,actual,info) {
	massive.munit.Assert.assertionCount++;
	if(expected == actual) massive.munit.Assert.fail("Value [" + Std.string(actual) + "] was the same as expected value [" + Std.string(expected) + "]",info);
}
massive.munit.Assert.fail = function(msg,info) {
	throw new massive.munit.AssertionException(msg,info);
}
massive.munit.MUnitException = function(message,info) {
	massive.haxe.Exception.call(this,message,info);
	this.type = massive.haxe.util.ReflectUtil.here({ fileName : "MUnitException.hx", lineNumber : 50, className : "massive.munit.MUnitException", methodName : "new"}).className;
};
massive.munit.MUnitException.__name__ = ["massive","munit","MUnitException"];
massive.munit.MUnitException.__super__ = massive.haxe.Exception;
massive.munit.MUnitException.prototype = $extend(massive.haxe.Exception.prototype,{
	__class__: massive.munit.MUnitException
});
massive.munit.AssertionException = function(msg,info) {
	massive.munit.MUnitException.call(this,msg,info);
	this.type = massive.haxe.util.ReflectUtil.here({ fileName : "AssertionException.hx", lineNumber : 49, className : "massive.munit.AssertionException", methodName : "new"}).className;
};
massive.munit.AssertionException.__name__ = ["massive","munit","AssertionException"];
massive.munit.AssertionException.__super__ = massive.munit.MUnitException;
massive.munit.AssertionException.prototype = $extend(massive.munit.MUnitException.prototype,{
	__class__: massive.munit.AssertionException
});
Math.__name__ = ["Math"];
Math.NaN = Number.NaN;
Math.NEGATIVE_INFINITY = Number.NEGATIVE_INFINITY;
Math.POSITIVE_INFINITY = Number.POSITIVE_INFINITY;
Math.isFinite = function(i) {
	return isFinite(i);
};
Math.isNaN = function(i) {
	return isNaN(i);
};
String.prototype.__class__ = String;
String.__name__ = ["String"];
Array.prototype.__class__ = Array;
Array.__name__ = ["Array"];
var Int = { __name__ : ["Int"]};
var Dynamic = { __name__ : ["Dynamic"]};
var Float = Number;
Float.__name__ = ["Float"];
var Bool = Boolean;
Bool.__ename__ = ["Bool"];
var Class = { __name__ : ["Class"]};
var Enum = { };
MonadTest.__meta__ = { fields : { compilationTest : { Test : null}}};
NodeJsMonadTest.__meta__ = { fields : { compilationTest : { Test : null}}};
DB.nbCalls = 0;
com.mindrocks.monads.Monad.validNames = new haxe.ds.StringMap();
massive.munit.Assert.assertionCount = 0;
MonadTest.main();
})();
