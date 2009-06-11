private var mock:Mock;

public function expects(methodName:String):Mock {
    return mock.expects(methodName); 
} 

public function times(timesInvoked:int):Mock {
    return mock.times(timesInvoked); 
} 

public function verify():void {
    mock.verify(); 
} 

public function success():Boolean {
    return mock.success(); 
} 

public function errorMessage():String {
    return mock.errorMessage(); 
} 

public function withArg(arg:Object):Mock {
	return mock.withArg(arg); 
}

public function withArgs(...args):Mock {
	return mock.withArg(args); 
}

public function willReturn(arg:Object):void {
	mock.willReturn(arg); 
}

public function clear():void {
	mock.clear();
}

protected function expectedReturnFor(methodName:String):Object{
	return mock.expectedReturnFor(methodName);
}

public function ignoreMissingExpectations():void {
	mock.ignoreMissingExpectations();
}