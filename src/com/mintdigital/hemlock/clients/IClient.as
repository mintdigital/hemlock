package com.mintdigital.hemlock.clients{
    import com.mintdigital.hemlock.Logger;
    import com.mintdigital.hemlock.data.JID;

    import org.jivesoftware.xiff.data.IQ;

    import flash.events.Event;
    import flash.utils.ByteArray;

    public interface IClient {
        function start() : void;
        function connect() : void;
        function addEventStrategies(strategies:Array) : void;
        function logout():void;
        function createRoom(roomType:String, domain:String, key:String=null):void;
        function createChatRoom(roomType:String, domain:String, key:String=null):void; // TODO: Remove; deprecated
        function joinRoom(roomJID:JID):void;
        function joinChatRoom(roomJID:JID):void; // TODO: Remove; deprecated
        function leaveRoom(roomJID:JID):void;
        function leaveChatRoom(roomJID:JID):void; // TODO: Remove; deprecated
        function configureRoom(roomJID:JID, configOptions:Object=null):void;
        function configureChatRoom(roomJID:JID, configOptions:Object=null):void; // TODO: Remove; deprecated
        function updateItem(roomJID:JID, updating:JID, opts:Object=null):void;
        function sendMessage(toJID:JID, messageBody:String) : void;
        function sendDataMessage(toJID:JID, payloadType:String, payload:*=null) : void;
        function sendDirectDataMessage(toJID:JID, payloadType:String, payload:*=null) : void;
        function sendPresence(toJID:JID, options:Object) : void;
        function get username() : String;
        function set username( arg:String ) : void;
        function get password() : String;
        function set password( arg:String ) : void;
        function get avatar() : ByteArray ;
        function get server() : String ;
        function set server( arg:String ) : void ;
        function get registering() : Boolean ;
        function set registering( arg:Boolean ) : void ;
        function get jid() : JID;
        function handleSessionResponse(packet:IQ):void;
        function handleBindResponse(packet:IQ) : void;
        function handleRoomDisco(packet:IQ):void;
        function handleUserDisco(packet:IQ):void;
        function handleRoleUpdate(packet:IQ):void;
        function discoRooms():void;
        function discoChatRooms():void; // TODO: Remove; deprecated
        function discoUsers(toJID:JID):void;
        function updatePrivacyList(fromJID:JID, stanzaName:String, action:String, options:Object = null):void;
    }
}
