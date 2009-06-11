import com.mintdigital.hemlock.containers.HemlockContainer
import com.mintdigital.hemlock.data.JID;
import com.mintdigital.hemlock.display.HemlockSprite
import com.mintdigital.hemlock.widgets.HemlockWidget
import tests.com.mintdigital.helpers.TestDelegateHelper;

import org.mock4as.Mock

private var container_mock:PartialHemlockContainerMock;
private var widget:HemlockWidget;
private var jid:JID;

override public function setUp():void {
	container_mock = new PartialHemlockContainerMock();
	widget = new HemlockWidget(container_mock, {jid: new JID("test"), width: 200, height: 200})
	
	// need to set this so none of the messages are forwarded further (as we don't want to create another mock)
	var client:MockXMPPClient = new MockXMPPClient();
	client.ignoreMissingExpectations();
	container_mock.client = client

}

public function testSendMessageShouldBeDelegatedToContainer():void{
	assertNull(
		TestDelegateHelper.shouldDelegateCall(widget, container_mock, "sendMessage","text", [widget.bareJID,"text"])
		.errorMessage()
	);
}

public function testSendDataMessageShouldBeDelegatedToContainer():void{
	assertNull(
		TestDelegateHelper.shouldDelegateCall(widget, container_mock, "sendDataMessage",["text",{}], [widget.bareJID,"text",{}])
		.errorMessage()
	);
}

public function testSendPresenceShouldBeDelegatedToContainer():void{
	assertNull(
		TestDelegateHelper.shouldDelegateCall(widget, container_mock, "sendPresence",{}, [widget.bareJID,{}])
		.errorMessage()
	);
}

public function testGetScreen():void{
	assertEquals(null, widget.getScreen("screen1"));
	
	var screen1:HemlockSprite = new HemlockSprite();
	widget.views.screens = {screen1: screen1}
	assertEquals(screen1, widget.getScreen("screen1"));
}

public function testCreateScreen():void{
	assertEquals(null, widget.getScreen("screen2"));
	assertEquals(null, widget.getScreen("screen3"));
	
	widget.createScreens("screen2", "screen3");

	
	assertNotNull(widget.getScreen("screen2"));
	assertNotNull(widget.getScreen("screen3"));
	assertTrue(widget.contains(widget.getScreen("screen2")));
	assertTrue(widget.contains(widget.getScreen("screen3")));
}

public function testDestroyScreen():void{
	widget.createScreens("screen4");
	assertNotNull(widget.getScreen("screen4"));
	
	widget.destroyScreen("screen4");
	
	assertNull(widget.getScreen("screen4"));
}

public function testShowScreens():void{
	widget.createScreens("screen_a","screen_b");
	assertTrue(widget.getScreen("screen_a").visible);
	assertTrue(widget.getScreen("screen_b").visible);
	
	widget.showScreens("screen_a");
	assertTrue(widget.getScreen("screen_a").visible);
	assertFalse(widget.getScreen("screen_b").visible);
	
	widget.showScreens("screen_b");
	assertTrue(widget.getScreen("screen_b").visible);
	assertFalse(widget.getScreen("screen_a").visible);
}

public function testRecreateScreen():void{
	widget.createScreens("screen_c");
	assertNull(widget.getScreen("screen_a"));
	assertNull(widget.getScreen("screen_b"));
	assertNotNull(widget.getScreen("screen_c"));
}

