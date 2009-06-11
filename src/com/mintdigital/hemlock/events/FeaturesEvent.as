package com.mintdigital.hemlock.events {    
    import com.mintdigital.hemlock.conn.XMPPConnection;
    import com.mintdigital.hemlock.events.HemlockEvent;
    
    import flash.events.Event;
    import flash.xml.XMLNode;
    
    public class FeaturesEvent extends HemlockEvent{

        public static const FEATURES:String = 'features';
        protected var _connection:XMPPConnection;
        protected var _node:XMLNode;
            
        public function FeaturesEvent(type:String, options:Object = null){
            if(!options){ options = {}; }
            
            super(type, options);
            _connection = options.connection;
            _node       = options.node;
        }
        
        public override function clone():Event{
            return new FeaturesEvent(type, options);
        }
        
        public override function toString():String{
            return formatHemlockEventToString('FeaturesEvent');
        }        
        
        
        
        //--------------------------------------
        //  Properties
        //--------------------------------------
        
        public function get connection():XMPPConnection { return _connection; }
        
        public function get data():String               { return _node.childNodes[0].nodeValue; }
        
    }
}
