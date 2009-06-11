package org.mock4as
{
	public class Mock  
	{
		public function Mock(){
		}  
		
		// hash table of methodName -> MethodInvocation obj
		private var actualMethodInvocations:Object = new Object();
		private var methodInvoked:Array = new Array();
		private var methodExpected:Array = new Array();
		
		// hash table of methodName -> MethodInvocation obj
		private var expectedMethodInvocations:Object = new Object();
		
		private var _ignoreMissingExpectations:Boolean = false;
		
		private var methodInProgress:String;
		
		private var testFailed:Boolean = false;
		private var reason:String;
		
		public function expects(methodName:String):Mock
		{
			this.methodInProgress = methodName;
			this.methodExpected.push(methodName);
			this.expectedMethodInvocations[methodName] = new MethodInvocation(methodName); 
			return this;
		}
		
		public function clear():void
		{
			this.actualMethodInvocations = new Object();
			this.methodInvoked = new Array();
			this.methodExpected = new Array();
			this.expectedMethodInvocations = new Object();
		}

		public function times(timesInvoked:int):Mock
		{
			expectedMethodInvocationFor(methodInProgress).timesInvoked = timesInvoked;
			return this;
		}
		
		private function expectedMethodInvocationFor(methodName:String):MethodInvocation
		{
			return this.expectedMethodInvocations[methodName];
		}

		private function actualMethodInvocationFor(methodName:String):MethodInvocation
		{
			return this.actualMethodInvocations[methodName];
		}
		
		public function noArgs():Mock
		{
			return this;
		}

		public function withArgs(...args):Mock
		{
			expectedMethodInvocationFor(methodInProgress).args = args; 			
			return this;
		}

		public function withArg(arg:Object):Mock
		{
			expectedMethodInvocationFor(methodInProgress).args[0] = arg; 			
			return this;
		}

		public function willReturn(returnValue:Object):void
		{
			expectedMethodInvocationFor(methodInProgress).returnValue = returnValue; 			
		}
		
		public function noReturn():void
		{
		}

		private function returnValueFor(methodName:String):Object
		{
			if(expectedMethodInvocationFor(methodName)!=null){
				return expectedMethodInvocationFor(methodName).returnValue;
			}
			return "No Return Defined for " + methodName;
		}

		private function verifyMethodIsExpected(methodName:String):void
		{
			if (!this.methodIsExpected(methodName)){
				reason = "Unexpected method call - " + methodName + "(...)";
				testFailed = true;
			}
		}
		
		private function verifyMethodHasBeenInvoked(methodName:String):void
		{
			if (!this.methodHasBeenInvoked(methodName) && this.expectedMethodInvocations[methodName].timesInvoked != 0){
				reason = "Expected method - " + methodName + "(...) not called";
				testFailed = true;
			}
		}
		
		private function methodIsExpected(methodName:String):Boolean{
			return (this.expectedMethodInvocationFor(methodName)!=null);
		} 

		private function verifyTimesInvoked(methodName:String):void
		{
			if (!this.testFailed){
				var expectedTimeInvoked:int = this.expectedMethodInvocationFor(methodName).timesInvoked;
				var actualTimeInvoked:int = this.actualMethodInvocationFor(methodName).timesInvoked;
				
				if (actualTimeInvoked != expectedTimeInvoked){
					reason = "Unexpected method call. Expected " + methodName + "(...) to be invoked " + expectedTimeInvoked + " time(s), but it was invoked " + actualTimeInvoked + " time(s)." ;
					testFailed = true;
				}			
			}
		}	
		
		public function expectedReturnFor(methodName:String):Object{
			return this.returnValueFor(methodName);			
		}	

		private function methodHasBeenInvoked(methodName:String):Boolean{
			return (this.actualMethodInvocationFor(methodName) != null);
		} 
		
		public function record(methodName:String, ...args):void{
			this.methodInvoked.push(methodName);
			if (this.methodHasBeenInvoked(methodName)){
				this.actualMethodInvocationFor(methodName).timesInvoked++;
			}else{
				var methodInvoked:MethodInvocation = new MethodInvocation(methodName)
				methodInvoked.args = args;
				this.actualMethodInvocations[methodName] = methodInvoked;
			}
			
		}
		private function verifyArgList(methodName:String, args:Array):void{
			if (!this.testFailed){
				var argsReceived:String = args.toString();
				var methInv:MethodInvocation;
				methInv = this.expectedMethodInvocationFor(methodName);
				var argsExpected:String = methInv.args.toString();
			
				if (argsReceived != argsExpected){
					reason = "Unexpected argument value. Expected " + methodName + "("+argsExpected+"), but " + methodName + "("+argsReceived+") was invoked instead.";
					testFailed = true;
				}
				
			}

		}
		
		// verify all method expectations for this mock
		public function verify():void{
			trace("invoked methods:"+this.methodInvoked.join(","));
			var methodInvokation:MethodInvocation;
			for (var i:int=0; i<this.methodInvoked.length; i++){		
				
				methodInvokation = this.actualMethodInvocationFor(this.methodInvoked.valueOf(i));
				trace("checking expectations for invoked method");
				trace(this.methodInvoked[i]);
				
				if(!this._ignoreMissingExpectations) {
					this.verifyMethodIsExpected(this.methodInvoked[i]);
				}
					
				if (methodInvokation!= null){
					this.verifyTimesInvoked(methodInvokation.name);
					this.verifyArgList(methodInvokation.name, methodInvokation.args);
				}
				/* remove call from expected if all is fine */
				this.methodExpected.splice(this.methodExpected.indexOf(this.methodInvoked[i]),1);					
			}
			
			for (i=0; i<this.methodExpected.length; i++){	
				
				this.verifyMethodHasBeenInvoked(this.methodExpected[i]);
				trace("checking invokations for expected method");
				trace(this.methodExpected[i]);
			}
		}
		
		public function success():Boolean{
			this.verify();
			return !this.testFailed;
		}

		public function hasError():Boolean{
			return !this.testFailed;
		}
		public function errorMessage():String{
			return this.reason;
		}
		
		public function ignoreMissingExpectations():void{
			this._ignoreMissingExpectations = true;
		}
		
	}
}

class MethodInvocation {
   function MethodInvocation(methodName : String){
         this.name = methodName;
   }	
	public var name:String;
	public var timesInvoked:int=1;
	public var args:Array = new Array();
	public var returnValue:Object;
}
    
