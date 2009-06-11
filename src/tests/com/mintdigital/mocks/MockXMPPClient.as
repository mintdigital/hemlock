package tests.com.mintdigital.mocks {
	import com.mintdigital.hemlock.Logger;
	import com.mintdigital.hemlock.clients.IClient;
    import com.mintdigital.hemlock.data.JID;
	import com.mintdigital.hemlock.events.HemlockDispatcher;
	
	import org.jivesoftware.xiff.data.IQ;

	import org.mock4as.Mock;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;

	public class MockXMPPClient extends Mock implements IClient {
	    private var _dispatcher:HemlockDispatcher;
	
		public function addEventStrategies(strategies:Array):void {
	        record("addEventStrategies", strategies);
	    }
        
	    public function start() : void {
	        record("start");
	    }
	    
	    public function connect() : void {
	        record("connect");
	    }
        
        public function logout():void {
		    record("logout");
		};
		
        public function leaveChatRoom(jid:JID): void {
			record("leaveChatRoom", jid);
		};

		public function joinChatRoom(jid:JID) : void {
			record("joinChatRoom", jid);
		};
		
		public function createChatRoom(roomType:String, domain:String, key:String=null):void {
			record("createChatRoom", roomType, domain, key);
		};
		
		public function configureChatRoom(toJID:JID, configOptions:Object=null):void {
			record("configureChatRoom", toJID, configOptions);
		};
	
		public function sendMessage(jid:JID, messageBody:String) : void {
			record("sendMessage", jid, messageBody);
		};
	
		public function sendDataMessage(toJID:JID, payloadType:String, payload:*=null) : void {
			record("sendDataMessage", toJID, payloadType, payload || {});
		};
		
		public function sendDirectDataMessage(toJID:JID, payloadType:String, payload:*=null) : void {
			record("sendDirectDataMessage", toJID, payloadType, payload || {});
		};
	
		public function sendPresence(roomJID:JID, options:Object) : void {
            record("sendPresence", roomJID, options);
		};
		
		public function discoChatRooms():void {
			record("discoChatRooms");
		};
		
		public function discoUsers(roomJID:JID):void {
			record("discoUsers", roomJid);
		};
		
		public function updatePrivacyList(fromJID:JID, stanzaName:String, action:String, options:Object = null):void {
			record("updatePrivacyList",fromJID, stanzaName, action, options);
		};
	
		public function get username() : String {
	        record("username");
		    return "username";
		};
	
		public function set username( arg:String ) : void {
			record("username",arg);
		};
	
		public function get password() : String {
			record("password");
		    return "password";
		};
	
		public function set password( arg:String ) : void {
			record("password",arg)
		};
	
		public function get avatar() : ByteArray  {
		    return new ByteArray;
		};
	
		public function get server() : String  {
			record("server");
		    return "string";
		};
	
		public function set server( arg:String ) : void  {
			record("server",arg);
		};

		public function dispatchEvent( event:Event ) : Boolean  {
			record("dispatchEvent",event);
			return true
		};
	
		public function get registering() : Boolean {
			record("registering");
		    return true;
		} ;
	
	    public function set registering( arg:Boolean ) : void  {
			record("registering",arg);
		};
    
		public function get jid() : JID {
		    return new JID("test");
		};
	
		public function get roomJid() : JID {
		    return new JID("test");
		};
	
		public function handleSessionResponse(packet:IQ):void {
		};
	
		public function handleBindResponse(packet:IQ) : void {
		};
		
		public function get dispatcher():HemlockDispatcher {
			return HemlockDispatcher.getInstance();
		}
		
		public function handleConfigurationResponse(packet:IQ):void {};
		public function handleRoomDisco(packet:IQ):void {};
		public function handleUserDisco(packet:IQ):void {};
	}
}