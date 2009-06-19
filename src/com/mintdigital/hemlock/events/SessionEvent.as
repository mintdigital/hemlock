package com.mintdigital.hemlock.events{
    import flash.events.Event;

    public class SessionEvent extends HemlockEvent{
        public static const START:String = 'session_start';
        public static const CREATE_SUCCESS:String = 'session_createSuccess';
        public static const CREATE_FAILURE:String = 'session_createFailure';
        public static const DESTROY:String = 'session_destroy';
        
        public function SessionEvent(type:String, options:Object = null){
            super(type, options);
        }
        
        override public function clone() : Event {
            return new SessionEvent(type, options);
        }

        override public function toString() : String {
            return formatHemlockEventToString('SessionEvent');
        }
        
        
        
        //--------------------------------------
        //  Properties
        //--------------------------------------
        
        public function get username():String   { return options.username; }
        public function get password():String   { return options.password; }
        public function get jid():String        { return options.jid; }
        
    }
}
