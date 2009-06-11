package tests.com.mintdigital.mocks {
	import com.mintdigital.hemlock.Logger;
	import com.mintdigital.hemlock.containers.HemlockContainer;
    import com.mintdigital.hemlock.data.JID;
	import com.mintdigital.hemlock.events.AppEvent;
	import com.mintdigital.hemlock.HemlockEnvironment;
			
	import org.mock4as.Mock;
	
	import flash.display.DisplayObject;
	import flash.events.*

	public class PartialHemlockContainerMock extends HemlockContainer {
	  	include "../helpers/PartialMockHelper.as"

		public function PartialHemlockContainerMock() { 
			mock = new Mock();
			super();
			include '../../../../config/environment.as';
	    }
	
        override public function createSystemNotification(options:Object = null):void{
	        mock.record("createSystemNotification", options);
/*          super.createSystemNotification(options);*/

	    }
	
        override protected function onSessionCreateSuccess(ev:AppEvent):void{
	        mock.record("onSessionCreateSuccess");
			super.onSessionCreateSuccess(ev);
		}
		
		override protected function onRegistrationErrors(ev:AppEvent):void{
	        mock.record("onRegistrationErrors");
			super.onRegistrationErrors(ev);
		}
		
		override public function sendMessage(toJID:JID, messageBody:String):void{
	        mock.record("sendMessage", toJID, messageBody);
			super.sendMessage(toJID, messageBody);
		}

		override public function sendDataMessage(toJID:JID, payloadType:String, payload:*):void{
	        mock.record("sendDataMessage", toJID, payloadType, payload);
			super.sendDataMessage(toJID, payloadType, payload);
		}
		
		override public function sendPresence(toJID:JID, options:Object):void{
	        mock.record("sendPresence", toJID, options);
            super.sendPresence(toJID, options);
		}

		override public function leaveChatRoom(toJID:JID):void{
	        mock.record("leaveChatRoom", toJID);
			super.leaveChatRoom(toJID);
		}
	
		override protected function setUpStage():void{
		}	
	
	}
}