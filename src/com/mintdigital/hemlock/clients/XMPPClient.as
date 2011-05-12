package com.mintdigital.hemlock.clients{
    import com.mintdigital.hemlock.HemlockEnvironment;
    import com.mintdigital.hemlock.Logger;
    import com.mintdigital.hemlock.auth.Registration;
    import com.mintdigital.hemlock.auth.SASLAnonymousAuth;
    import com.mintdigital.hemlock.auth.SASLAuth;
    import com.mintdigital.hemlock.auth.SASLMD5Auth;
    import com.mintdigital.hemlock.auth.SASLPlainAuth;
    import com.mintdigital.hemlock.clients.IClient;
    import com.mintdigital.hemlock.conn.XMPPConnection;
    import com.mintdigital.hemlock.data.DataMessage;
    import com.mintdigital.hemlock.data.JID;
    import com.mintdigital.hemlock.data.Message;
    import com.mintdigital.hemlock.data.Presence;
    import com.mintdigital.hemlock.data.PrivacyListExtension;
    import com.mintdigital.hemlock.data.bind.BindExtension;
    import com.mintdigital.hemlock.data.disco.InfoDiscoExtension;
    import com.mintdigital.hemlock.data.register.RegisterExtension;
    import com.mintdigital.hemlock.events.AppEvent;
    import com.mintdigital.hemlock.events.ConnectionEvent;
    import com.mintdigital.hemlock.events.FeaturesEvent;
    import com.mintdigital.hemlock.events.HemlockDispatcher;
    import com.mintdigital.hemlock.events.HemlockEvent;
    import com.mintdigital.hemlock.events.MessageEvent;
    import com.mintdigital.hemlock.events.PresenceEvent;
    import com.mintdigital.hemlock.events.RegistrationEvent;
    import com.mintdigital.hemlock.events.SessionEvent;
    import com.mintdigital.hemlock.events.StreamEvent;
    import com.mintdigital.hemlock.events.VCardEvent;
    import com.mintdigital.hemlock.utils.HashUtils;
    import com.mintdigital.hemlock.vcard.VCard;

    import com.dynamicflash.util.Base64;

    import org.jivesoftware.xiff.data.ExtensionClassRegistry;
    import org.jivesoftware.xiff.data.forms.FormExtension;
    import org.jivesoftware.xiff.data.IQ;
    import org.jivesoftware.xiff.data.disco.ItemDiscoExtension;
    import org.jivesoftware.xiff.data.muc.MUCExtension;
    import org.jivesoftware.xiff.data.muc.MUCAdminExtension
    import org.jivesoftware.xiff.data.muc.MUCOwnerExtension;
    import org.jivesoftware.xiff.data.muc.MUCUserExtension;
    import org.jivesoftware.xiff.data.session.SessionExtension;
    import org.jivesoftware.xiff.data.vcard.VCardExtension;
    import org.jivesoftware.xiff.data.XMPPStanza;

    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.TimerEvent;
    import flash.utils.ByteArray;
    import flash.utils.Timer;
    import flash.xml.XMLNode;

    public class XMPPClient implements IClient{

        private var _connection:XMPPConnection;
        private var _keepAliveTimer:Timer;
        private var _lastSent:int = 0;
        private var _username:String;
        private var _password:String;
        private var _server:String;
        private var _loggedIn:Boolean;
        private var _sessionStarted:Boolean;
        private var _jid:JID;
        private var _roomJIDs:Array = [];
        private var _registering:Boolean = false;
        private var _loggingOut:Boolean = false;
        private var _registration:Registration;
        private var _auth:SASLAuth;
        private var _vCard:VCard;
        private var _eventStrategies:Array; // of IEventStrategy implementors
        
        private const SESSION_NODE:String = 'session';

        private var _dispatcher:HemlockDispatcher;
            
        public function XMPPClient(server:String = null, username:String = null, password:String = null){
            // TODO: Convert to accept an `args` object; see XMPPClientLite

            _username = username;
            _password = password;
            _server = server;
            _loggedIn = false;
            _dispatcher = HemlockDispatcher.getInstance();

            _connection = new XMPPConnection({
                server:     server,
                policyPort: HemlockEnvironment.POLICY_PORT
            });
            
            _connection.addEventListener(Event.CLOSE,                   onSocketClosed);
            _connection.addEventListener(ConnectionEvent.DESTROY,       onConnectionDestroy);
            _connection.addEventListener(FeaturesEvent.FEATURES,        onFeatures);
            _connection.addEventListener(IOErrorEvent.IO_ERROR,         onIOError);
            _connection.addEventListener(MessageEvent.CHAT_MESSAGE,     onMessageEvent);
            _connection.addEventListener(PresenceEvent.UPDATE,          onPresenceUpdate);
            _connection.addEventListener(RegistrationEvent.COMPLETE,    onRegistrationComplete);
            _connection.addEventListener(RegistrationEvent.ERRORS,      onRegistrationErrors);
            _connection.addEventListener(SessionEvent.CREATE_SUCCESS,   onSessionCreateSuccess);
            _connection.addEventListener(SessionEvent.CREATE_FAILURE,   onSessionCreateFailure);
            _connection.addEventListener(SessionEvent.DESTROY,          onSessionDestroy);
            _connection.addEventListener(StreamEvent.ERROR,             onStreamError);
            _connection.addEventListener(StreamEvent.START,             onStreamStart);
            
            ExtensionClassRegistry.register(BindExtension);
            ExtensionClassRegistry.register(RegisterExtension);
            ExtensionClassRegistry.register(VCardExtension);
            ExtensionClassRegistry.register(InfoDiscoExtension);
            ExtensionClassRegistry.register(ItemDiscoExtension);
            ExtensionClassRegistry.register(FormExtension);
            ExtensionClassRegistry.register(MUCExtension);
            ExtensionClassRegistry.register(MUCAdminExtension);
            ExtensionClassRegistry.register(MUCUserExtension);
            ExtensionClassRegistry.register(MUCOwnerExtension);
        }
        
        public function start() : void {
            _connection.connect();
            resetKeepAliveTimer();
        }
        
        public function connect():void {
            if(!server){
                server = HemlockEnvironment.SERVER;
            }
            start();
        }
        
        public function addEventStrategies(strategies:Array):void{
            // Adds the array `strategies` to the start of _eventStrategies
            // stack, which allows the given strategies to take precedence
            // over the existing ones.
            
            if(!_eventStrategies){ _eventStrategies = []; }
            _eventStrategies = strategies.concat(_eventStrategies);
        }
        
        public function logout():void {
            Logger.debug("XMPPClient::logout()");
            
            if(_loggingOut){ return; }
            _loggingOut = true;
            
            if (_roomJIDs.length > 1) {
                var roomJIDString:String;
                var roomJID:JID;
                for each(roomJIDString in _roomJIDs) {
                    roomJID = new JID(roomJIDString);
                    if (roomJID.node != SESSION_NODE) {
                        leaveRoom(roomJID);
                    }
                }
            } else {
                disconnect();
            }
        }
        
        private function disconnect():void {
            Logger.debug("XMPPClient::disconnect()");
            
            _auth.stop();
            _keepAliveTimer.stop();
            _connection.disconnect();
            _loggedIn = false;
            _loggingOut = false;
        }
        
        public function createRoom(roomType:String, domain:String, key:String = null):void{
            Logger.debug('XMPPClient::createRoom()');

            var presence:Presence = new Presence(newRoomJID(roomType, domain, key), _jid),
                mucExtension:MUCExtension = new MUCExtension();
            mucExtension.maxchars = 0; // Request no history
            presence.addExtension(mucExtension);
            _connection.sendStanza(presence);
        }

        public function joinRoom(roomJID:JID):void{
            Logger.debug('XMPPClient::joinRoom() : roomJID = ' + roomJID);

            var presence:Presence = new Presence(roomJID, _jid),
                mucExtension:MUCExtension = new MUCExtension();
            mucExtension.maxchars = 0; // Request no history
                // http://xmpp.org/extensions/xep-0045.html#example-37
            presence.addExtension(mucExtension);
            _connection.sendStanza(presence);
        }

        public function leaveRoom(roomJID:JID):void{
            Logger.debug('XMPPClient::leaveRoom() : roomJID = ' + roomJID);
            
            var presence:Presence = new Presence(roomJID, _jid, Presence.UNAVAILABLE_TYPE);
            _connection.sendStanza(presence);
        }

        public function updateItem(roomJID:JID, updating:JID, opts:Object=null):void {
            Logger.debug("XMPPClient::updateAffiliation()");
            
            var options:Object = opts || {};
            var iq:IQ = new IQ(new JID(roomJID.toBareJID()), IQ.SET_TYPE);
            var adminExtension:MUCAdminExtension = new MUCAdminExtension();
            
            adminExtension.addItem(options.affiliation, options.role, options.nickname, updating);
            
            iq.addExtension(adminExtension);
            iq.callbackName = "handleItemUpdate";
            iq.callbackScope = this;
            
            _connection.sendStanza(iq);
        }
        
        public function configureRoom(roomJID:JID, configOptions:Object = null):void{
            Logger.debug('XMPPClient::configureRoom() : roomJID = ' + roomJID);
            
            var configIQ:IQ = new IQ(new JID(roomJID.toBareJID()), IQ.SET_TYPE);
            var userExt:MUCOwnerExtension = new MUCOwnerExtension();
            configIQ.addExtension(userExt);
            
            var formExt:FormExtension = new FormExtension();            
            formExt.setFields(configOptions || {});
            formExt.type = 'submit';
            userExt.addExtension(formExt);
            
            configIQ.callbackName = "handleCustomConfigResponse";
            configIQ.callbackScope = this;

            _connection.sendStanza(configIQ);
        }

        public function discoRooms():void{
            Logger.debug('XMPPClient::discoRooms()');
            
            var discoIQ:IQ = new IQ(domainJID, IQ.GET_TYPE);
            
            discoIQ.addExtension(new ItemDiscoExtension());
            discoIQ.callbackName = "handleRoomDisco";
            discoIQ.callbackScope = this;
            
            _connection.sendStanza(discoIQ);
        }

        public function discoUsers(toJID:JID):void {
            var discoIQ:IQ = new IQ(toJID, IQ.GET_TYPE);
            
            discoIQ.addExtension(new ItemDiscoExtension());
            discoIQ.callbackName = "handleUserDisco";
            discoIQ.callbackScope = this;
            
            _connection.sendStanza(discoIQ);
        }
        
        public function sendMessage(toJID:JID, messageBody:String) : void {
            var message:Message = new Message({
                recipient:  toJID,
                body:       messageBody,
                type:       Message.GROUPCHAT_TYPE
            });
            _connection.sendStanza(message);
        }
        
        public function sendDataMessage(toJID:JID, payloadType:String, payload:*=null):void{
            var dataMessage:DataMessage = new DataMessage(payloadType, payload || {}, {
                recipient:  toJID,
                type:       Message.GROUPCHAT_TYPE
            });
            _connection.sendStanza(dataMessage);
        }
        
        //TODO - maybe refactor these into 1 method
        public function sendDirectDataMessage(toJID:JID, payloadType:String, payload:*=null):void{
            var dataMessage:DataMessage = new DataMessage(payloadType, payload || {}, {
                recipient:  toJID,
                type:       Message.CHAT_TYPE
            });
            _connection.sendStanza(dataMessage);
        }
        
        public function sendPresence(toJID:JID, options:Object):void{
            // Accepted options:
            // - type: One of the static Presence "_TYPE" constants
            // - show: One of the static Presence "SHOW_" constants
            // - status: Away messages, etc.
            // - priority: Number, usually 1-5
            
            Logger.debug('XMPPClient::sendPresence() : options = ' + HashUtils.toString(options));

            var presence:Presence = new Presence(
                toJID, jid, options.type, options.show, options.status, options.priority
                );
            _connection.sendStanza(presence);
        }
        
        public function sendDiscoveryRequest(toJID:JID=null):void {
            Logger.debug("XMPPClient::sendDiscoveryRequest()");

            if(!toJID){ toJID = sessionJID(); }
            sendDataMessage(toJID, AppEvent.ROOM_CONFIGURED);
        }
        
        public function updatePrivacyList(fromJID:JID, stanzaName:String, action:String, options:Object = null):void{
            // stanzaName: "message", "iq", "presence-in", or "presence-out"
            // action: "allow" or "deny"

            // Implemented according to XEP-0016.

            const LIST_NAME:String = fromJID + ':privacy_list';
            
            /*
            // Request current list
            var iq:IQ = new IQ(null, IQ.GET_TYPE);
            iq.from = fromJID;
            var extension:PrivacyListExtension = new PrivacyListExtension();
            iq.addExtension(extension);
            _connection.sendStanza(iq);
            */
            
            // Specify privacy list
            var iq:IQ = new IQ(null, IQ.SET_TYPE);
            iq.from = fromJID;
            var extension:PrivacyListExtension = new PrivacyListExtension();
            extension.setActiveListName(LIST_NAME);
            iq.addExtension(extension);
            _connection.sendStanza(iq);
            
            // Edit privacy list
            iq = new IQ(null, IQ.SET_TYPE);
            iq.from = fromJID;
            extension = new PrivacyListExtension();
            extension.createList(LIST_NAME);
            extension.addListItem({
                order:      uint(iq.id.replace('iq_', '')),
                action:     action,
                stanzaName: stanzaName
            });
            iq.addExtension(extension);
            // iq.callbackName = '';
            // iq.callbackScope = this;
            _connection.sendStanza(iq);
        }
        
        private function uniqueNode(roomType:String=null, key:String=null):String {
            return (roomType ? roomType + "_" : "") + (key ? key : timestamp);
        }
        
        private function newRoomJID(roomType:String, domain:String, key:String=null):JID {
            return new JID(uniqueNode(roomType, key) + "@" + domain + "/" + username);
        }
        
        private function sessionJID(name:String = null):JID {
            return new JID(SESSION_NODE + "@" + domain + (name ? "/" + name : ""));
        }
        
        
        
        //--------------------------------------
        //  Events > Handlers
        //--------------------------------------
        
        private function onPresenceUpdate(e:PresenceEvent):void {
            Logger.debug("XMPPClient::onPresenceUpdate()");

            if (e.options.presence.status == '201') {
                onRoomEventCreate(e);
            } else {
                var roomJID:JID = new JID(e.presence.from.toBareJID() + "/" + username);

                if (_roomJIDs.indexOf(roomJID.toString()) < 0 && e.presence.type != Presence.UNAVAILABLE_TYPE) {
                    dispatchRoomJoinEvent(e.presence, roomJID);
                } else if (e.presence.type == Presence.UNAVAILABLE_TYPE && roomJID.eq(e.presence.from)) {
                    dispatchRoomLeaveEvent(e.presence, roomJID);
                }

                dispatchAppEvent(AppEvent.PRESENCE_UPDATE, {
                    presenceFrom:       new JID(e.presence.from.toString()),
                    presenceType:       e.presence.type,
                    presenceRole:       e.presence.role,
                    presenceStatus:     e.presence.status,
                    presenceRealJID:    e.presence.realJID.toString(),
                    presenceAffiliation:e.presence.affiliation
                });            
            }
        }

        private function onRoomEventCreate(e:PresenceEvent):void {
            Logger.debug("XMPPClient::onRoomEventCreate()");
            
            var customConfigureIQ:IQ = new IQ(new JID(e.presence.from.toBareJID()), IQ.GET_TYPE);
            var userExt:MUCOwnerExtension = new MUCOwnerExtension();
            customConfigureIQ.addExtension(userExt);
    
            customConfigureIQ.callbackName  = "handleCustomConfigResponse";
            customConfigureIQ.callbackScope = this;

            _connection.sendStanza(customConfigureIQ);
        }
        
        private function onMessageEvent(ev:MessageEvent):void{
            Logger.debug('XMPPClient::onMessageEvent() : ev = ' + ev);

            for each(var strategy:* in _eventStrategies){
                if(strategy.dispatchMatchingEvent(_dispatcher, ev)){ break; }
            }
        }
        
        private function onVCardEvent(e:VCardEvent):void {
            Logger.debug("XMPPClient::onVCardEvent()");
            
            switch(e.type) {
                case VCardEvent.AVATAR_LOADED:
                    Logger.debug("- Avatar loaded");
                    break;
                case VCardEvent.SAVED:
                    Logger.debug("- VCard saved");
                    break;
                case VCardEvent.LOADED:
                    Logger.debug("- VCard loaded");
                    _vCard = e.vcard;
/*                    var s:String = "R0lGODlhDwAPAKECAAAAzMzM/////wAAACwAAAAADwAPAAACIISPeQHsrZ5ModrLlN48CXF8m2iQ3YmmKqVlRtW4MLwWACH+H09wdGltaXplZCBieSBVbGVhZCBTbWFydFNhdmVyIQAAOw=="
                    _vCard.setAvatar(s);
                    _vCard.saveVCard(_connection, this);*/
                    break;
                case VCardEvent.ERROR:
                    Logger.debug("- Errors loading VCard");
                    break;
                default:
                    break;
            }
            
            /* Saving tests...            */
/*            Logger.debug("My nickname before the save: " + _vCard.nickname);
            if (_vCard.nickname != "Schmozzleboff4") {
                Logger.debug("Trying to save.");
                _vCard.nickname = "Schmozzleboff4";
                _vCard.saveVCard(_connection, this);
                Logger.debug("My nickname after the save: " + _vCard.nickname);
            }*/
        }
        
        private function onStreamStart(event:StreamEvent) : void {
            Logger.debug('XMPPClient::onStreamStart() : loggedIn = ' + _loggedIn);
            
            if(!_loggedIn){
                if(registering){
                    register();
                }else{
                    if(event.options.node){
                        // Expected `event.options.node` structure:
                        // <stream:stream>
                        //     <stream:features>
                        //         ...
                        //     </stream:features>
                        // </stream:stream>
                        
                        // Get authentication mechanism and authenticate
                        var featuresNode:XMLNode = (function():XMLNode{
                            var node:XMLNode;
                            for each(var childNode:XMLNode in event.options.node.childNodes){
                                if(childNode.nodeName == 'stream:features'){
                                    node = childNode;
                                }
                            }
                            return node;
                        })();
                        if(featuresNode){
                            handleStreamFeaturesNode(featuresNode);
                        }
                    }
                }
            }else{
                establishSession();
            }
        }
        
        private function onStreamError(event:StreamEvent):void{
            Logger.debug('XMPPClient::onStreamError() : loggedIn = ' + _loggedIn);
            dispatchAppEvent(AppEvent.STREAM_ERROR,event.options);
        }

        private function onFeatures(event:FeaturesEvent) : void {
            Logger.debug("XMPPClient::onFeatures()");
            
            if(_loggedIn && !_sessionStarted){
                establishSession();
            }
            
            // Check for features
            if(event.options.node){
                handleStreamFeaturesNode(event.options.node);
            }
        }

        private function onSocketClosed(ev:Event):void{
            Logger.debug('XMPPClient::onSocketClosed()');
        }

        private function onIOError(ev:Event):void{
            Logger.debug('XMPPClient::onIOError()');
        }

        private function onSessionCreateSuccess(ev:SessionEvent):void{
            Logger.debug('XMPPClient::onSessionCreateSuccess()');
            _loggedIn = true;
            _connection.sendOpenStreamTag();
        }

        private function onSessionCreateFailure(ev:SessionEvent):void{
            Logger.debug('XMPPClient::onSessionCreateFailure() : ev.type = ' + ev.type);
            Logger.debug("Login FAILED");
            _auth.stop();
            _keepAliveTimer.stop();
            _connection.disconnect();
            dispatchAppEvent(AppEvent.SESSION_CREATE_FAILURE);
        }

        private function onSessionDestroy(ev:SessionEvent):void{
            dispatchAppEvent(AppEvent.SESSION_DESTROY);
        }

        private function onKeepAliveTimer(ev:Event):void{
            Logger.debug('XMPPClient::onKeepAliveTimer()');
            _connection.sendKeepAlive();
            resetKeepAliveTimer();
        }

        private function onRegistrationComplete(ev:RegistrationEvent):void{
            Logger.debug('XMPPClient::onRegistrationComplete()');
            _registering = false;
            _registration.removeEventListener(RegistrationEvent.ERRORS, onRegistrationErrors);
            _registration.removeEventListener(RegistrationEvent.COMPLETE, onRegistrationComplete);
            _registration = null;
            _connection.disconnect();
            _connection.connect();
        }
        
        private function onRegistrationErrors(ev:RegistrationEvent):void{
            Logger.debug('XMPPClient::onRegistrationErrors()');
            dispatchAppEvent(AppEvent.REGISTRATION_ERRORS);
            _registering = false;
            _keepAliveTimer.stop();
            _connection.disconnect();
        }

        private function onConnectionDestroy(ev:ConnectionEvent):void{
            dispatchAppEvent(AppEvent.CONNECTION_DESTROY);
            _keepAliveTimer.stop();
        }



        //--------------------------------------
        //  Callbacks
        //--------------------------------------

        public function handleCustomConfigResponse(packet:IQ):void {
            Logger.debug("XMPPClient::handleCustomConfigResponse()");
            
            var notifName:String;
            var notifData:Object;
            
            switch(packet.type) {
                case "result": 
                    var userExt:MUCOwnerExtension = packet.getExtension("query") as MUCOwnerExtension;
                    var formExt:FormExtension = userExt.getExtension("x") as FormExtension;
                    
                    if (formExt) {
                        notifName = AppEvent.CONFIGURATION_START;
                        notifData = {
                            from: packet.from,
                            fields: formExt.getAllFields()
                        };
                    } else {
                        notifName = AppEvent.CONFIGURATION_COMPLETE;
                        notifData = { from: packet.from };
                        
                        sendDiscoveryRequest();
                        
                        joinRoom(new JID(packet.from.toString()));
                    }
                    break;
                    
                case "error":
                    notifName = AppEvent.CONFIGURATION_ERROR;
                    notifData = { from: packet.from };
                    break;
                    
            }
            dispatchAppEvent(notifName, notifData);
        }

        public function handleSessionResponse(packet:IQ):void
        {
            Logger.debug("XMPPClient::handleSessionResponse()");
            _sessionStarted = true;
            
            dispatchAppEvent(AppEvent.SESSION_CREATE_SUCCESS, {
                from: _username,
                jid: _jid
            });
            
            dispatchAppEvent(AppEvent.PRESENCE_CREATE, {
                presenceFrom:   _jid,
                presenceType:   PresenceEvent.STATUS_AVAILABLE
            });
            
            _vCard = VCard.getVCard(_connection, this);
            _vCard.addEventListener(VCardEvent.AVATAR_LOADED, onVCardEvent);
            _vCard.addEventListener(VCardEvent.LOADED, onVCardEvent);
            _vCard.addEventListener(VCardEvent.SAVED, onVCardEvent);
            _vCard.addEventListener(VCardEvent.ERROR, onVCardEvent);
        }
    
        public function handleBindResponse(packet:IQ) : void {
            Logger.debug("XMPPClient::handleBindResponse()");

            var bindExtension:BindExtension = packet.getExtension("bind") as BindExtension;
            _jid = new JID(bindExtension.getJID());

            var sessionIQ:IQ = new IQ(null, IQ.SET_TYPE);
            sessionIQ.addExtension(new SessionExtension());
            sessionIQ.callbackName  = "handleSessionResponse";
            sessionIQ.callbackScope = this;

            _connection.sendStanza(sessionIQ);
        }
        
        public function handleRoomDisco(packet:IQ):void {
            Logger.debug("XMPPClient::handleRoomDisco()");
            
            var disco:ItemDiscoExtension = packet.getExtension("query") as ItemDiscoExtension;
            dispatchAppEvent(AppEvent.DISCOVERY_ITEMS_FOUND, {
                items: disco.items
            });
        }
        
        public function handleUserDisco(packet:IQ):void {
            Logger.debug("XMPPClient::handleUserDisco()");
            
            var disco:ItemDiscoExtension = packet.getExtension("query") as ItemDiscoExtension;
            dispatchAppEvent(AppEvent.DISCOVERY_USERS_FOUND, {
                items: disco.items
            });
        }
        
        public function handleItemUpdate(packet:IQ):void {
            Logger.debug("XMPPClient::handleItemUpdate()");
            
            switch(packet.type) {
                case 'result':
                    dispatchAppEvent(AppEvent.ITEM_UPDATE, {
                        to:     packet.to,
                        from:   packet.from
                    });
                    break;
                case 'error':
                    Logger.debug("Error trying to update item.");
                    break;
            }
        }
        
        public function handleAffiliationUpdate(packet:IQ):void {
            Logger.debug("XMPPClient::handleAffiliationUpdate()");
            
            switch(packet.type) {
                case 'result':
                    dispatchAppEvent(AppEvent.AFFILIATION_UPDATE, {
                        to:     packet.to,
                        from:   packet.from
                    });
                    break;
                case 'error':
                    Logger.debug("Error trying to update affiliation.");
                    break;
            }
        }
        
        public function handleRoleUpdate(packet:IQ):void {
            Logger.debug("XMPPClient::handleRoleUpdate()");
            
            switch(packet.type) {
                case 'result':
                    dispatchAppEvent(AppEvent.ROLE_UPDATE, {
                        to:     packet.to,
                        from:   packet.from
                    });
                    break;
                case 'error':
                    Logger.debug("Error trying to update role.");
                    break;
            }
        }
        
        //--------------------------------------
        //  Event dispatchers
        //--------------------------------------
        
        public function dispatchEvent(event:HemlockEvent):void{
            _dispatcher.dispatchEvent(event);
        }
        
        public function dispatchAppEvent(eventType:String, eventOptions:Object = null):void{
            // Convenience function for dispatching an AppEvent on the
            // dispatcher. To dispatch other types of events, use
            // dispatchEvent().
            
            Logger.debug('XMPPClient::dispatchAppEvent() : eventType = ' + eventType);
            dispatchEvent(new AppEvent(eventType, eventOptions));
        }
        
        public function notifyApp(notifType:String, notifData:Object = null):void{
            Logger.warn('DEPRECATED: XMPPClient::notifyApp(); use dispatchAppEvent() instead.');
            dispatchAppEvent(notifType, notifData);
        }
        
        private function dispatchRoomJoinEvent(presence:Presence, roomJID:JID):void {
            Logger.debug("XMPPClient::dispatchRoomJoinNotification()");

            dispatchAppEvent(AppEvent.ROOM_JOINED, {
                name:   presence.from.node,
                jid:    roomJID,
                to:     _jid,
                from:   presence.from
            });
            
            sendDiscoveryRequest();
            
            _roomJIDs.push(roomJID.toString());
        }
        
        private function dispatchRoomLeaveEvent(presence:Presence, roomJID:JID):void {
            Logger.debug("XMPPClient::dispatchRoomLeaveNotification()");

            dispatchAppEvent(AppEvent.ROOM_LEAVE, {
                jid:    roomJID,
                to:     _jid,
                from:   presence.from
            });
            
            var i:int = _roomJIDs.indexOf(roomJID.toString());
            _roomJIDs.splice(i, i + 1);
            
            sendDiscoveryRequest();
            
            if (_loggingOut && _roomJIDs.length == 1) {
                disconnect();
            }
        }
        
        
        
        //--------------------------------------
        //  Internal helpers
        //--------------------------------------
        
        private function resetKeepAliveTimer() : void {
            if(_keepAliveTimer){ _keepAliveTimer.stop(); }
            _keepAliveTimer = new Timer(15000);
            _keepAliveTimer.addEventListener(TimerEvent.TIMER, onKeepAliveTimer);
            _keepAliveTimer.start();
        }

        private function authenticate(mechanism:String):void{
            // `mechanism` should be one of the SASLAuth.MECHANISM_* constants.
            
            Logger.debug('XMPPClient::authenticate() : mechanism = ' + mechanism);
            
            switch(mechanism){
                case SASLAuth.MECHANISM_ANONYMOUS:
                    _auth = new SASLAnonymousAuth(_connection);
                    break;
                case SASLAuth.MECHANISM_PLAIN:
                    _auth = new SASLPlainAuth({
                        connection: _connection,
                        username:   username,
                        password:   password,
                        server:     server
                    });
                    break;
                default:
                    _auth = new SASLMD5Auth({
                        connection: _connection,
                        username:   username,
                        password:   password,
                        server:     server
                    });
            }

            _sessionStarted = false;
            _auth.start();
        }
        
        private function register() : void {
            Logger.debug("XMPPClient::register()");
            _registration = new Registration(_connection);
            _registration.username = _username;
            _registration.password = _password;
            
            _registration.addEventListener(RegistrationEvent.ERRORS,    onRegistrationErrors);
            _registration.addEventListener(RegistrationEvent.COMPLETE,  onRegistrationComplete);
            
            _sessionStarted = false;
            _registration.start();
        }

        private function establishSession():void{
            Logger.debug("XMPPClient::establishSession()");
            var bindIQ:IQ = new IQ(null, IQ.SET_TYPE),
                bindExtension:BindExtension = new BindExtension();
            bindExtension.resource = username || 'hemlock';

            bindIQ.addExtension(bindExtension);
            bindIQ.callbackName  = "handleBindResponse";
            bindIQ.callbackScope = this;

            _connection.sendStanza(bindIQ);
        }
        
        private function handleStreamFeaturesNode(featuresNode:XMLNode):void{
            // Expected `featuresNode` structure:
            // <stream:features>
            //     <mechanisms>
            //         <mechanism>...</mechanism>
            //         <mechanism>...</mechanism>
            //         <mechanism>...</mechanism>
            //     </mechanisms>
            // </stream:features>
            
            for each(var featureNode:XMLNode in featuresNode.childNodes){
                switch(featureNode.nodeName){
                    case 'mechanisms':
                        if(featureNode.firstChild && !_loggedIn){
                            authenticate(featureNode.firstChild.firstChild.nodeValue);
                        }
                        break;
                }
            }
        }
        
        
        
        //--------------------------------------
        //  Properties
        //--------------------------------------
        
        public function get username():String           { return _username; }
        public function set username(value:String):void { _username = value; }
        
        public function get password():String           { return _password; }
        public function set password(value:String):void { _password = value; }

        public function get server():String             { return _server; }
        public function set server(value:String):void   { _server = value; }
            // TODO: Rename to `host`

        private function get domain():String    { return 'conference.' + server; }
            // TODO: Rename to `mucHost`

        private function get domainJID():JID    { return new JID(domain); }

        public function get registering():Boolean           { return _registering; }
        public function set registering(value:Boolean):void { _registering = value; }
        
        public function get jid():JID           { return _jid; }

        public function get avatar():ByteArray  { return _vCard.avatar; }
        
        private function get timestamp():String { return (new Date()).getTime().toString(); }
        
    } 
}
