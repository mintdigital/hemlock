package com.mintdigital.hemlock.auth{
    import com.mintdigital.hemlock.conn.IConnection;
    import com.mintdigital.hemlock.Logger;

    public class SASLAnonymousAuth extends SASLAuth{

        /*
        To add support for anonymous login to your Hemlock app:

        1. Open your ejabberd.cfg.
        2. Define your virtual host, e.g. "public.example.org":
            {hosts, ["private.example.org", "public.example.org"]}.
        3. Define your default global authentication, e.g.:
            {auth_method, internal}.
        4. Override the global authentication for your specific host:
            {host_config, "public.example.org", [{auth_method, [anonymous]},
                                                 {anonymous_protocol, sasl_anon}]}.
        5. Restart ejabberd (`ejabberdctl restart`).

        More documentation here, under "SASL anonymous":
        https://support.process-one.net/doc/display/MESSENGER/Anonymous+users+support
        */

        public function SASLAnonymousAuth(connection:IConnection){
            super(connection);
        }

        override public function start():void{
            Logger.debug('SASLAnonymousAuth::start()');

            connection.send(authRequest());
        }

        protected function authRequest():String{
            return "<auth xmlns='" + SASLAuth.XMLNS + "' mechanism='" +
                    SASLAuth.MECHANISM_ANONYMOUS + "'/>";
        }

    }
}
