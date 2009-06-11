package com.mintdigital.hemlock.strategies{
    import com.mintdigital.hemlock.Logger;
    import com.mintdigital.hemlock.data.DataMessage;
    import com.mintdigital.hemlock.events.MessageEvent;
    import com.mintdigital.hemlock.events.HemlockEvent;
    import com.mintdigital.hemlock.strategies.IEventStrategy;
    import com.mintdigital.hemlock.strategies.MessageEventStrategy;

    import flash.events.EventDispatcher;

    public class DataMessageEventStrategy extends MessageEventStrategy implements IEventStrategy{
        
        private var _eventClass:Class;
        private var _eventTypes:Array /* of Strings */ = [];
        
        public function DataMessageEventStrategy(options:Object){
            _eventClass = options.eventClass;
            _eventTypes = options.eventTypes;
        }
        
        override public function matchesStrategy(event:HemlockEvent):Boolean{
            Logger.debug('DataMessageEventStrategy::matchesStrategy()');
            if(event is MessageEvent){
                var messageEvent:MessageEvent = event as MessageEvent;
                return _eventTypes.indexOf(messageEvent.xmppMessage.payloadType) >= 0;
            }
            return false;
        }
        
        override public function dispatchMatchingEvent(dispatchee:EventDispatcher, event:HemlockEvent):Boolean{
            if(matchesStrategy(event)){
                var messageEvent:MessageEvent = event as MessageEvent,
                    dataMessage:DataMessage = messageEvent.xmppMessage.toDataMessage(),
                    eventType:String = dataMessage.payloadType,
                    eventOptions:Object = getEventOptions(eventType, dataMessage.payload);
                
                // Discard `event`, which is a MessageEvent. Dispatch a new
                // event of type _eventClass in its place.
                dispatchee.dispatchEvent(new _eventClass(eventType, eventOptions));
                Logger.debug('DataMessageEventStrategy::dispatchMatchingEvent() : dispatched ' + eventType);
                
                // TODO: Create hook here for post-dispatch behavior/callback
                // - e.g., Dispatching ChatroomEvents
                
                return true;
            }
            Logger.debug('DataMessageEventStrategy::dispatchMatchingEvent() : not dispatched');
            return false;
        }
        
        protected function getEventOptions(eventType:String, options:Object):Object{
            // Returns an object hash for constructing the event to be
            // dispatched.
            
            // Override this to customize how events should be constructed,
            // e.g., convert JID strings into actual strings, or other such
            // deserializations.
            
            return options;
        }
        
        
        
        //--------------------------------------
        //  Properties
        //--------------------------------------
        
        public function get eventClass():Class                  { return _eventClass; }
        
        public function get eventTypes():Array /* of Strings */ { return _eventTypes; }
        
    }
}
