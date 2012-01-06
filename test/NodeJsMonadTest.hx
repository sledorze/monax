package ;

/**
 * ...
 * @author sledorze
 */

import com.mindrocks.monads.Monad;
import com.mindrocks.monads.instances.NodeJs;
using com.mindrocks.monads.instances.NodeJs;

import massive.munit.Assert;

class NodeJsMonadTest {

  public function new() {
  }

  @Test
  public function compilationTest() {
    
    var db = new DB();    
    
    var getLength =
      NodeM.dO({
        coll <= db.collection("avatars", _.either());
        avatars <=
          switch (coll) {
            case Right(coll): coll.all("", _);
            case Left(err) : null; // broken...
          }
        size <= avatars[0].size(_.one());
//        size <= (function (cb) avatars[0].size(function (v) cb(null, v)))(_);
        ret(size); // avatars.length);
      });
    
    getLength(function (err, res) Assert.areEqual(2, res));
    getLength(function (err, res) Assert.areEqual(2, res));
    Assert.areEqual(3, DB.nbCalls);

  }
  
}


class Obj {
  var name : String;
  public function size(cb : Int -> Void) {
    cb(2);
  }
  public function new(name : String) {    
    this.name = name;
  }
}

class Collection {
  var objs : Array<Obj>;
  public function new() { 
    objs = [new Obj("a"), new Obj("b")];
  }
  public function all(name : String, cb : Error -> Array<Obj> -> Void) {    
    // cb("Aieeeuu!!", null);
    cb(null, objs);
  }
}

class DB {
  var coll : Collection;
  public function new() {
    coll = new Collection();
  }
  public static var nbCalls = 0;
  public function collection(name : String, cb : Error -> Collection -> Void) {
    nbCalls++;
    cb(null, coll);
  }
}
