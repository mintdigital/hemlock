import com.mintdigital.hemlock.containers.HemlockContainer;
import com.mintdigital.hemlock.data.JID;
import com.mintdigital.hemlock.data.Presence;
import com.mintdigital.hemlock.events.*;
import com.mintdigital.hemlock.widgets.HemlockWidget
import tests.com.mintdigital.helpers.TestDelegateHelper;

private var mock:MockXMPPClient;
private var dispatcher:HemlockDispatcher;
private var hemlock_container:PartialHemlockContainerMock;
private var hemlock_container_partial_mock:PartialHemlockContainerMock;


override public function setUp():void {

	dispatcher = HemlockDispatcher.getInstance();
	
    hemlock_container = new PartialHemlockContainerMock();
	hemlock_container.ignoreMissingExpectations();

    mock = new MockXMPPClient();    
    hemlock_container.client = mock; 
}

public function testSendMessage():void {
    mock.expects("sendMessage").times(1).withArgs(new JID("test"), "test message"); 
		
	hemlock_container.sendMessage(new JID("test"), "test message");
	
	mock.verify();
    assertNull(mock.errorMessage());
}

public function testSendDataMessage():void {

    mock.expects("sendDataMessage").times(1).withArgs(new JID("test"), "test payload type", "test payload");

	hemlock_container.sendDataMessage(new JID("test"), "test payload type", "test payload");
	
	mock.verify();
    assertNull(mock.errorMessage());
}

public function testSendDirectMessage():void {

    mock.expects("sendDirectDataMessage").times(1).withArgs(new JID("test"), "test payload type", "test payload");

	hemlock_container.sendDirectDataMessage(new JID("test"), "test payload type", "test payload");
	
	mock.verify();
    assertNull(mock.errorMessage());
}

public function testSendPresence():void{
    mock.expects("sendPresence").times(1).withArgs(new JID("test"), {
        show:   'test show val',
        status: 'test status val'
    });

	hemlock_container.sendPresence(new JID("test"), {
	    show:   'test show val',
	    status: 'test status val'
	});
	
	mock.verify();
    assertNull(mock.errorMessage());
}


// TEST for proper delegation to client

public function testLogoutShouldBeDelegatedToClient():void{
	assertNull(
		TestDelegateHelper.shouldDelegateCall(hemlock_container, mock, "logout")
		.errorMessage()
	);
}

public function testDiscoRoomsShouldBeDelegatedToClient():void{
	assertNull(
		TestDelegateHelper.shouldDelegateCall(hemlock_container, mock, "discoRooms")
		.errorMessage()
	);
}


public function testJoinRoomShouldBeDelegatedToClient():void{
	assertNull(
		TestDelegateHelper.shouldDelegateCall(hemlock_container, mock, "joinRoom", 
		new JID("test"), 
		new JID('test/' + hemlock_container.client.username))
		.errorMessage()
	);		
}

public function testUpdatePrivacyListShouldBeDelegatedToClient():void{
	assertNull(
		TestDelegateHelper.shouldDelegateCall(hemlock_container, mock, "updatePrivacyList", 
		new Array(new JID("test"), "stanza", "action", null))
		.errorMessage()
	);
}

public function testCreateRoomShouldBeDelegatedToClient():void{
	assertNull(
		TestDelegateHelper.shouldDelegateCall(hemlock_container, mock, "createRoom", "test", new Array("test",hemlock_container.domain,null))
		.errorMessage()
		);
}

public function testLeaveRoomShouldBeDelegatedToClient():void{
	assertNull(
		TestDelegateHelper.shouldDelegateCall(hemlock_container, mock, "leaveRoom", new JID("test"))
		.errorMessage()
		);
}

public function testDiscoUsersShouldBeDelegatedToClient():void{
	assertNull(
		TestDelegateHelper.shouldDelegateCall(hemlock_container, mock, "discoUsers", new JID("test"))
		.errorMessage()
	);
}

public function testConfigureRoomShouldBeDelegatedToClient():void{
	assertNull(
		TestDelegateHelper.shouldDelegateCall(hemlock_container, mock, "configureRoom", new Array(new JID("test"),{}))
		.errorMessage()
	);
}

	
public function testSignIn():void {
	mock.expects("username").times(1).withArgs("username");
	mock.expects("password").times(1).withArgs("password");

	/* This comes from connect method */
	mock.expects("connect").times(1)
	
	hemlock_container.signIn("username", "password")

	mock.verify();
    assertNull(mock.errorMessage());
}

public function testSignUp():void {
	mock.expects("username").times(1).withArgs("username");
	mock.expects("password").times(1).withArgs("password");
	mock.expects("registering").times(1).withArgs(false);

	/* This comes from connect method */
	mock.expects("connect").times(1)
	
	hemlock_container.signUp("username", "password")

	mock.verify();
    assertNull(mock.errorMessage());
}

public function testShouldAddAllTheWidgetsAsChildren():void {
	var widgets:Object = { widget1: new HemlockWidget(hemlock_container),
				           widget2: new HemlockWidget(hemlock_container) }
				
	hemlock_container.addWidgets([widgets.widget1,widgets.widget2])
	assertEquals(widgets.widget1, hemlock_container.getChildAt(0))
	assertEquals(widgets.widget2, hemlock_container.getChildAt(1))
}


public function testContainerShouldRespondToSessionCreateSuccessEvent():void {
	containerShouldRespondToAppEvent(AppEvent.SESSION_CREATE_SUCCESS, "onSessionCreateSuccess",function(container:PartialHemlockContainerMock):void {
		var client_mock:MockXMPPClient = container.client as MockXMPPClient;
		client_mock.expects("joinRoom").times(1)
	});
}

public function testContainerShouldRespondToRegistrationErrorsEvent():void {
	containerShouldRespondToAppEvent(AppEvent.REGISTRATION_ERRORS, "onRegistrationErrors", function(container:PartialHemlockContainerMock):void {
		container.expects("createSystemNotification").withArg({
            error: "Registration failed. Please try again later."
        }).times(1)
	});
}

private function containerShouldRespondToAppEvent(event_type:String, respond_method:String, more_expectations:Function):void {
	hemlock_container.clear();
	hemlock_container.expects(respond_method).times(1);
	more_expectations(hemlock_container);
		
	dispatcher.dispatchEvent(new AppEvent(event_type));

	hemlock_container.verify();
    assertNull(hemlock_container.errorMessage());
}
