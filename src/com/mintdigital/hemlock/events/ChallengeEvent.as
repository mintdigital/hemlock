package com.mintdigital.hemlock.events {    
    import flash.events.*;
    import com.mintdigital.hemlock.conn.IConnection;
    import flash.xml.XMLNode;
    
    public class ChallengeEvent extends HemlockEvent {
      
        public static const CHALLENGE:String = 'challenge';
        
        protected var _connection:IConnection;
        protected var _node:XMLNode;
            
        public function ChallengeEvent (type:String, options:Object = null){
            super(type, options);
            _connection = options.connection;
            _node = options.node;
        }
        
        public override function clone() : Event {
            return new ChallengeEvent(type, options);
        }
        
        public override function toString() : String {
            return formatToString("ChallengeEvent", "type", "bubbles", "cancelable", "eventPhase", "connection")
        }        
        
        
        
        //--------------------------------------
        //  Properties
        //--------------------------------------
        
        public function get connection():IConnection{ return _connection; }
        
        public function get data():String{
            return _node.childNodes[0].nodeValue;
        }
        
    }
}
