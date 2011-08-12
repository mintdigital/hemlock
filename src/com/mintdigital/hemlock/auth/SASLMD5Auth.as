package com.mintdigital.hemlock.auth {
    import com.mintdigital.hemlock.HemlockEnvironment;
    import com.mintdigital.hemlock.Logger;
    import com.mintdigital.hemlock.conn.IConnection;
    import com.mintdigital.hemlock.events.ChallengeEvent;
    
    import com.dynamicflash.util.Base64;
    
    import com.gsolo.encryption.MD5;
    
     public class SASLMD5Auth extends SASLAuth{

        private var _username:String;
        private var _password:String;
        private var _server:String;
        private var _firstChallengeHandled:Boolean;
        
        public function SASLMD5Auth(args:Object){
            super(args.connection);
            _username   = args.username;
            _password   = args.password;
            _server     = args.server || HemlockEnvironment.SERVER;
        }
        
        override public function start():void{
            Logger.debug('SASLMD5Auth::start()');
            
            connection.addEventListener(ChallengeEvent.CHALLENGE, onChallenge);
            _firstChallengeHandled = false;
            connection.send(authRequest());
        }
        
        
        
        //--------------------------------------
        //  Events > Handlers
        //--------------------------------------
        
        private function handleFirstChallenge(ev:ChallengeEvent):void{
            var decoded_data:String = Base64.decode(ev.data);
            Logger.debug("... " + decoded_data);
            
            var tuples:Array = decoded_data.split(",");
            var nonce:String;
            var qop:String;
            
            Logger.debug("tuples: " + tuples.length)
            for (var i:int = 0; i<tuples.length; i++){
                Logger.debug("... " + i + ": " + tuples[i]);
                var kvs:Array = tuples[i].split("=");
                var key:String = kvs[0];
                var value:String = kvs[1];
                switch (key){
                    case "nonce" :
                        nonce = unquoted(value);
                        break;
                    case "qop" : 
                        qop = unquoted(value);
                        break;
                    default:
                        break;
                }
            }
            
            Logger.debug("nonce = " + nonce);
            Logger.debug("qop = " + qop);
        
            connection.send(responseXML(nonce));
            _firstChallengeHandled = true;
        }
        
        private function handleSecondChallenge(ev:ChallengeEvent):void{
            connection.send("<response xmlns='" + SASLAuth.XMLNS + "' />");
        }
        
        private function onChallenge(ev:ChallengeEvent):void{
            Logger.debug("SASLMD5Auth::onChallenge() " + ev.data);
            if (!_firstChallengeHandled){
                handleFirstChallenge(ev);
            }else{
                handleSecondChallenge(ev);
            }
        }
        
        override public function stop() : void {
            connection.removeEventListener(ChallengeEvent.CHALLENGE, onChallenge);
        }
        

        
        //--------------------------------------
        //  Internal helpers
        //--------------------------------------
        
        private function authRequest() : String {
            return "<auth xmlns='" + SASLAuth.XMLNS + "' mechanism='" +
                    SASLAuth.MECHANISM_DIGEST_MD5 + "'/>";
        }
        
        private function h(value:String) : String {
            return MD5.rstr_md5 (MD5.str2rstr_utf8 (value))
        }
        
        private function hh(value:String) : String {
            return MD5.hex_md5_raw(value)
        }

        public function test() : void {
            Logger.debug("SASLMD5Auth::test()");
            username = "TEST_USERNAME";
            password = "TEST_PASSWORD";
            var res:String = responseValue(
                username,
                server,
                'xmpp/' + server,
                password,
                "2365057907",
                "4da1f5911223553007f3548ea3",
                "auth");
            Logger.debug("response: " + res);
            
            Logger.debug("fullresponse: " + responseString("2544981027"));
            Logger.debug("encoded: " + Base64.encode(responseString("2544981027")));
            Logger.debug("XML: " + responseXML("2544981027"));
            
        }
        
        private function quoted(value:String) : String {
            return '"' + value + '"';
        }
        
        private function unquoted(value:String) : String {
            return value.substr(1,value.length-2);
        }
        
        private function joined(strings:Array) : String {
            var result:String = "";
            for (var i:int = 0; i<strings.length - 1; i++){
                result = result + strings[i] + ","
            }
            result = result + strings[strings.length - 1];
            return result;
        }
        
        private function responseXML(nonce:String) : String {
            return "<response xmlns='" + SASLAuth.XMLNS + "'>" +
                    Base64.encode(responseString(nonce)) + "</response>";
        }
        
        private function responseString(nonce:String) : String
        {
            var cnonce:String = hh((new Date()).toString());
            
            Logger.debug("Generating response with:");
            Logger.debug("- username: " + username);
            Logger.debug("- password: " + password);
            Logger.debug("- nonce: "    + nonce);
            Logger.debug("- cnonce: "   + cnonce);
            
            
            
            var tuples:Array = [
                "username=" + quoted(username),
                "realm=" + quoted(server),
                "nonce=" + quoted(nonce),
                "cnonce=" + quoted(cnonce),
                "nc=00000001",
                "qop=auth",
                'digest-uri=' + quoted('xmpp/' + server),
                "response=" + responseValue(
                    username,
                    server,
                    'xmpp/' + server,
                    password,
                    nonce,
                    cnonce,
                    "auth"),
                "charset=utf-8"
            ];
            
            return(joined(tuples));
        }
        
        
        private function responseValue(username:String, realm:String, digest_uri:String, passwd:String, nonce:String, cnonce:String, qop:String) : String 
        {
            var a1_h:String = h(username + ":" + realm + ":" + passwd);
            var a1:String = a1_h + ":" + nonce + ":" + cnonce;
            var a2:String = "AUTHENTICATE:" + digest_uri;
            
            return (hh(hh(a1) + ":" + nonce + ":00000001:" + cnonce + ":" + qop + ":" + hh(a2)));
        }
        
        
        
        //--------------------------------------
        //  Properties
        //--------------------------------------
        
        public function get username():String           { return _username; }
        public function set username(value:String):void { _username = value; }
        
        public function get password():String           { return _password; }
        public function set password(value:String):void { _password = value; }
        
        public function get server():String             { return _server; }
        public function set server(value:String):void   { _server = value; }

    }
}
