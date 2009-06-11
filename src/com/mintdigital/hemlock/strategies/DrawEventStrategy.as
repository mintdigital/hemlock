package com.mintdigital.hemlock.strategies{
    import com.mintdigital.hemlock.events.DrawEvent;
    import com.mintdigital.hemlock.strategies.IEventStrategy;
    
    public class DrawEventStrategy extends DataMessageEventStrategy implements IEventStrategy{
        
        public function DrawEventStrategy(){
            super({
                eventClass: DrawEvent,
                eventTypes: DrawEvent.TYPES
            });
        }
        
    }
}
