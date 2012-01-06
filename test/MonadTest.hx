package ;

/**
 * ...
 * @author sledorze
 */

import com.mindrocks.monads.instances.Prelude;
using com.mindrocks.monads.instances.Prelude;

import com.mindrocks.monads.Monad;
using com.mindrocks.monads.Monad;

import massive.munit.Assert;
// import com.mindrocks.macros.Monad; // just for imorting an definition Option


class MonadTest {

  public function new() {
  }

  @Test
  public function compilationTest() {
    
    var res =
      Monad.dO({
        value <= Some(55);
        value1 <= ret(value * 2);
        ret(value1 + value);
      });
    
      Monad.dO({
        v <= Some([10, 20]);        
        w <= ret(Monad.dO({
          x <= v;
          ret(x + 2);
        }));
        ret(w);
      });      
      
    /*  
    Monad.adO({
        value <= Some(55);
        value1 <= ret(value * 2);
        ret(value1 + value);
      });
  */
      
  
    Assert.isTrue(
      switch (res) {
        case None: false;
        case Some(x): x == 165;
      }
    );
   
    var res2 = 
      Monad.dO({
        a <= [0, 1, 2];
        b <= [10, 20, 30];
        c <= ret(1000);
        [a + b + c];
      });

    var expected = [1010, 1020, 1030, 1011, 1021, 1031, 1012, 1022, 1032];
    var equals = res2.length == expected.length;    
    if (equals) {
      for (i in 0...res2.length) {
        equals = equals && (res2[i] == expected[i]);
      }
    }
    Assert.isTrue(equals);

    var res3 =
      Monad.dO({
        passedState <= StateM.gets();
        puts("2");
        state <= gets();
        ret('passed state: '+passedState+' new state: '+state);
      }).runState("1");

    Assert.areEqual(res3, "passed state: 1 new state: 2");
    
    var dummyReadFile:RC<String,String> = function(cont)  {
      var fileContents = "dummy-content";
      return cont(fileContents);
    }
    
    var res4 =
      Monad.dO({
        headline <= ContM.ret(52);
        filecontents <= dummyReadFile;
        ret(Std.string(headline) + "\n" + filecontents);
      })(function(x) return x);
      
    Assert.areEqual(res4, "52\ndummy-content");
    
  }
}
