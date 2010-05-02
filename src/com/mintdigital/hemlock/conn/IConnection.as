package com.mintdigital.hemlock.conn{
    import com.mintdigital.hemlock.Logger;
    import com.mintdigital.hemlock.data.JID;

    import org.jivesoftware.xiff.data.IQ;
    import org.jivesoftware.xiff.data.XMPPStanza;
    import org.jivesoftware.xiff.util.SocketDataEvent;

    import flash.events.Event;
    import flash.events.IEventDispatcher;
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;
    import flash.xml.XMLNode;

    public interface IConnection extends IEventDispatcher{
        function connect():Boolean;
        function disconnect():Boolean;
        function send(data:*):void;
        function sendKeepAlive():void;
        function sendOpenStreamTag():void;
        function sendStanza(stanza:XMPPStanza):void;

        //--------------------------------------
        //  Event dispatchers
        //--------------------------------------

        function handleRegisterResponse(packet:IQ):void;
        // function handleIQ(node:XMLNode):void;

        //--------------------------------------
        //  Events > Handlers
        //--------------------------------------

        // function onSocketConnected(ev:Event):void;
        // function onDataReceived(ev:SocketDataEvent):void;
        // function onSocketClosed(ev:Event):void;
        // function onIOError(ev:IOErrorEvent):void;
        // function onSecurityError(ev:SecurityErrorEvent):void;

        //--------------------------------------
        //  Internal helpers
        //--------------------------------------

        // function openStreamTag():String;
        // function closeStreamTag():String;

        //--------------------------------------
        //  Properties
        //--------------------------------------

        function get port():Number;
        function set port(value:Number):void;

        function get ports():Array;
        function set ports(value:Array):void;

        function get server():String;
        function set server(value:String):void;
    }
}
