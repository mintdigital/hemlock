// TODO: Test Logger.debug('...'), etc instead; no more LogEvent

import org.mock4as.Mock;

private var logger:Logger;
private var mock:Object;

override public function setUp():void {
	mock = new Mock();
	var func:Function = function(text:String):void {
		mock.record("calledWith",text);
	}
	Logger.addLogFunction(func);
}

public function testLoggerMethods():void {
	var calls:Array = new Array("debug","info","warn","error","fatal")
	for each(var function_name:String in calls) {
	    mock.expects("calledWith").withArg('text');

	    Logger[function_name]('text');
	
		trace("logger:"+function_name);
	    mock.verify();
	    assertNull(mock.errorMessage());	
	}
}