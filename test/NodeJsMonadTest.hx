package ;

/**
 * ...
 * @author sledorze
 */

import com.mindrocks.monads.Monad;
import com.mindrocks.monads.instances.NodeJs;
using com.mindrocks.monads.instances.NodeJs;

import com.mindrocks.monads.instances.Prelude;
using com.mindrocks.monads.instances.Prelude;

import massive.munit.Assert;

class NodeJsMonadTest {

  public function new() {
  }

  @Test
  public function compilationTest() {
    
    var db = new DB();
    
    var getLengthViaEither =
      NodeM.dO({
        coll <= db.collection("avatars", _.either()); // If one wants to handle errors explicitely he can use 'either' construct
        avatars <= 
          switch (coll) {
            case Right(coll): coll.all("", _);
            case Left(_) : null; // but it has to really handle it explicitely! (not like this)
          }        
        size <= avatars[0].size(_.single());
        return size;
      });
      
    var getLength =
      NodeM.dO({
        coll <= db.collection("avatars", _);
        avatars <= coll.all("", _);
        size <= avatars[0].size(_.single()); // single parameter cb (no possible error)
        return size;
      });
    
    getLength(function (err, res) Assert.areEqual(2, res));
    getLength(function (err, res) Assert.areEqual(2, res));
    Assert.areEqual(2, DB.nbCalls);

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
