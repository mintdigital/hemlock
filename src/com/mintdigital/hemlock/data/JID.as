package com.mintdigital.hemlock.data{
    import org.jivesoftware.xiff.core.JID;
    
    public class JID extends org.jivesoftware.xiff.core.JID{
        
        // Format: [ node "@" ] domain [ "/" resource ]
        // => [ ROOM_NAME "@" ] conference.SERVER [ "/" NICKNAME ]
        // Source: http://www.ietf.org/rfc/rfc3920.txt
        
        public static const TYPE_CHAT:String    = 'chat';
        public static const TYPE_APP:String     = 'app';
        public static const TYPE_SESSION:String = 'session';
        
        protected var _jidString:String;
        protected var _bareJIDString:String;
            // There's a bit of redundancy here with the superclass, mainly
            // because the superclass stores its `jid` and `bareJID` as
            // private member variables.
        protected var _node:String;
        protected var _domain:String;
        protected var _resource:String;
        protected var _type:String;
            // One of the TYPE_* constants
        protected var _key:String;
        
        public function JID(jidString:String):void{
            super(jidString);
            _jidString = jidString || '';
        }
        
        public function eq(otherJID:*, isCaseSensitive:Boolean = false):Boolean{
            // `otherJID` should be a JID or String.
            
            return isCaseSensitive
                ? toString() == otherJID.toString()
                : toString().toLowerCase() == otherJID.toString().toLowerCase();
        }
        
        
        
        //--------------------------------------
        //  Properties
        //--------------------------------------
        
        public function get bareJID():com.mintdigital.hemlock.data.JID{
            if(!_bareJIDString){
                _bareJIDString = toBareJID(); // See superclass
            }
            return new com.mintdigital.hemlock.data.JID(_bareJIDString);
        }
        
        override public function get node():String{
            if(!_node){
                var i:int = _jidString.indexOf('@');
                if(i >= 0){ _node = _jidString.slice(0, i); }
            }
            return _node;
        }
        
        override public function get domain():String{
            if(!_domain){
                var iAt:int     = _jidString.indexOf('@'),
                    iSlash:int  = _jidString.indexOf('/');
                if(iAt < 0){ iAt = -1; }
                
                _domain = (iSlash >= 0)
                    ? _jidString.slice(iAt + 1, iSlash)
                    : _jidString.slice(iAt + 1);
            }
            return _domain;
        }
        
        override public function get resource():String{
            if(!_resource){
                var i:int = _jidString.indexOf('/');
                if(i >= 0){ _resource = _jidString.slice(i + 1); }
            }
            return _resource;
        }
        
        public function get type():String{
            if(!_type){
                var i:int = node.indexOf('_');
                _type = (i >= 0) ? node.slice(0, i) : node;
            }
            return _type;
        }
        
        public function get key():String{
            if(!_key){
                var i:int = node.lastIndexOf('_');
                _key = node.slice(i + 1);
            }
            return _key;
        }
        
    }
}
