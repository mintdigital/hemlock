package com.mintdigital.hemlock.strategies{
    import com.mintdigital.hemlock.events.HemlockEvent;
    import flash.events.EventDispatcher;    
    
    public interface IEventStrategy{
        function matchesStrategy(evt:HemlockEvent):Boolean;
            // For use with incoming or outgoing data.
            // Returns true if the event matches the implementor's expected
             // event type. For instance, GameEventStrategy would return true
            // if evt is of  a GAME_START type, false otherwise.
        
        function dispatchMatchingEvent(dispatchee:EventDispatcher, evt:HemlockEvent):Boolean;
            // For use with incoming data.
            // If evt matches the implementor's expected event type, the evt
            // is dispatched on the dispatchee, and the function returns true.
            // Otherwise, the function returns false.
    }
}
