package com.mintdigital.hemlock.auth{
    import com.mintdigital.hemlock.conn.XMPPConnection;
    
    public class SASLAuth{
        public static const MECHANISM_ANONYMOUS:String  = 'ANONYMOUS';
        public static const MECHANISM_DIGEST_MD5:String = 'DIGEST-MD5';
        public static const MECHANISM_PLAIN:String      = 'PLAIN';
        private var _connection : XMPPConnection;
        
        public function SASLAuth(connection:XMPPConnection){
            super();
            _connection = connection;
        }
        
        // Override:
        public function start():void{}
        public function stop():void{}
        
        
        
        //--------------------------------------
        //  Properties
        //--------------------------------------
        
        public function get connection():XMPPConnection             { return _connection; }
        public function set connection(value:XMPPConnection):void   { _connection = value; }
        
    }
}
