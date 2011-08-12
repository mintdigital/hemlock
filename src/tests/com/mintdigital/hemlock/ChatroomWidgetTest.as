import com.mintdigital.hemlock.data.JID;
import com.mintdigital.hemlock.data.Message;
import com.mintdigital.hemlock.display.HemlockSprite;
import com.mintdigital.hemlock.events.AppEvent;
import com.mintdigital.hemlock.events.HemlockDispatcher;
import com.mintdigital.hemlock.events.PresenceEvent;
import com.mintdigital.hemlock.widgets.chatroom.*;

import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.ui.Keyboard; 
import flash.events.TextEvent;

	
private var dispatcher:HemlockDispatcher;
private var widget:ChatroomWidget;
private var	parent:PartialHemlockContainerMock;

override public function setUp():void {	
	dispatcher = HemlockDispatcher.getInstance();
	parent = new PartialHemlockContainerMock();
	widget = new ChatroomWidget(parent);
	
	var client_mock:MockXMPPClient = new MockXMPPClient();    
    parent.client = client_mock; 
}

public function testShouldHaveEventsAndViewsDelegates():void {
	assertTrue(widget.delegates.events is ChatroomWidgetEvents);
	assertTrue(widget.delegates.views is ChatroomWidgetViews);
}

// test for external events
	
public function testOnChatMessageShouldDispayChatMessage():void {
	assertFalse(widget.views.room.htmlText.indexOf('test of text') > 0);

	dispatcher.dispatchEvent(new AppEvent(AppEvent.CHAT_MESSAGE, {
		xmppMessage: new Message({
			body: "test of text"
		})
	}));
	assertTrue(widget.views.room.htmlText.indexOf('test of text') > 0);
}

public function testOnUserJoinShouldDispayThisEntrance():void {
	assertFalse(widget.views.room.htmlText.indexOf('test_user has entered the room') > 0);
	
	dispatcher.dispatchEvent(new AppEvent(AppEvent.ROOM_USER_JOIN, {
		from: new JID(widget.bareJID+"/test_user")
	}));
	assertTrue(widget.views.room.htmlText.indexOf('test_user has entered the room') > 0);
}

public function testOnUserJoinOtherRoomShouldNotDispayThisEntrance():void {
	assertFalse(widget.views.room.htmlText.indexOf('test_user has entered the room') > 0);
	
	dispatcher.dispatchEvent(new AppEvent(AppEvent.ROOM_USER_JOIN, {
		from: new JID("some@other.room/test_user")
	}));
	assertFalse(widget.views.room.htmlText.indexOf('test_user has entered the room') > 0);
}

public function testChatroomStatusShouldDisplayTheMessage():void {
	assertFalse(widget.views.room.htmlText.indexOf('hello, this is status message') > 0);
	
	dispatcher.dispatchEvent(new AppEvent(AppEvent.CHATROOM_STATUS, {
		message: "hello, this is status message"
	}));
	assertTrue(widget.views.room.htmlText.indexOf('hello, this is status message') > 0);
}

public function testOnRoomUserLeaveShouldDisplayTheMessage():void {
	assertFalse(widget.views.room.htmlText.indexOf('test_user has left the room') > 0);
	
	dispatcher.dispatchEvent(new AppEvent(AppEvent.ROOM_USER_LEAVE, {
		from: new JID(widget.bareJID+"/test_user")
	}));
	assertTrue(widget.views.room.htmlText.indexOf('test_user has left the room') > 0);
}

public function testOnPresenceAvailableShouldDisplayMessageAndAddUserToTheRoster():void {
	assertNull(widget.roster.pop());
	
	dispatcher.dispatchEvent(new AppEvent(AppEvent.PRESENCE_UPDATE, {
		presenceFrom: new JID(widget.bareJID+"/test_user"),
		status: 'available'
	}));
	assertEquals('test_user',widget.roster.pop().nickname);
	assertTrue(widget.views.room.htmlText.indexOf('test_user is now available') > 0);
}

public function testOnPresenceOfflineShouldDisplayMessageAndRemoveUserFromRoster():void {

	assertNull(widget.roster.pop());
	dispatcher.dispatchEvent(new AppEvent(AppEvent.PRESENCE_UPDATE, {
		presenceFrom: new JID(widget.bareJID+"/test_user"),
		status: 'available'
	}));
	assertEquals('test_user',widget.roster.pop().nickname);

	dispatcher.dispatchEvent(new AppEvent(AppEvent.PRESENCE_UPDATE, {
		presenceFrom:   new JID(widget.bareJID+"/test_user"),
		presenceType:   PresenceEvent.STATUS_OFFLINE,
		status: 'unavailable'
	}));

	assertTrue(widget.views.room.htmlText.indexOf('test_user is now offline') > 0);
	assertNull(widget.roster.pop());
}

// test for internal events handler

/*widget.registerListener(views.messageInput, KeyboardEvent.KEY_DOWN, onMessageInput);
widget.registerListener(views.messageButton, MouseEvent.CLICK, onMessageButton);
widget.registerListener(views.room, TextEvent.LINK, onLinkEvent);*/

public function testEnterKeyShouldSendAMessage():void {
	parent.expects("sendMessage").withArgs(widget.bareJID,"test message");

	widget.views.messageInput.value = "test message";
	var ev:KeyboardEvent = new KeyboardEvent(KeyboardEvent.KEY_DOWN);
	ev.keyCode = Keyboard.ENTER;
	widget.views.messageInput.dispatchEvent(ev);
	
	parent.verify();
	assertNull(parent.errorMessage());
}

public function testMouseClickShouldSendAMessage():void {
	parent.expects("sendMessage").withArgs(widget.bareJID,"test message");

	widget.views.messageInput.value = "test message";
	widget.views.messageButton.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
	
	parent.verify();
	assertNull(parent.errorMessage());
}

public function testShouldLeaveRoomOnClickingLink():void {
	parent.expects("leaveRoom").times(1);

	widget.views.room.dispatchEvent(new TextEvent(TextEvent.LINK));
	
	parent.verify();
	assertNull(parent.errorMessage());
}



