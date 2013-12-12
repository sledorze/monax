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

  public static function main() {
    new MonadTest().compilationTest();
    new NodeJsMonadTest().compilationTest();
  }

  @Test
  public function compilationTest() {

    var res =
      Monad.dO({
        value <= Some(55);
        value1 <= return value * 2;
        return value1 + value;
      });

    var nested =
      Monad.dO({
        v <= Some([10, 20]);
        w <= return {
          x <= v;
          return x + 2;
        };
        return w;
      });

      trace("Nested " + nested);

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
        c <= return 1000;
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
        return 'passed state: '+passedState+' new state: '+state;
      }).runState("1");

    Assert.areEqual(res3, "passed state: 1 new state: 2");

    var dummyReadFile:RC<String,String> = function(cont)  {
      var fileContents = "dummy-content";
      return cont(fileContents);
    }

    var res4 =
      ContM.dO({
        headline <= return 52;
        filecontents <= dummyReadFile;
        return Std.string(headline) + "\n" + filecontents;
      })(function(x) return x);

    Assert.areEqual(res4, "52\ndummy-content");


    var res5 =
      NullM.dO({
        a <= null;
        b <= 1;
        return a + b;
      });
    Assert.areEqual(res5, null);

    var res6 =
      NullM.dO({
        a <= 1;
        b <= null;
        return a = b;
      });
    Assert.areEqual(res6, null);

    var res7 =
      NullM.dO({
        a <= 2;
        b <= 3;
        return a + b;
      });
    Assert.areEqual(res7, 5);

    var res8 =
      NullM.dO({
        a <= 2;
        b <= a * 7 + 1;
        return a + b;
      });
    Assert.areEqual(res8, 17);
  }
}
