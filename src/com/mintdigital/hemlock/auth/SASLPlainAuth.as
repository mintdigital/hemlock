package com.mintdigital.hemlock.auth{
    import com.mintdigital.hemlock.conn.IConnection;
    import com.mintdigital.hemlock.HemlockEnvironment;
    import com.mintdigital.hemlock.Logger;

    import com.dynamicflash.util.Base64;

    public class SASLPlainAuth extends SASLAuth{

        /*
        For use with `PLAIN` authentication, in which the username and
        password are transmitted insecurely with Base64.

        Useful when using `{auth_method, external}` in `ejabberd.cfg`,
        and the XMPP server forces `PLAIN` authentication instead of something
        secure.
        */

        private var _username:String;
        private var _password:String;
        private var _server:String;

        public function SASLPlainAuth(args:Object){
            super(args.connection);
            _username   = args.username;
            _password   = args.password;
            _server     = args.server || HemlockEnvironment.SERVER;
        }

        override public function start():void{
            Logger.debug('SASLPlainAuth::start()');

            connection.send(authRequest());
        }

        protected function authRequest():String{
            var auth:String = Base64.encode(
                    _username + '@' + _server + '\u0000' +
                    _username + '\u0000' + _password
                );

            return "<auth xmlns='" + SASLAuth.XMLNS + "' mechanism='" +
                    SASLAuth.MECHANISM_PLAIN + "'>" + auth + "</auth>";
        }

    }
}
