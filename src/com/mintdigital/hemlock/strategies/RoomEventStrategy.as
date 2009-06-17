package com.mintdigital.hemlock.strategies{
    import com.mintdigital.hemlock.data.DataMessage;
    import com.mintdigital.hemlock.data.JID;
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
            // Logger.debug('=> false');
            return false;
        }
        
        public function dispatchMatchingEvent(dispatchee:EventDispatcher, event:HemlockEvent):Boolean{
            if(matchesStrategy(event)){
                var messageEvent:MessageEvent = event as MessageEvent,
                    dataMessage:DataMessage = messageEvent.xmppMessage.toDataMessage(),
                    eventType:String = dataMessage.payloadType,
                    eventOptions:Object = dataMessage.payload;
                
                if(eventOptions.jid && eventOptions.jid is String){
                    eventOptions.jid = new JID(eventOptions.jid);
                }
                
                dispatchee.dispatchEvent(new AppEvent(eventType, eventOptions));
                Logger.debug('RoomEventStrategy::dispatchMatchingEvent() : dispatched ' + eventType);
                return true;
            }
            Logger.debug('RoomEventStrategy::dispatchMatchingEvent() : not dispatched');
            return false;
        }
    }
}
