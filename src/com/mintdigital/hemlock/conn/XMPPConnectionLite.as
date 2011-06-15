package com.mintdigital.hemlock.conn {
    import com.mintdigital.hemlock.HemlockEnvironment;
    import com.mintdigital.hemlock.Logger;
    import com.mintdigital.hemlock.clients.XMPPClient;
    import com.mintdigital.hemlock.data.JID;
    import com.mintdigital.hemlock.data.Message;
    import com.mintdigital.hemlock.data.Presence;
    import com.mintdigital.hemlock.events.ChallengeEvent;
    import com.mintdigital.hemlock.events.ConnectionEvent;
    import com.mintdigital.hemlock.events.FeaturesEvent;
    import com.mintdigital.hemlock.events.MessageEvent;
    import com.mintdigital.hemlock.events.PresenceEvent;
    import com.mintdigital.hemlock.events.RegistrationEvent;
    import com.mintdigital.hemlock.events.SessionEvent;
    import com.mintdigital.hemlock.events.StreamEvent;
    import com.mintdigital.hemlock.events.XMPPEvent;

    import org.jivesoftware.xiff.data.IQ;
    import org.jivesoftware.xiff.data.XMPPStanza;
    import org.jivesoftware.xiff.events.ConnectionSuccessEvent;
    import org.jivesoftware.xiff.exception.SerializationException;
    import org.jivesoftware.xiff.util.SocketConn;
    import org.jivesoftware.xiff.util.SocketDataEvent;

    import flash.errors.IOError;
    import flash.events.ProgressEvent;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;
    import flash.system.Security;
    import flash.xml.XMLDocument;
    import flash.xml.XMLNode;
    
    public class XMPPConnectionLite extends EventDispatcher implements IConnection{
        
        protected var _socket : SocketConn;
        protected var _incompleteRawXML : String;
        protected var _server : String;
        protected var _port : Number;
        protected var _ports : Array;
        protected var _policyPort:Number;
        protected var _active : Boolean;
        protected var _loggedIn : Boolean;
        protected var _pendingIQs : Object;
        protected var _currentPort : Number;
        protected var _passThroughMode : Boolean;

        public function XMPPConnectionLite(args:Object){
            _server     = args.server || HemlockEnvironment.SERVER;
            _policyPort = args.policyPort || HemlockEnvironment.POLICY_PORT;
            Security.loadPolicyFile(
                'xmlsocket://' + _server + ':' + _policyPort);

            super();
            
            _socket = new SocketConn();
            _socket.addEventListener(Event.CLOSE, onSocketClosed);
            _socket.addEventListener(Event.CONNECT, onSocketConnected);
            _socket.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
            _socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR,
                                        onSecurityError);
            _socket.addEventListener(SocketDataEvent.SOCKET_DATA_RECEIVED,
                                        onDataReceived);
            _currentPort = 0; // Index in `ports`
            ports = HemlockEnvironment.SERVER_PORTS;
        }
        
        public function connect() : Boolean {
            _active = false;
            _loggedIn = false;
            _incompleteRawXML = '';
            _pendingIQs = new Object();
            
            _socket.connect(server, ports[_currentPort]);
            Logger.debug('XMPPConnectionLite::connect : socket = ' + _socket);
            
            return true;
        }
        
        public function disconnect() : Boolean {
            Logger.debug("XMPPConnectionLite::disconnect()");
            _active = false;
            _loggedIn = false;
            dispatchEvent(new ConnectionEvent(ConnectionEvent.DESTROY));
            return true;
        }
        
        public function send(data:*) : void {
            Logger.debug('Sending to socket: ' + data);
            _socket.sendString(data);
        }
        
        public function sendKeepAlive():void
        {
            if( _active ) {
                _socket.sendString(" ");
            }
        }
        
        public function sendOpenStreamTag() : void {
            Logger.debug("XMPPConnectionLite::sendOpenStreamTag()");
            send( openStreamTag() );
        }
        
        public function sendStanza( stanza:XMPPStanza ):void
        {
            Logger.debug("XMPPConnectionLite::sendStanza()");
            if ( _active ) {
                if ( stanza is IQ ) {
                    var iq:IQ = stanza as IQ;
                    if ( ( iq.callback != null ) || ( iq.callbackName != null && iq.callbackScope != null ) ) {
            	        _pendingIQs[iq.id] = {methodName:iq.callbackName, methodScope:iq.callbackScope, func:iq.callback};
                    }
                }
                var root:XMLNode = stanza.getNode().parentNode;
                if ( root == null ) {
                    root = new XMLDocument();
                }
                 if ( stanza.serialize( root ) ) {
                    send( root.firstChild );
                } else {
                    throw new SerializationException();
                }
            }
        }
        
        //--------------------------------------
        //  Event dispatchers
        //--------------------------------------

        private function handleRawData(rawXML:String):void{
            Logger.debug('XMPPConnectionLite::handleRawData()');
            dispatchEvent(new XMPPEvent(XMPPEvent.RAW_XML, {
                rawXML: rawXML
            }));
        }

        private function handleStreamStart(node:XMLNode):void{
            Logger.debug('XMPPConnectionLite::handleStreamStart()');
            dispatchEvent(new StreamEvent(StreamEvent.START, {
                bubbles:    true,
                cancelable: true,
                connection: this,
                node:       node
            }));
        }
        
        private function handleStreamError(node:XMLNode):void{
            Logger.debug('XMPPConnectionLite::handleStreamError()');
            dispatchEvent(new StreamEvent(StreamEvent.ERROR, {
                bubbles:    true,
                cancelable: true,
                connection: this
            }));
        }

        private function handlePresence(node:XMLNode):void{
            Logger.debug('XMPPConnectionLite::handlePresence() ' + node);
            var presence:Presence = new Presence();
            
            if (!presence.deserialize(node)){
                throw new SerializationException();
            }
            dispatchEvent(new PresenceEvent(PresenceEvent.UPDATE, {
                presence: presence
            }));
        }

        private function handleChallenge(node:XMLNode) : void {
            Logger.debug('XMPPConnectionLite::handleChallenge()');
            dispatchEvent(new ChallengeEvent(ChallengeEvent.CHALLENGE, {
                bubbles:    true,
                cancelable: true,
                connection: this,
                node:       node
            }));
        }
        
        public function handleRegisterResponse(packet:IQ):void {
            Logger.debug("XMPPConnectionLite::handleRegisterResponse()");
            dispatchEvent(new RegistrationEvent(RegistrationEvent.REGISTERING, {
                iq: packet
            }));
        }

        private function handleSuccess() : void {
            Logger.debug("XMPPConnectionLite::handleSuccess()");
            dispatchEvent(new SessionEvent(SessionEvent.CREATE_SUCCESS));
        }
        
        private function handleFailure(node:XMLNode) : void {
            Logger.debug("XMPPConnectionLite::handleFailure()");
            for ( var i:int = 0; i < node.childNodes.length; i++ ) {
                Logger.debug("Failure message: " + node.childNodes[i].nodeName);
            };
            dispatchEvent(new SessionEvent(SessionEvent.CREATE_FAILURE));
        }
        
        private function handleFeatures(node:XMLNode) : void {
            Logger.debug('XMPPConnectionLite::handleFeatures()');
            dispatchEvent(new FeaturesEvent(FeaturesEvent.FEATURES, {
                bubbles:    true,
                cancelable: true,
                connection: this,
                node:       node
            }));
        }
        
        protected function handleIQ(node:XMLNode):void{
            var iq:IQ = new IQ();
            if( !iq.deserialize( node ) ) {
                throw new SerializationException();
            }
            // handle error
            if( iq.type == IQ.ERROR_TYPE && !_pendingIQs[iq.id] ) {
                Logger.debug("XMPPConnectionLite::handleIQ() : ERROR, no registered id:" + iq.id );
            }
            else {
                // check if a callback exists for this iq
                if ( _pendingIQs[iq.id] !== undefined ) {
                    var callbackInfo:* = _pendingIQs[iq.id];
                    if ( callbackInfo.methodScope && callbackInfo.methodName ) {
                        callbackInfo.methodScope[callbackInfo.methodName].apply( callbackInfo.methodScope, [iq] );
                    }
                    if (callbackInfo.func != null) { 
                        callbackInfo.func( iq );
                    }
                    _pendingIQs[iq.id] = null;
                    delete _pendingIQs[iq.id];
                }
                else {
                    Logger.debug("XMPPConnectionLite::handleIQ() : no registered callback for " + iq.id );
                }
            }
        }
        
        
        
        //--------------------------------------
        //  Events > Handlers
        //--------------------------------------
        
        protected function onSocketConnected(ev:Event):void {
            Logger.debug("XMPPConnectionLite::onSocketConnected()" );
            _active = true;
            port = ports[_currentPort];
            send( openStreamTag() );
            dispatchEvent( new ConnectionSuccessEvent() );
        }

        protected function onDataReceived(ev:SocketDataEvent) : void {
            var rawXML:String = _incompleteRawXML + ev.data as String;
            
            Logger.debug('RAW INCOMING XML: ' + rawXML);
            
            if (containsClosedStreamTag(rawXML)){
                Logger.debug('... closed stream tag');
                // TODO: Check for <stream:error> if duplicate login
                // - If dup login, pass error string to disconnect()
                // - Error string should propagate to container, which should recognize it and change to a user-friendly explanation
                /*
                <stream:error>
                    <conflict xmlns='urn:ietf:params:xml:ns:xmpp-streams'/>
                    <text xml:lang='' xmlns='urn:ietf:params:xml:ns:xmpp-streams'>Replaced by new connection</text>
                </stream:error>
                */
                disconnect();
                _socket.close();
                return;
            }
            
            if (containsOpenStreamTag(rawXML)){
                rawXML = rawXML.concat(closeStreamTag());
            }

            var xmlData:XMLDocument = stringToXML(rawXML,ev);
            if(xmlData == null){ return; }

            if(_passThroughMode){
                handleRawData(rawXML);
                return;
            }

            for (var i:int = 0; i < xmlData.childNodes.length; i++){
                var node:XMLNode = xmlData.childNodes[i];
                Logger.debug("... handling " + node.nodeName);
                switch (node.nodeName.toLowerCase()){
                    case "stream:stream":
                        handleStreamStart(node);
                        break;
                    case 'stream:error':
                        handleStreamError(node);
                        break;
                    case 'stream:features':
                        handleFeatures(node);
                        break;
                    case "challenge":
                        handleChallenge(node);
                        break;
                    case "success":
                        handleSuccess();
                        break;
                    case "failure":
                        handleFailure(node);
                        break;
                    case 'presence':
                        handlePresence(node);
                        break;
                    case 'iq':
                        handleIQ(node);
                        break;
                    default:
                        break;
                }
            }
        }
        
        protected function onSocketClosed(ev:Event):void{
            Logger.debug('XMPPConnectionLite::onSocketClosed()');
            disconnect();
        }
        
        protected function onIOError(ev:IOErrorEvent):void{
            Logger.debug('XMPPConnectionLite::onIOError() : ' + ev.text);
            dispatchEvent(ev);
        }
        
        protected function onSecurityError(ev:SecurityErrorEvent):void{
            Logger.debug('XMPPConnectionLite::onSecurityError() : ' + ev.text);

            _active = false;
            _loggedIn = false;
            _currentPort++; // Try next supported port, if any
            if(ports[_currentPort]){
                connect();
            }else{
                dispatchEvent(ev);
            } 
        }
        
        
        //--------------------------------------
        //  Internal helpers
        //--------------------------------------        
        
        private function stringToXML(rawXML:String, ev:SocketDataEvent) : XMLDocument {
            var xmlData:XMLDocument = new XMLDocument();
            xmlData.ignoreWhite = true;
            try {
                Logger.debug('... trying to parse: ' + rawXML);
                xmlData.parseXML(rawXML);
                _incompleteRawXML = '';
            } catch (e:Error) {
                _incompleteRawXML += ev.data as String;
                return null;
            }
            return xmlData;
        }
        
        private function containsOpenStreamTag(xml:String) : Boolean {
            var openStreamRegex:RegExp = new RegExp("<stream:stream");
            var resultObj:Object = openStreamRegex.exec(xml);
            return (resultObj != null);
        }
        
        private function containsClosedStreamTag(xml:String) : Boolean {
            var closeStreamRegex:RegExp = new RegExp("<\/stream:stream");
            var resultObj:Object = closeStreamRegex.exec(xml);
            return (resultObj != null);
        }

        protected function openStreamTag() : String {
            return "<?xml version=\"1.0\"?><stream:stream to=\"" + server + 
                "\" xmlns=\"jabber:client\" xmlns:stream=\"http://etherx.jabber.org/streams\" version=\"1.0\">";
        }
        
        protected function closeStreamTag() : String {
            return "</stream:stream>";
        }



        //--------------------------------------
        //  Properties
        //--------------------------------------
        
        public function get port():Number               { return _port; }
        public function set port(value:Number):void     { _port = value; }
        
        public function get ports():Array               { return _ports; }
        public function set ports(value:Array):void     { _ports = value; }        

        public function get policyPort():Number             { return _policyPort; }
        public function set policyPort(value:Number):void   { _policyPort = value; }

        public function get server():String             { return _server; }
        public function set server(value:String):void   { _server = value; }
            // TODO: Rename to `host`

        public function get passThroughMode():Boolean
            { return _passThroughMode; }
        public function set passThroughMode(value:Boolean):void
            { _passThroughMode = value; }
        
    } 
}
