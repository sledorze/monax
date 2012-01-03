package ;

/**
 * ...
 * @author sledorze
 */

import Standard;
using Standard;

class MonadTest {

  public static function foo() {
    
  }
  
  public static function compilationTest() {
    
    var res =
      OptionM.dO({
        value <= ret(55);
        value1 <= ret(value * 2);        
        ret(value1 + value);
      });
      
    var res2 = 
      ArrayM.dO({
        a <= [0, 1, 2];
        b <= [10, 20, 30];
        c <= ret(1000);
        [a + b + c];
      });
      
    var res3 =
      StateM.dO({
        passedState <= gets();
        puts("2");
        state <= gets();
        ret('passed state: '+passedState+' new state: '+state);
      }).runState("1");

    var dummyReadFile:RC<String,String> = function(cont)  {
      var fileContents = "dummy-content";
      return cont(fileContents);
    }

    var res4 =
      ContM.dO({
        headline <= ret(52);
        filecontents <= dummyReadFile;
        ret(Std.string(headline) + "\n" + filecontents);
      })(function(x) return x);

    trace("result " + Std.string(res));
    trace("result2 " + Std.string(res2));
    trace("result3 " + Std.string(res3));
    trace("result4 " + Std.string(res4));
  }  
}
