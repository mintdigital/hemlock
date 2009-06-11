package com.mintdigital.hemlock.widgets{
    import com.mintdigital.hemlock.HemlockEnvironment;
    import com.mintdigital.hemlock.Logger;
    import com.mintdigital.hemlock.containers.HemlockContainer;
    import com.mintdigital.hemlock.data.JID;
    import com.mintdigital.hemlock.data.Presence;
    import com.mintdigital.hemlock.display.HemlockSprite;
    import com.mintdigital.hemlock.events.AppEvent;
    import com.mintdigital.hemlock.events.HemlockDispatcher;
    import com.mintdigital.hemlock.models.Roster;
    
    public class HemlockWidget extends HemlockSprite{
        
        public var delegates:Object = {};
        public var views:Object = {}; // Store all views (shapes, controls, etc.)
        protected var _parentSprite:HemlockSprite;
        protected var _hostJID:JID;
            // The initial host should be determined based on which user is
            // given the moderator role by the server. Afterwards, the host is
            // responsible for choosing a new random host. The title of "host"
            // is based solely on appointment, and not on any "role" or
            // "affiliation" status from the server.
        protected var _roster:Roster;
        private var _widgets:Object = {};
        private var _room:String;
        private var _dispatcher:HemlockDispatcher;
        
        public function HemlockWidget(parentSprite:HemlockSprite, options:Object = null){
            _parentSprite = parentSprite;
            
            super(options);
            
            if(options && options.delegates){ delegates = options.delegates; }
            
            // TODO: HemlockWidgets must have delegates
            delegates.views
                ? delegates.views.createViews()
                : createViews();
            delegates.events
                ? delegates.events.registerListeners()
                : registerListeners();
            startListeners();
        }
        
        public function addWidgets(widgets:Array /* of HemlockWidgets */):void{
            // Adds widgets to stage in the order defined.
            // See HemlockContainer::addWidgets() for usage.
            
            for each(var widget:HemlockWidget in widgets){
                addChild(widget);
            }
        }
        
        
        
        //--------------------------------------
        //  Subclasses should override:
        //--------------------------------------
        
        // TODO: Remove; these should instead be implemented in delegates
        
        public function createViews():void{
            /* Override me in your widget's views delegate */
            
            // Code here with addChild() calls...
            updateSize(); // Do this last
        }
        public function destroyViews():void{
            /* Override me in your widget's views delegate */
        }
        
        
        
        //--------------------------------------
        //  Internal helpers
        //--------------------------------------
        
        public function createRoomJID(username:String):JID {
            /* Used to generate a JID for a user as they join
               a group chat room. Should be updated to use
               nickname instead of username. */
            return new JID(room + '/' + username);
        }
        
        public function get bareJID():JID{
            /* This is the JID that identifies the room independent from
               the client. Use to determine whether or not the room should
               respond to a particular event. */
            return jid.bareJID;
        }
        
        public function isHost():Boolean{
            // Returns true if the current user is the host. For use when a
            // single player should be designated to lead the room.
            
            // For synchronizing data across users, use a bot instead.
            
            return jid && host && jid.eq(host);
        }
        
        /*
        // Disabled because AppEvent.PRESENCE_* no longer contains a Presence instance.
        internal function setHostFromPresence(presence:Presence):void{
            // Sets _hostJID according to the given Presence instance. Use
            // this in custom widgets' PresenceEvent handlers.
            
            if(presence.role == Presence.MODERATOR_ROLE){
                _hostJID = presence.from;
            }
        }
        */
        
        public function setHostFromPresenceEvent(event:AppEvent):void{
            // TODO: Update to accept a PresenceEvent instead of an AppEvent
            
            // Sets _hostJID according to the presence's role in the given
            // event. Use this in custom widgets' AppEvent.PRESENCE_*
            // handlers.
            
            // This function is public because it needs to be available to
            // delegates of HemlockWidget subclasses.
            
            if(event.options.presenceRole == Presence.MODERATOR_ROLE){
                _hostJID = event.options.presenceFrom;
            }
        }
        
        public function sendMessage(messageBody:String) : void {
            container.sendMessage(bareJID, messageBody);
        }
        
        public function sendDataMessage(payloadType:String, payload:*=null):void{
            // Typical `payloadType` values should come from a HemlockEvent's
            // constants, e.g., AppEvent.GAME_BEGIN. The value for `payload`
            // should be an object, such as { foo: "bar", baz: 1 }.
            container.sendDataMessage(bareJID, payloadType, payload || {});
        }
        
        public function sendPresence(options:Object):void{
            container.sendPresence(bareJID, options);
        }
        
        
        
        //--------------------------------------
        //  Screens
        //--------------------------------------
        
        // Screens are simply HemlockSprites with child views; use screens to
        // switch sets of views on and off.
        // 
        // Example usage:
        // 
        //     // Set up screens
        //     const SCREEN_BEFORE_GAME:String = 'screen_beforeGame',
        //           SCREEN_GAME:String        = 'screen_game';
        //     createScreens(SCREEN_BEFORE_GAME, SCREEN_GAME);
        //     
        //     // Set up and show BEFORE_GAME screen
        //     views.logo = new Sprite();
        //     getScreen(SCREEN_BEFORE_GAME).addChild(views.logo);
        //     showScreen(SCREEN_BEFORE_GAME);
        
        public function getScreen(screenName:String):HemlockSprite{
            return views.screens ? views.screens[screenName] : null;
        }
        
        public function createScreens(... screenNames /* of Strings */):void{
            // - Sets `views.screens` to an object hash in which each key is
            //   an element from `screenNames`, and each value is a
            //   HemlockSprite that takes up the widget's entire width and
            //   height.
            // - Adds each screen to the widget as a child.

            const WIDTH:Number = options.width;
            const HEIGHT:Number = options.height;

            if(!views.screens){ views.screens = {}; }
            var screen:HemlockSprite;
            
            for each(var screenName:String in screenNames){
                screen = new HemlockSprite();
                with(screen.graphics){
                    // Add invisible graphics to force the screen to match the
                    // widget's dimensions. Without this, the screen shrinks
                    // to the size of its contents, then scales them up to
                    // match the widget's dimensions.

                    beginFill(0, 0);
                    // beginFill(0x00FF00, 1);
                    drawRect(0, 0, WIDTH, HEIGHT); // Prop open
                    endFill();
                }
                screen.setSize(WIDTH, HEIGHT);
                views.screens[screenName] = screen;
            }
            
            // Add screens
            for each(screen in views.screens){ addChild(screen); }
        }
        
        public function recreateScreen(screenName:String):HemlockSprite{
            // Destroys, recreates, and returns the given screen. This is
            // useful for quickly removing all content from a screen and
            // starting over.

            destroyScreen(screenName);
            createScreens(screenName);
            
            var screen:HemlockSprite = getScreen(screenName);
            addChild(screen);
            return screen;
        }

        public function destroyScreen(screenName:String):void{
            // Removes the given screen from the widget, and deletes the
            // object in views.screens that points to it.

            removeChild(views.screens[screenName]);
            delete views.screens[screenName];
        }

        public function showScreen(screenName:String):void{
            // Shows the specified screen and hides others.
            // 
            // Usage:
            // - showScreen('settings');

            showScreens(screenName);
        }

        public function showScreens(... screenNames /* of Strings */):void{
            // Shows the specified screens and hides others.
            // 
            // Usage:
            // - showScreens('settings');
            // - showScreens('chooseCategory', 'showCards');

            for(var screenName:String in views.screens){
                var screen:HemlockSprite = getScreen(screenName);
                if(screenNames.indexOf(screenName) >= 0){
                    screen.show();
                    moveChildToFront(screen);
                }else{
                    screen.hide();
                }
            }
        }
        
        
        
        //--------------------------------------
        //  Properties
        //--------------------------------------
        
        public function get room():String{
            return _room + '@' + domain;
        }
        
        public function get domain():String{
            return 'conference.' + HemlockEnvironment.SERVER;
        }
        
        public function get container():*{
            // Returns the root HemlockContainer, regardless of whether this
            // widget is a direct child of that container, or nested inside
            // another widget.
            
            // Use this if a nested widget needs to listen for an event from
            // the container.
            
            return (_parentSprite is HemlockContainer)
                ? (_parentSprite as HemlockContainer)
                : (_parentSprite as HemlockWidget).container;
        }
        
        public function get dispatcher():HemlockDispatcher {
            _dispatcher ||= HemlockDispatcher.getInstance();
            return _dispatcher;
        }
        
        public function get parentSprite():HemlockSprite    { return _parentSprite; }
        
        public function get host():JID                      { return _hostJID; }
        public function set host(value:JID):void            { _hostJID = value; }
        
        public function get roster():Roster                 { return _roster; }
        public function set roster(value:Roster):void       { _roster = value; }
                                                            
        public function get jid():JID                       { return new JID(_options.jid); }
        public function set jid(value:JID):void             { _options.jid = value; }
        
        public function get widgets():Object                { return _widgets; }
        
        public static function get skin():*                 { return HemlockEnvironment.SKIN; }

    }
}
