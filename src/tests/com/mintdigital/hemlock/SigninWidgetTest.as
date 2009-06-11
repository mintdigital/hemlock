import com.mintdigital.hemlock.events.HemlockDispatcher;
import com.mintdigital.hemlock.events.AppEvent;
import com.mintdigital.hemlock.widgets.signin.*;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.ui.Keyboard; 

	
private var dispatcher:HemlockDispatcher;
private var widget:SigninWidget;
private var	parent:PartialHemlockContainerMock;

override public function setUp():void {	
	dispatcher = HemlockDispatcher.getInstance();
	parent = new PartialHemlockContainerMock();
	widget = new SigninWidget(parent);
	
	var client_mock:MockXMPPClient = new MockXMPPClient();    
    parent.client = client_mock; 
}

public function testShouldHaveEventsAndViewsDelegates():void {
	assertTrue(widget.delegates.events is SigninWidgetEvents);
	assertTrue(widget.delegates.views is SigninWidgetViews);
}

// test for external events
	
public function testOnSessionCreateSuccessShouldClearForm():void {

	widget.views.signInButton.disable({ label: 'Signing in...' });
	widget.views.username.value = 'username'
	widget.views.password.value = 'password'
	
	dispatcher.dispatchEvent(new AppEvent(AppEvent.SESSION_CREATE_SUCCESS));
	
	assertEquals('',widget.views.username.value);
	assertEquals('',widget.views.password.value);
	assertFalse(widget.views.signInButton.disabled);
}

public function testOnSessionCreateFailureShouldClearFormAndCreatePopup():void {

	widget.views.signInButton.disable({ label: 'Signing in...' });
	widget.views.registerButton.disable({ label: 'Registering' });
	widget.views.username.value = 'username'
	widget.views.password.value = 'password'
		
	dispatcher.dispatchEvent(new AppEvent(AppEvent.SESSION_CREATE_FAILURE));
	
	assertEquals('username',widget.views.username.value);
	assertEquals('',widget.views.password.value);
	assertFalse(widget.views.signInButton.disabled);
	assertFalse(widget.views.registerButton.disabled);
}
