package com.mintdigital.hemlock.auth{
    import com.mintdigital.hemlock.conn.IConnection;

    public class SASLAuth{
        public static const MECHANISM_ANONYMOUS:String  = 'ANONYMOUS';
        public static const MECHANISM_DIGEST_MD5:String = 'DIGEST-MD5';
        public static const MECHANISM_PLAIN:String      = 'PLAIN';
        public static const XMLNS:String = 'urn:ietf:params:xml:ns:xmpp-sasl';
        private var _connection:IConnection;

        public function SASLAuth(connection:IConnection){
            super();
            _connection = connection;
        }

        // Override:
        public function start():void{}
        public function stop():void{}



        //--------------------------------------
        //  Properties
        //--------------------------------------

        public function get connection():IConnection            { return _connection; }
        public function set connection(value:IConnection):void  { _connection = value; }

    }
}
