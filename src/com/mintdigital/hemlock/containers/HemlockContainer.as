package com.mintdigital.hemlock.containers{
    import com.mintdigital.hemlock.HemlockEnvironment;
    import com.mintdigital.hemlock.Logger;
    import com.mintdigital.hemlock.clients.HTTPClient;
    import com.mintdigital.hemlock.clients.IClient;
    import com.mintdigital.hemlock.clients.XMPPClient;
    import com.mintdigital.hemlock.data.JID;
    import com.mintdigital.hemlock.display.ErrorPopup;
    import com.mintdigital.hemlock.display.HemlockSprite;
    import com.mintdigital.hemlock.display.SystemNotificationManager;
    import com.mintdigital.hemlock.strategies.MessageEventStrategy;
    import com.mintdigital.hemlock.widgets.HemlockWidget;

    import com.mintdigital.hemlock.events.AppEvent;
    import com.mintdigital.hemlock.events.HemlockDispatcher;
        
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    
    public class HemlockContainer extends HemlockSprite{
        public var views:Object = {}; // Store all non-widget views (background, logos, etc.)
        protected var _room:String = JID.TYPE_SESSION;
        private var _client:IClient;
        private var _dispatcher:HemlockDispatcher;
        private var _flashvars:Object;
        private var _httpClient:HTTPClient;
        private var _jid:JID;
        private var _systemNotificationManager:SystemNotificationManager;
        private var _widgets:Object = {};
        
        public function HemlockContainer(options:Object = null){
            initialize();
            _flashvars = this.loaderInfo.parameters;
               _systemNotificationManager = new SystemNotificationManager(this, stage);

            httpClient = new HTTPClient(HemlockEnvironment.API_PATH);
            
            client = new XMPPClient();
            client.addEventStrategies([
                new MessageEventStrategy()
                // App constructors should add a strategy for each custom
                // event that is triggered by a DataMessage payload. This
                // array acts as a stack; earlier strategies take precedence.
            ]);
            
            registerListeners();
            startListeners();
        }
        
        protected function initialize():void{
            // Custom containers should override this to specify custom
            // environments, skins, and other configurations.
            
            include '../../../../config/environment.as';
        }
        
        protected function initializeStage():void{
            // Override this (call super.initializeStage() first) to add views
            // only after the stage is ready. This is useful when loading your
            // container via a loader.
            
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align     = StageAlign.TOP_LEFT;
        }

        
        
        //--------------------------------------
        //  Model helpers
        //--------------------------------------
        
        // [write your own]
        
        
        
        //--------------------------------------
        //  View helpers
        //--------------------------------------
        
        public function addWidgets(widgets:Array):void{
            // Adds widgets to stage in the order defined.
            
            // Usage:
            // 1. Create widgets in your HemlockContainer subclass:
            //    widgets = {
            //        widgetName1: hemlockWidgetSubclass,
            //        widgetName2: anotherHemlockWidgetSubclass
            //        ...
            //    };
            // 2. Add widgets in the order you choose:
            //    addWidgets([
            //        widgetName2,
            //        widgetName1
            //    ]);
            
            for each(var widget:HemlockWidget in widgets){
                addChild(widget);
                widget.registerListeners();
            }
        }
        
        public function createSystemNotification(options:Object = null):void{
            _systemNotificationManager.createNotification(options.message, options.error, options.duration);                        
        }
        
        public function createErrorPopup(text:String, options:Object = null):void{
            // To use a custom subclass of ErrorPopup, override a duplicate of
            // this function, but instantiate your own subclass instead of
            // ErrorPopup (e.g., `new com.mintdigital.myApp.display.ErrorPopup`).
            
            if(!options){ options = {}; }
            var errorPopup:ErrorPopup = new ErrorPopup(text, options);
            errorPopup.displayIn(options.parent || this);
        }
        
        
        
        //--------------------------------------
        //  Events > Initializers
        //--------------------------------------
        
        override public function registerListeners():void{
            // Register view listeners
            registerListener(this,              Event.ADDED_TO_STAGE,               onAddedToStage); // Requires Flash 9.0.28.0
            
            // Register dispatcher listeners
            registerListener(dispatcher,        AppEvent.SESSION_CREATE_SUCCESS,    onSessionCreateSuccess);
            registerListener(dispatcher,        AppEvent.REGISTRATION_ERRORS,       onRegistrationErrors);
        }
        
        
        
        //--------------------------------------
        //  Events > Standard handlers > Views
        //--------------------------------------
        
        protected function onAddedToStage(event:Event):void{
            initializeStage();
        }
        
        
        
        //--------------------------------------
        //  Events > Standard handlers > App
        //--------------------------------------
        
        protected function onEvent(event:Event):void{
            // Simply redispatches the event so widgets can hear it. For use
            // in passing down events from dispatcher without any special
            // handling in the container.
            
            dispatchEvent(event);
        }
        
        protected function onSessionCreateSuccess(event:AppEvent):void {
            client.joinChatRoom(createRoomJID(event.options.jid.resource));
        }
        
        protected function onRegistrationErrors(event:AppEvent):void{
            createSystemNotification({
                error: 'Registration failed. Please try again later.'
            });
            
            if(widgets.signin){
                widgets.signin.resetForm();
                widgets.signin.show();
            }
        }
        
        
        
        //--------------------------------------
        //  Events > Custom handlers
        //--------------------------------------
        
        // [write your own]
        
        
        
        //--------------------------------------
        //  Client helpers
        //--------------------------------------
        
        public function sendMessage(toJID:JID, messageBody:String):void{
            client.sendMessage(toJID, messageBody);
        }
        
        public function sendDataMessage(toJID:JID, payloadType:String, payload:*):void{
            // Typical `payloadType` values should come from a HemlockEvent's
            // constants, e.g., AppEvent.GAME_BEGIN. The value for `payload`
            // should be an object, such as {"foo": "bar", "baz": 1}.
            client.sendDataMessage(toJID, payloadType, payload || {});
        }
        
        public function updateItem(roomJID:JID, updating:JID, opts:Object=null):void {
            client.updateItem(roomJID, updating, opts);
        }
        
        public function sendDirectDataMessage(toJID:JID, payloadType:String, payload:*):void{
            client.sendDirectDataMessage(toJID, payloadType, payload || {});
        }
        
        public function sendPresence(toJID:JID, options:Object):void{
            client.sendPresence(toJID, options);
        }
        
        public function signIn(username:String=null, password:String=null):void{
            client.username = username;
            client.password = password;
            client.connect();
        }
        
        public function signUp(username:String=null, password:String=null):void{
            client.username = username;
            client.password = password;
            client.registering = true;
            
            // Announce start of registration. If you want to integrate with
            // an API (e.g., to create a duplicate user in a separate
            // database), have your container listen for this event.
            dispatcher.dispatchEvent(new AppEvent(AppEvent.REGISTRATION_START));
            
            client.connect();
        }
        
        /* If unique actions need to take place on a per app 
           basis, override this method within the app's container.
           Do make sure that you call super.logout() or client.logout()
           from the override. */
        public function logout():void{
            client.logout();
        }
        
        public function joinChatRoom(toJID:JID):void{
            client.joinChatRoom(new JID(toJID.toString() + '/' + client.username));
        }
        
        public function createChatRoom(roomType:String):void{
            client.createChatRoom(roomType, domain);
        }
        
        public function configureChatRoom(toJID:JID, configOptions:Object=null):void{
            client.configureChatRoom(toJID, configOptions || {});
        }
        
        public function leaveChatRoom(toJID:JID):void{
            client.leaveChatRoom(toJID);
        }
        
        public function discoChatRooms():void{
            Logger.debug("HemlockContainer::discoChatRooms()");
            client.discoChatRooms();
        }
        
        public function discoUsers(roomJID:JID):void{
            Logger.debug("HemlockContainer::discoUsers()");
            client.discoUsers(roomJID);
        }
        
        public function updatePrivacyList(fromJID:JID, stanzaName:String, action:String, options:Object = null):void{
            Logger.debug('HemlockContainer::updatePrivacyList()');
            client.updatePrivacyList(fromJID, stanzaName, action, options);
        }
        
        
        
        //--------------------------------------
        //  Private helpers
        //--------------------------------------
        
        private function createRoomJID(username:String):JID{
            return new JID(room + '/' + username);
        }
        
        
        
        //--------------------------------------
        //  Properties
        //--------------------------------------
        
        public function get client():IClient            { return _client; }
        public function set client(client:IClient):void { _client = client; }
        
        public function get dispatcher():HemlockDispatcher{ 
            _dispatcher ||= HemlockDispatcher.getInstance(); 
            return _dispatcher;
        }
        
        public function get domain():String             { return 'conference.' + HemlockEnvironment.SERVER; }
        
        public function get flashvars():Object          { return _flashvars; }
        
        public function get httpClient():HTTPClient                 { return _httpClient; }
        public function set httpClient(httpClient:HTTPClient):void  { _httpClient = httpClient }

        public function get jid():JID                   { return _jid; }
        
        public function get room():String               { return _room + '@' + domain; }
        
        public function get systemNotificationManager():SystemNotificationManager           { return _systemNotificationManager; }
        public function set systemNotificationManager(value:SystemNotificationManager):void { _systemNotificationManager = value; }
        
        public function get widgets():Object            { return _widgets;  }
        public function set widgets(value:Object):void  { _widgets = value; }
        
        public static function get skin():*             { return HemlockEnvironment.SKIN; }
        
    }
}
