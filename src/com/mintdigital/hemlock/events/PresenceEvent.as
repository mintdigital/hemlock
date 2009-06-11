package com.mintdigital.hemlock.events{
    import com.mintdigital.hemlock.data.JID;
    import com.mintdigital.hemlock.data.Presence;

    import flash.events.Event;
    
    public class PresenceEvent extends HemlockEvent{
        public static const CREATE:String           = 'presence_create';
        public static const UPDATE:String           = 'presence_update';
        public static const DESTROY:String          = 'presence_destroy';
        
        public static const STATUS_AWAY:String      = 'away';
        public static const STATUS_OFFLINE:String   = 'offline';
        public static const STATUS_AVAILABLE:String = 'available';
        
        public function PresenceEvent(type:String, options:Object = null){
            super(type, options);
        }
        
        public function isFromUser():Boolean{
            return presence.from.domain.search(/^conference\./) >= 0;
        }
        
        override public function clone() : Event {
            return new PresenceEvent(type, options);
        }
    
        override public function toString() : String {
              // return formatHemlockEventToString('PresenceEvent');
            return formatToString('PresenceEvent', 'type', 'message', 'error', 'errorCode', 'from', 'status');
        }        
        
        
        
        //--------------------------------------
        //  Properties
        //--------------------------------------

        public function get presence():Presence { return options.presence; }
        
        public function get jid():String { return options.jid; }
        
        public function get status():String {
            var status:String;
            
            if(presence.show == Presence.SHOW_AWAY){
                status = STATUS_AWAY;
            }else if(presence.type == Presence.UNAVAILABLE_TYPE){
                status = STATUS_OFFLINE;
            }else if(!presence.show){
                status = STATUS_AVAILABLE;
            }else{
                status = presence.status;
            }
            return status;
        }
        
    }
}
