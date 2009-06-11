package com.mintdigital.hemlock.strategies{
    import com.mintdigital.hemlock.data.Message;
    import com.mintdigital.hemlock.events.MessageEvent;
    import com.mintdigital.hemlock.data.DataMessage;

    import com.mintdigital.hemlock.events.HemlockEvent;
    import com.mintdigital.hemlock.events.AppEvent;
    import com.mintdigital.hemlock.Logger;
    
    import flash.events.EventDispatcher;
    
    public class MessageEventStrategy implements IEventStrategy{
        public function MessageEventStrategy(){}
        
        public function matchesStrategy(event:HemlockEvent):Boolean{
            Logger.debug('MessageEventStrategy::matchesStrategy() : type = ' + event.type);
            if(event is MessageEvent){
                var messageEvent:MessageEvent = event as MessageEvent;
                var isMatch:Boolean = (messageEvent.xmppMessage.payloadType == Message.DEFAULT_PAYLOAD_TYPE);
                Logger.debug('=> ' + isMatch + ' (payloadType = ' + messageEvent.xmppMessage.payloadType + ')');
                return isMatch;
            }
            Logger.debug('=> false (not a MessageEvent)');
            return false;
        }
        
        public function dispatchMatchingEvent(dispatchee:EventDispatcher, event:HemlockEvent):Boolean{
            if(matchesStrategy(event)){
                var messageEvent:MessageEvent = event as MessageEvent;
                var message:Message = messageEvent.xmppMessage;
                dispatchee.dispatchEvent(new AppEvent(AppEvent.CHAT_MESSAGE, event.options));
                return true;
            }
            return false;
        }
    }
}
