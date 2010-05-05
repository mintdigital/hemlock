package com.mintdigital.hemlockPixel{
    import com.mintdigital.hemlock.HemlockEnvironment;
    import com.mintdigital.hemlock.Logger;
    import com.mintdigital.hemlock.clients.XMPPClientLite;
    import com.mintdigital.hemlock.data.JID;
    import com.mintdigital.hemlock.display.HemlockSprite;
    import com.mintdigital.hemlock.events.AppEvent;
    import com.mintdigital.hemlock.events.HemlockDispatcher;
    import com.mintdigital.hemlock.events.XMPPEvent;
    import com.mintdigital.hemlock.utils.JavaScript;

    import flash.events.Event;
    import flash.external.ExternalInterface;

    // For use with Hemlock JS: Build app logic and UIs with JS, and use
    // Hemlock AS (a.k.a. HemlockPixel) purely for Flash's socket connection
    // as a fallback when the WebSocket JS API is unavailable.

    // Note: This uses HemlockPixel.swc, a stripped-down version of
    // HemlockCore.swc, to reduce the compiled binary's file size. Not all of
    // the usual classes are available here.

    public class HemlockPixel extends HemlockSprite{
        protected var _room:String = JID.TYPE_SESSION;
        private var _client:XMPPClientLite;
        private var _dispatcher:HemlockDispatcher;
        private var _flashvars:Object;
        private var _jid:JID;
        private var _jsCallbackNames:Object = {};

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

                JavaScript.run(['function(){ ',
                    _flashvars.logFunction, '("',
                        string.replace(new RegExp('"', 'gm'), '\\"'),
                    '");',
                '}'].join(''));
            });

            client = new XMPPClientLite();

            // TODO: The following logic is hardcoded for now, but is
            // app-specific. Refactor out into an app-agnostic client config
            // function; apps should decide their own means of authentication.
            (function():void{
                client.username = flashvars.username;
                client.password = flashvars.password;
                client.server   = 'localhost';
                // TODO: Set client.policyPort
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
            registerListener(dispatcher, AppEvent.SESSION_CREATE_SUCCESS, onSessionCreateSuccess);
            // registerListener(dispatcher, AppEvent.REGISTRATION_ERRORS, onRegistrationErrors);
            registerListener(dispatcher, AppEvent.SESSION_DESTROY,      onSessionDestroy);
            registerListener(dispatcher, AppEvent.CONNECTION_DESTROY,   onConnectionDestroy);
            registerListener(dispatcher, XMPPEvent.RAW_XML, onXMPPRawXml);
        }

        public function registerJSListeners():void{
            if(!ExternalInterface.available){ return; }

            ExternalInterface.addCallback('connect',    onJSConnect);
            ExternalInterface.addCallback('sendString', onJSSendString);
        }



        //--------------------------------------
        //  Events > Handlers > ActionScript
        //--------------------------------------

        protected function onSessionCreateSuccess(ev:AppEvent):void{
            Logger.debug('HemlockPixel::onSessionCreateSuccess()');
            callJSCallbackConnect(STATUS_CODES.CONNECTED, 'Connected');
        }

        protected function onSessionDestroy(ev:AppEvent):void{
            Logger.debug('HemlockPixel::onSessionDestroy()');
            // Do nothing.
        }

        protected function onConnectionDestroy(ev:AppEvent):void{
            Logger.debug('HemlockPixel::onConnectionDestroy()');
            callJSCallbackConnect(STATUS_CODES.DISCONNECTED, 'Disconnected');
        }

        /*
        protected function onRegistrationErrors(ev:AppEvent):void{}
        */

        protected function onXMPPRawXml(ev:XMPPEvent):void{
            Logger.debug('HemlockPixel::onXMPPRawXml() : ev.type = ' + ev.type);
            sendStringToJS(ev.options.rawXML);
        }



        //--------------------------------------
        //  Events > Handlers > JavaScript
        //--------------------------------------

        protected function onJSConnect(jsCallbackName:String):void{
            Logger.debug('HemlockPixel::onJSConnect() : jsCallbackName = ' +
                jsCallbackName);
            Logger.debug('Logging in with username=' +
                client.username + ', password=' + client.password);

            _jsCallbackNames.connect = jsCallbackName;
            callJSCallbackConnect(STATUS_CODES.CONNECTING, 'Connecting...');

            client.connect();
        }

        protected function onJSSendString(string:String):void{
            Logger.debug('Received string: ' + string);

            // Send directly to socket
            client.sendXML(string);
        }



        //--------------------------------------
        //  JavaScript helpers
        //--------------------------------------

        protected function sendStringToJS(string:String):void{
            Logger.debug('HemlockPixel::sendStringToJS()');

            var escapedString:String =
                    string.replace(new RegExp('"', 'gm'), '\\"');

            JavaScript.run(['function(){',
                "$(Hemlock.Bridge).trigger(",
                    '"hemlock:incoming", ',
                    '"', escapedString, '"',
                ");",
            '}'].join('').replace(new RegExp('"', 'gm'), '\"'));
        }

        protected function callJSCallbackConnect(statusCode:int, description:String):void{
            JavaScript.run(['function(){',
                jsCallbackNames.connect, '(',
                    statusCode, ', "',
                    description.replace(new RegExp('"', 'gm'), '\\"'),
                '"); ',
            '}'].join(''));
        }



        //--------------------------------------
        //  Properties
        //--------------------------------------

        public function get client():XMPPClientLite
            { return _client; }
        public function set client(client:XMPPClientLite):void
            { _client = client; }

        public function get dispatcher():HemlockDispatcher{
            _dispatcher ||= HemlockDispatcher.getInstance();
            return _dispatcher;
        }

        public function get domain():String
            { return 'conference.' + HemlockEnvironment.SERVER; }

        public function get flashvars():Object
            { return _flashvars; }

        public function get jid():JID
            { return _jid; }

        public function get jsCallbackNames():Object
            { return _jsCallbackNames; }

        public function get room():String
            { return _room + '@' + domain; }

    }
}
