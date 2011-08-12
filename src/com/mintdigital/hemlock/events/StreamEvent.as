package com.mintdigital.hemlock.events{
    import com.mintdigital.hemlock.conn.IConnection;
    
    import flash.events.Event;
    import flash.xml.XMLNode;
    
    public class StreamEvent extends HemlockEvent{
        public static const START:String    = 'stream_start';
        public static const ERROR:String    = 'stream_error';
        
        protected var _connection:IConnection;
        protected var _node:XMLNode;
        
        public function StreamEvent(type:String, options:Object = null){
            if(!options){ options = {}; }
            
            super(type, options);
            _connection = options.connection;
            _node       = options.node;
        }
        
        override public function clone():Event{
            return new StreamEvent(type, options);
        }
        
        override public function toString():String{
            return formatHemlockEventToString('StreamEvent');
        }
        
        
        
        //--------------------------------------
        //  Properties
        //--------------------------------------
        
        public function get connection():IConnection{ return _connection; }
        
        public function get node():XMLNode          { return _node; }
        
    }
}
