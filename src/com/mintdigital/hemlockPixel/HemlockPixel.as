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
        private var _host:String;
        private var _mucHost:String;
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
                // variation is to pass `console.log` instead of `MyApp.log`,
                // but not all browsers support this function natively.
                //
                // Example usage:
                //
                //   JS:
                //
                //     MyApp.log = function(string){
                //       jQuery('#actionscript-output').
                //          append('<p>' + string + '</p>');
                //     };
                //     Hemlock.Bridge.create({
                //       flashvars: {
                //          username:       'me',
                //          password:       'secret',
                //          host:           'localhost',
                //          mucHost:        'conference.localhost',
                //          logFunction:    'MyApp.log'
                //       }
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

            client = new XMPPClientLite({
                username:   flashvars.username,
                password:   flashvars.password,
                resource:   flashvars.resource,
                server:     flashvars.host ||
                                HemlockEnvironment.SERVER,
                policyPort: flashvars.policyPort ||
                                HemlockEnvironment.POLICY_PORT
            });

            // Handle internal ActionScript events
            registerListeners();
            startListeners();

            // Handle JavaScript-triggered events
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
            registerListener(dispatcher, AppEvent.SESSION_CREATE_SUCCESS,
                onSessionCreateSuccess);
            registerListener(dispatcher, AppEvent.SESSION_DESTROY,
                onSessionDestroy);
            registerListener(dispatcher, AppEvent.CONNECTION_DESTROY,
                onConnectionDestroy);
            registerListener(dispatcher, AppEvent.IO_ERROR,
                onIOError);
            registerListener(dispatcher, XMPPEvent.RAW_XML,
                onXMPPRawXml);
        }

        public function registerJSListeners():void{
            Logger.debug('HemlockPixel::registerJSListeners()');
            if(!ExternalInterface.available){
                Logger.debug('- !ExternalInterface.available');
                return;
            }

            ExternalInterface.addCallback('connect',    onJSConnect);
            ExternalInterface.addCallback('disconnect', onJSDisconnect);
            ExternalInterface.addCallback('sendString', onJSSendString);
        }



        //--------------------------------------
        //  Events > Handlers > ActionScript
        //--------------------------------------

        protected function onSessionCreateSuccess(ev:AppEvent):void{
            Logger.debug('HemlockPixel::onSessionCreateSuccess()');
            callJSConnectCallback(STATUS_CODES.CONNECTED, 'Connected');
        }

        protected function onSessionDestroy(ev:AppEvent):void{
            Logger.debug('HemlockPixel::onSessionDestroy()');
            // Do nothing.
        }

        protected function onConnectionDestroy(ev:AppEvent):void{
            Logger.debug('HemlockPixel::onConnectionDestroy()');
            callJSConnectCallback(STATUS_CODES.DISCONNECTED, 'Disconnected');
        }

        protected function onIOError(ev:AppEvent):void{
            Logger.debug('HemlockPixel::onIOError()');
            callJSConnectCallback(STATUS_CODES.ERROR, 'IO error');
        }

        protected function onXMPPRawXml(ev:XMPPEvent):void{
            Logger.debug('HemlockPixel::onXMPPRawXml() : ev.type = ' + ev.type);
            sendStringToJS(ev.options.rawXML);
        }



        //--------------------------------------
        //  Events > Handlers > JavaScript
        //--------------------------------------

        protected function onJSConnect(jsCallbackName:String):void{
            Logger.debug('HemlockPixel::onJSConnect() : ' +
                'jsCallbackName = ' + jsCallbackName);
            Logger.debug('Logging in with username=' +
                client.username + ', password=' + client.password);

            _jsCallbackNames.connect = jsCallbackName;
            callJSConnectCallback(STATUS_CODES.CONNECTING, 'Connecting...');

            client.connect();
        }

        protected function onJSDisconnect():void{
            Logger.debug('HemlockPixel::onJSDisconnect()');

            // Uses the same callback as `onJSConnect`.

            callJSConnectCallback(
                STATUS_CODES.DISCONNECTING, 'Disconnecting...');
            client.disconnect();
        }

        protected function onJSSendString(string:String):void{
            Logger.debug('Received from JS: ' + string);

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
                "jQuery(Hemlock.Bridge).trigger(",
                    '"incoming.hemlock", ',
                    '"', escapedString, '"',
                ");",
            '}'].join('').replace(new RegExp('"', 'gm'), '\"'));
        }

        protected function callJSConnectCallback(statusCode:int, description:String):void{
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

        public function get host():String               { return _host; }
        public function set host(value:String):void     { _host = value; }

        public function get mucHost():String            { return _mucHost; }
        public function set mucHost(value:String):void  { _mucHost = value; }

        public function get flashvars():Object{ return _flashvars; }

        public function get jid():JID{ return _jid; }

        public function get jsCallbackNames():Object
            { return _jsCallbackNames; }

        public function get room():String{ return _room + '@' + mucHost; }

    }
}
