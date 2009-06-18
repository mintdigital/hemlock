package com.mintdigital.hemlock.auth {
    import com.mintdigital.hemlock.conn.XMPPConnection;
    import com.mintdigital.hemlock.Logger;
    import com.mintdigital.hemlock.data.register.RegisterExtension;
    import com.mintdigital.hemlock.events.RegistrationEvent;
    
    import flash.xml.XMLDocument;
    import flash.xml.XMLNode;
    import flash.events.EventDispatcher;
    import flash.events.Event;
    
    import org.jivesoftware.xiff.data.IQ;
    import org.jivesoftware.xiff.data.ExtensionClassRegistry;
    
    public class Registration extends EventDispatcher {
        
        public var _connection : XMPPConnection;
        public var _username : String;
        public var _password : String;
        private var _regResponse:RegisterExtension = new RegisterExtension();
        private var _getRegisterIQ:IQ = new IQ(null, IQ.GET_TYPE);
        private var _setRegisterIQ:IQ = new IQ(null, IQ.SET_TYPE);
        
        function Registration(connection : XMPPConnection){
            Logger.debug("Registration()");
            super();
            _connection = connection;
            ExtensionClassRegistry.register(RegisterExtension);
        }
        
        public function start() : void {
            Logger.debug("Registration::start() ");

            _connection.addEventListener(RegistrationEvent.REGISTERING, onRegisterResponse);
            
            _connection.sendStanza(getRegisterIQ);
        }

        
        
        //--------------------------------------
        //  Events > Handlers
        //--------------------------------------
        
        private function onStart(event : RegistrationEvent) : void {
            Logger.debug("Registration::onStart()");
        }
        
        public function onRegisterResponse(e:RegistrationEvent):void {
            Logger.debug("Registration::onRegisterResponse()");
            
            var iq:IQ = e.iq;
            var regRequest:RegisterExtension = iq.getExtension("query") as RegisterExtension;
            
            switch(regRequest.status) {
                case "registering":
                    _connection.sendStanza(setRegisterIQ);
                    break;
                case "errors":
                    dispatchEvent(new RegistrationEvent(RegistrationEvent.ERRORS));
                    _connection.removeEventListener(RegistrationEvent.REGISTERING, onRegisterResponse);
                    break;
                case "complete":
                    dispatchEvent(new RegistrationEvent(RegistrationEvent.COMPLETE));
                    _connection.removeEventListener(RegistrationEvent.REGISTERING, onRegisterResponse);
                    break;
                default:
                    break;
            }
        }
        
        
        
        //--------------------------------------
        //  Internal helpers
        //--------------------------------------
        
        // ...
        
        
        
        //--------------------------------------
        //  Properties
        //--------------------------------------
        
        public function get connection() : XMPPConnection { 
            return _connection; 
        }
        
        private function get getRegisterIQ() : IQ {
            _getRegisterIQ.addExtension(new RegisterExtension());

            _getRegisterIQ.callbackName = "handleRegisterResponse";
            _getRegisterIQ.callbackScope = _connection;
            return _getRegisterIQ;
        }
        
        private function get setRegisterIQ() : IQ {
            _setRegisterIQ.addExtension(regResponse);
            _setRegisterIQ.callbackName = "handleRegisterResponse";
            _setRegisterIQ.callbackScope = _connection;
            return _setRegisterIQ;
        }
        
        private function get regResponse() : RegisterExtension {
            _regResponse.username = _username;
            _regResponse.password = _password;
            return _regResponse;
        }
        
        public function get username() : String { 
            return _username; 
        }
        
        public function set username( arg:String ) : void { 
            _username = arg; 
        }
        
        public function get password() : String { 
            return _password; 
        }
        
        public function set password( arg:String ) : void { 
            _password = arg; 
        }

    }
}