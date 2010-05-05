package com.mintdigital.hemlock.strategies{
    import com.mintdigital.hemlock.events.HemlockEvent;
    import flash.events.EventDispatcher;    
    
    public interface IEventStrategy{
        function matchesStrategy(ev:HemlockEvent):Boolean;
            // For use with incoming or outgoing data.
            // Returns true if the event matches the implementor's expected
             // event type. For instance, GameEventStrategy would return true
            // if `ev` is of a GAME_START type, false otherwise.
        
        function dispatchMatchingEvent(dispatchee:EventDispatcher, ev:HemlockEvent):Boolean;
            // For use with incoming data.
            // If `ev` matches the implementor's expected event type, the
            // event is dispatched on the dispatchee, and the function returns
            // true. Otherwise, the function returns false.
    }
}
