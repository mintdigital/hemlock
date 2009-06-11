import com.mintdigital.hemlock.widgets.debug.*;
import flash.events.MouseEvent;
import com.mintdigital.hemlock.Logger;
import com.mintdigital.hemlock.events.AppEvent;
	
private var widget:DebugWidget;
private var	parent:PartialHemlockContainerMock;

override public function setUp():void {	
	parent = new PartialHemlockContainerMock();
	widget = new DebugWidget(parent,{
        width:  100,
        height: 50
    });
	
	var client_mock:MockXMPPClient = new MockXMPPClient();    
    parent.client = client_mock; 
}

public function testShouldHaveEventsAndViewsDelegates():void {
	assertTrue(widget.delegates.events is DebugWidgetEvents);
	assertTrue(widget.delegates.views is DebugWidgetViews);
}

// test for external events
	
public function testDisplayLoggerMessages():void {
	var calls:Array = new Array("debug","info","warn","error","fatal")
	for each(var function_name:String in calls) {
		assertFalse(widget.views.logText.text.indexOf(function_name+'_text') >= 0)
		Logger[function_name](function_name+'_text');
		assertTrue(widget.views.logText.text.indexOf(function_name+'_text') >= 0)		
	}
	
}

public function testShouldToggleWidgetWithMouseClick():void {

    // set up to be hidden
    widget.views.log.visible = false;
    widget.views.toggle.text = 'show debugger';
    widget.views.toggle.backgroundColor = widget.views.colors.dark;
    widget.views.toggle.textColor = widget.views.colors.light;


	var ev1:MouseEvent = new MouseEvent(MouseEvent.CLICK);
	widget.views.toggle.dispatchEvent(ev1);
	
	assertTrue(widget.views.log.visible);
	assertEquals(widget.views.toggle.text, "hide debugger");
	assertEquals(widget.views.toggle.backgroundColor,widget.views.colors.light);
	assertEquals(widget.views.toggle.textColor,widget.views.colors.dark);
	
	var ev2:MouseEvent = new MouseEvent(MouseEvent.CLICK);
	widget.views.toggle.dispatchEvent(ev2);
	
	assertFalse(widget.views.log.visible);
	assertEquals(widget.views.toggle.text, "show debugger");
	assertEquals(widget.views.toggle.backgroundColor,widget.views.colors.dark);
	assertEquals(widget.views.toggle.textColor,widget.views.colors.light);
}

public function testShouldMarkWithADateONControlMarkClick():void {
	assertFalse(widget.views.logText.text.indexOf('---------------------------------------') >= 0)
	
	var ev:MouseEvent = new MouseEvent(MouseEvent.CLICK);
	widget.views.controls.mark.dispatchEvent(ev);
	assertTrue(widget.views.logText.text.indexOf('---------------------------------------') >= 0)
}


public function testShouldClearLogWhenClearClicked():void {
	var text:String = "some text to be cleared"
	widget.addText(text)
	assertTrue(widget.views.logText.text.indexOf(text) >= 0)
	
	var ev:MouseEvent = new MouseEvent(MouseEvent.CLICK);
	widget.views.controls.clear.dispatchEvent(ev);
	assertFalse(widget.views.logText.text.indexOf(text) >= 0)
	assertTrue(widget.views.logText.text.indexOf(HemlockEnvironment.SERVER) >= 0)	
}

// not really possible as we do not have access to system clipboard from here :(
/*public function onCopyAllClickShouldCopyToSystemClipboard():void {	
}*/
