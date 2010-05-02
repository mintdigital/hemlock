package com.mintdigital.hemlock.events {    
    import flash.events.*;
    import com.mintdigital.hemlock.conn.IConnection;
    import flash.xml.XMLNode;
    import org.jivesoftware.xiff.data.IQ;
    
    public class RegistrationEvent extends HemlockEvent {
      
        public static const START:String        = 'start';
        public static const REGISTERING:String  = 'registering';
        public static const COMPLETE:String     = 'complete';
        public static const ERRORS:String       = 'errors';

        public function RegistrationEvent (type:String, options:Object = null){
            super(type, options);
        }
        
        public override function clone() : Event {
            return new RegistrationEvent(type, options);
        }
        
        public override function toString() : String {
            return formatToString("RegistrationEvent", "type", "bubbles", "cancelable", "eventPhase", "connection")
            // TODO: Update to use HemlockEvent::formatHemlockEventToString() ?
        }



        //--------------------------------------
        //  Properties
        //--------------------------------------

        public function get iq():IQ             { return options.iq; }
        public function get username():String   { return options.username; }
        public function get password():String   { return options.password; }
        
    }
}
