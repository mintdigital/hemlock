package com.mintdigital.hemlock.events{
    import flash.events.Event;
    
    public class DrawEvent extends HemlockEvent{
        
        public static const BRUSH:String    = 'draw_brush';
        public static const COORDS:String   = 'draw_coords';
        public static const CLEAR:String    = 'draw_clear';
        
        public static const TYPES:Array /* of Strings */ = [
            BRUSH, COORDS, CLEAR
        ];
        
        public function DrawEvent(type:String, options:Object = null){
            super(type, options);
        }
        
        override public function clone():Event{
            return new AppEvent(type, options);
        }
        
        override public function toString():String{
              return formatHemlockEventToString('DrawEvent');
        }
        
    }
}
