package com.mintdigital.hemlockPixel{
    import com.mintdigital.hemlock.HemlockEnvironment;
    import com.mintdigital.hemlock.Logger;
    // import com.mintdigital.hemlock.clients.HTTPClient;
    import com.mintdigital.hemlock.clients.IClient;
    import com.mintdigital.hemlock.clients.XMPPClient;
    import com.mintdigital.hemlock.data.JID;
    import com.mintdigital.hemlock.display.HemlockSprite;
    import com.mintdigital.hemlock.events.AppEvent;
    import com.mintdigital.hemlock.events.HemlockDispatcher;
    // import com.mintdigital.hemlock.strategies.DataMessageEventStrategy;
    import com.mintdigital.hemlock.strategies.MessageEventStrategy;
    import com.mintdigital.hemlock.utils.JavaScript;

    import flash.events.Event;
    import flash.external.ExternalInterface;
    import flash.utils.setTimeout;

    // For use with Hemlock JS: Build app logic and UIs with JS, and use
    // Hemlock AS (a.k.a. HemlockPixel) purely for Flash's socket connection
    // as a fallback when the WebSocket JS API is unavailable.

    // Note: This uses HemlockPixel.swc, a stripped-down version of
    // HemlockCore.swc, to reduce the compiled binary's file size. Not all of
    // the usual classes are available here.

    public class HemlockPixel extends HemlockSprite{
        protected var _room:String = JID.TYPE_SESSION;
        private var _client:IClient;
        private var _dispatcher:HemlockDispatcher;
        private var _flashvars:Object;
        // private var _httpClient:HTTPClient;
        private var _jid:JID;

        public const STATUS_CODES:Object = {
            // These mirror Strophe.Status codes:
            // http://code.stanziq.com/strophe/strophejs/doc/1.0.1/files/core-js.html#Strophe.Connection_Status_Constants
            ERROR:          0,  // An error has occurred
            CONNECTING:     1,  // The connection is currently being made
            CONNFAIL:       2,  // The connection attempt failed
            AUTHENTICATING: 3,  // The connection is authenticating
            AUTHFAIL:       4,  // The authentication attempt failed
            CONNECTED:      5,  // The connection has succeeded
            DISCONNECTED:   6,  // The connection has been terminated
            DISCONNECTING:  7,  // The connection is currently being terminated
            ATTACHED:       8   // The connection has been attached
        };

        public function HemlockPixel(options:Object = null){
            initialize();
            _flashvars = this.loaderInfo.parameters;

            Logger.addLogFunction(function(string:String):void{
                // Use this to pretty-print HemlockPixel log strings. A simple
                // variation is to pass `console.log` to HemlockPixel, but not
                // all browsers support this function natively.
                //
                // Example usage:
                //
                //   JS:
                //
                //     MyApp.log = function(string){
                //       $('#actionscript-output').append('<p>' + string + '</p>');
                //     };
                //     Hemlock.Bridge.create({
                //       flashvars: {logFunction: 'MyApp.log'}
                //     });
                //
                //   HTML:
                //
                //     <div id="actionscript-output">
                //       <p>ActionScript output:</p>
                //     </div>

                JavaScript.run('function(){ ' +
                    _flashvars.logFunction + '("' +
                        string.replace(new RegExp('"', 'gm'), '\\"') +
                    '"); }'
                );
            });

            // httpClient = new HTTPClient(HemlockEnvironment.API_PATH);

            client = new XMPPClient();
            client.addEventStrategies([
                // new DataMessageEventStrategy(),
                new MessageEventStrategy()
                // App constructors should add a strategy for each custom
                // event that is triggered by a DataMessage payload. This
                // array acts as a stack; earlier strategies take precedence.
            ]);

            // TODO: The following logic is hardcoded for now, but is
            // app-specific. Refactor out into an app-agnostic client config
            // function; apps should decide their own means of authentication.
            (function():void{
                client.username = flashvars.username;
                client.password = flashvars.password;
            })();

            registerListeners();
            startListeners();

            registerJSListeners();
        }

        protected function initialize():void{
            // Custom HemlockPixels should override this to specify custom
            // environments and other configurations.

            include '../../../config/environment.as';
        }



        //--------------------------------------
        //  Events > Initializers
        //--------------------------------------

        override public function registerListeners():void{
            // Register dispatcher listeners
            // registerListener(dispatcher,    AppEvent.SESSION_CREATE_SUCCESS,    onSessionCreateSuccess);
            // registerListener(dispatcher,    AppEvent.REGISTRATION_ERRORS,       onRegistrationErrors);

            // TODO: Listen directly to socket
        }

        public function registerJSListeners():void{
            if(!ExternalInterface.available){ return; }

            ExternalInterface.addCallback('connect',    onJSConnect);
            ExternalInterface.addCallback('sendString', onJSSendString);
        }



        //--------------------------------------
        //  Events > Standard handlers > App
        //--------------------------------------

        /*
        protected function onSessionCreateSuccess(event:AppEvent):void{
            client.joinRoom(createRoomJID(event.options.jid.resource));
        }

        protected function onRegistrationErrors(event:AppEvent):void{}
        */



        //--------------------------------------
        //  Events > JS handlers
        //--------------------------------------

        protected function onJSConnect(jsCallbackName:String):void{
            Logger.debug('Logging in with username=' +
                client.username + ', password=' + client.password);

            // FIXME: Implement

            // FIXME: The following is for testing; delete it.

            var statusCode:int,
                description:String;

            statusCode  = STATUS_CODES.CONNECTING;
            description = 'Connecting...';
            JavaScript.run([
                'function(){',
                    jsCallbackName, '(',
                        statusCode, ', "',
                        description.replace(new RegExp('"', 'gm'), '\\"'),
                    '"); ',
                '}'
            ].join(''));

            setTimeout(function():void{
                statusCode  = STATUS_CODES.CONNECTED;
                description = 'Connected';
                JavaScript.run([
                    'function(){',
                        jsCallbackName, '(',
                            statusCode, ', "',
                            description.replace(new RegExp('"', 'gm'), '\\"'),
                        '"); ',
                    '}'
                ].join(''));
            }, 2000);
        }

        protected function onJSSendString(string:String):void{
            Logger.debug('Received string: ' + string);

            // Send directly to socket
            // FIXME: Implement

            // FIXME: Testing; remove
            (function():void{
                // Send this stanza right back

                import com.mintdigital.hemlock.utils.StringUtils;
                import flash.utils.setTimeout;

                var fakeRawSocketString:String = string,
                    escapedSocketString:String = fakeRawSocketString.replace(
                        new RegExp('"', 'gm'), '\\"');

                JavaScript.run([
                    'function(){',
                        "$(Hemlock.Bridge).trigger(",
                            "'hemlock:incoming', ",
                            '"', escapedSocketString, '"',
                        ");",
                    '}'
                ].join('').replace(new RegExp('"', 'gm'), '\"'));
            })();
        }



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

        public function sendDirectDataMessage(toJID:JID, payloadType:String, payload:*):void{
            client.sendDirectDataMessage(toJID, payloadType, payload || {});
        }

        public function updateItem(roomJID:JID, updating:JID, opts:Object=null):void{
            client.updateItem(roomJID, updating, opts);
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
            // database), have your HemlockPixel listen for this event.
            dispatcher.dispatchEvent(new AppEvent(AppEvent.REGISTRATION_START));

            client.connect();
        }

        /* If unique actions need to take place on a per app
           basis, override this method within the app's HemlockPixel.
           Do make sure that you call super.logout() or client.logout()
           from the override. */
        public function logout():void{
            client.logout();
        }

        public function createRoom(roomType:String):void{
            client.createRoom(roomType, domain);
        }

        public function joinRoom(toJID:JID):void{
            client.joinRoom(new JID(toJID.toString() + '/' + client.username));
        }

        public function leaveRoom(toJID:JID):void{
            client.leaveRoom(toJID);
        }

        public function configureRoom(toJID:JID, configOptions:Object=null):void{
            client.configureRoom(toJID, configOptions || {});
        }

        /*
        public function discoRooms():void{
            Logger.debug("HemlockPixel::discoRooms()");
            client.discoRooms();
        }

        public function discoUsers(roomJID:JID):void{
            Logger.debug("HemlockPixel::discoUsers()");
            client.discoUsers(roomJID);
        }

        public function updatePrivacyList(fromJID:JID, stanzaName:String, action:String, options:Object = null):void{
            Logger.debug('HemlockPixel::updatePrivacyList()');
            client.updatePrivacyList(fromJID, stanzaName, action, options);
        }
        */



        //--------------------------------------
        //  Private helpers
        //--------------------------------------

        private function createRoomJID(username:String):JID{
            return new JID(room + '/' + username);
        }



        //--------------------------------------
        //  Properties
        //--------------------------------------

        public function get client():IClient
            { return _client; }
        public function set client(client:IClient):void
            { _client = client; }

        public function get dispatcher():HemlockDispatcher{
            _dispatcher ||= HemlockDispatcher.getInstance();
            return _dispatcher;
        }

        public function get domain():String
            { return 'conference.' + HemlockEnvironment.SERVER; }

        public function get flashvars():Object
            { return _flashvars; }

        // public function get httpClient():HTTPClient
        //     { return _httpClient; }
        // public function set httpClient(httpClient:HTTPClient):void
        //     { _httpClient = httpClient; }

        public function get jid():JID
            { return _jid; }

        public function get room():String
            { return _room + '@' + domain; }

    }
}
