//target - we are calling methods on this one, mock - this one is expecting our calls
package tests.com.mintdigital.helpers {
	public class TestDelegateHelper {
		static public function shouldDelegateCall(target:Object,mock:Object,function_name:String, arg:Object = null, receive_args:Object = null ):Object{
		    mock.ignoreMissingExpectations();

			// if it's mock too, we need to clear the expectations
		    /*if(target.expects)
				target.ignoreMissingExpectations();*/

			receive_args ||= arg;
			if(receive_args is Array) {
			    mock.expects(function_name).withArgs(receive_args).times(1);				
			} else if(receive_args){
			    mock.expects(function_name).withArg(receive_args).times(1);		
			} else {
				mock.expects(function_name).noArgs().times(1);		
			}

			if(arg is Array) {
				target[function_name].apply(null,arg);
			} else if(arg){
				target[function_name](arg);
			} else {
				target[function_name]();
			}

			mock.verify();
			return mock;
		}
		
	}
}
