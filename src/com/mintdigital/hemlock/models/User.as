package com.mintdigital.hemlock.models{
    import com.mintdigital.hemlock.data.JID;
    
    public dynamic class User {
        private var _nickname:String;
        private var _jid:JID;
        private var _status:String;
        private var _role:String
        private var _affiliation:String
        private var _realJID:JID;
        private var _voteCount:int = 0; // FIXME: Remove; this class should be generalized
        
        // FIXME: This should really just accept _options and expose the necessary public properties.
        public function User(jid:*, nickname:String = null, status:String = null, role:String=null, affiliation:String=null, realJIDOrString:*=null) {
            // `jid` is a JID or String.
            
            _jid = (jid is JID ? jid : new JID(jid));
            _nickname = nickname;
            _status = status;
            _role = role;
            _affiliation = affiliation;
            realJID = realJIDOrString;
        }
        
        public function toString():String{
            return '[User : jid = ' + jid + ' | nickname = ' + nickname + 
                   ' | realJID : ' + realJID + ']';
        }
        
        public function get role():String { return _role; }
        public function set role(val:String):void {
            if (val != null) {
                _role = val;
            }
        }
        
        public function get affiliation():String { return _affiliation; }
        public function set affiliation(val:String):void { 
            if (val != null) {
                _affiliation = val;
            }
        }
        
        public function get realJID():JID { return _realJID; }
        public function set realJID(val:*):void { 
            if (val != null) {
                _realJID = val is JID ? val : new JID(val);
            }
        }
        
        //--------------------------------------
        //  Properties
        //--------------------------------------
    
        public function get jid():JID                   { return _jid; }
        
        public function get nickname():String           { return _nickname; }
        public function set nickname(value:String):void { _nickname = value; }
        
        public function get status():String             { return _status; }
        public function set status(value:String):void   { _status = value; }
    }
}
