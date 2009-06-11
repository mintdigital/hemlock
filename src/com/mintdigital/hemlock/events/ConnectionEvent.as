package com.mintdigital.hemlock.events{
    import flash.events.Event;
    
    public class ConnectionEvent extends HemlockEvent{
        
        public static const CREATE_SUCCESS:String   = 'connection_createSuccess';
        public static const CREATE_FAILURE:String   = 'connection_createFailure';
        public static const DESTROY:String          = 'connection_destroy'; // Disconnect
        
        public function ConnectionEvent(type:String, options:Object = null){
            super(type, options);
        }
        
        override public function clone():Event{
            return new ConnectionEvent(type, options);
        }
        
        override public function toString():String{
            return formatHemlockEventToString('ConnectionEvent');
        }
        
    }
}
