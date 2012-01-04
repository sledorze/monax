package ;

/**
 * ...
 * @author sledorze
 */

import com.mindrocks.monads.Monad;
import com.mindrocks.monads.instances.NodeJs;

import massive.munit.Assert;

class NodeJsMonadTest {

  public function new() {
  }

  @Test
  public function compilationTest() {
    
    var db = new DB();    
    var res5 : String = "";
    
    NodeM.dO({
      coll <= db.collection("avatars", _);
      avatars <= coll.all("", _);
      ret(avatars.length);
    })(function (err, res) res5 = ("res " + err + " | " + res));
      
    Assert.areEqual(res5, "res null | 2");

  }
  
}


class Obj {
  var name : String;
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
  public function collection(name : String, cb : Error -> Collection -> Void) {
    cb(null, coll);
  }
}
