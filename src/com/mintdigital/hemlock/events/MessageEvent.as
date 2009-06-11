package com.mintdigital.hemlock.events{
    import com.mintdigital.hemlock.data.Message;
    
    import flash.events.Event;

    public class MessageEvent extends HemlockEvent{
        
        public static const CHAT_MESSAGE:String = 'message_chatMessage';  
        
        public function MessageEvent(type:String, options:Object = null){
            super(type, options);
        }
        
        public function get xmppMessage():Message{
            return options.xmppMessage;
        }
        
        override public function clone():Event{
            return new MessageEvent(type, options);
        }
        
        override public function toString():String{
            return formatHemlockEventToString('MessageEvent');
        }
        
    }
}
