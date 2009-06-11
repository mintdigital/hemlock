package com.mintdigital.hemlock.strategies{
    import com.mintdigital.hemlock.data.DataMessage;
    import com.mintdigital.hemlock.data.Message;
    import com.mintdigital.hemlock.events.MessageEvent;
    import com.mintdigital.hemlock.events.AppEvent;
    import com.mintdigital.hemlock.events.HemlockEvent;
    import com.mintdigital.hemlock.Logger;
    
    import flash.events.EventDispatcher;
    
    public class RoomEventStrategy implements IEventStrategy{
        public function RoomEventStrategy(){}
        
        public function matchesStrategy(event:HemlockEvent):Boolean{
            Logger.debug('RoomEventStrategy::matchesStrategy() : type = ' + event.type);
            if(event is MessageEvent){
                var messageEvent:MessageEvent = event as MessageEvent;
                var isMatch:Boolean = (messageEvent.xmppMessage.payloadType == AppEvent.ROOM_CONFIGURED);
                Logger.debug('=> ' + isMatch + ' (payloadType = ' + messageEvent.xmppMessage.payloadType + ')');
                return isMatch;
            }
            Logger.debug('=> false (not a ROOM_CONFIGURED event)');
            return false;
        }
        
        public function dispatchMatchingEvent(dispatchee:EventDispatcher, event:HemlockEvent):Boolean{
            if(matchesStrategy(event)){
                var messageEvent:MessageEvent = event as MessageEvent;
                var dataMessage:DataMessage = messageEvent.xmppMessage.toDataMessage();
                dispatchee.dispatchEvent(new AppEvent(dataMessage.payloadType, dataMessage.payload));
                return true;
            }
            return false;
        }
    }
}
