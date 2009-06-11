        package {
           import flexunit.framework.TestSuite;
import generated_tests.com.mintdigital.helpers.*;
          import generated_tests.com.mintdigital.hemlock.*;
          import generated_tests.com.mintdigital.mocks.*;
          
           public class allTests{
              public static function suite() : TestSuite{
                var testSuite : TestSuite = new TestSuite();

testSuite.addTest( HelpersTestSuite.suite() );testSuite.addTest( HemlockTestSuite.suite() );testSuite.addTest( MocksTestSuite.suite() );
              return testSuite;
            }
          }
        }
