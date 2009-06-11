// This event is used for the xmpp layer communication (usually connection <-> client)
package com.mintdigital.hemlock.events{
    import flash.events.Event;
    
    public class XMPPEvent extends HemlockEvent{

        public function XMPPEvent(type:String, options:Object = null){
            super(type, options);
        }
        
        override public function clone():Event{
            return new XMPPEvent(type, options);
        }
        
        override public function toString():String{
            return formatHemlockEventToString('XMPPEvent');
        }
        
    }
}
