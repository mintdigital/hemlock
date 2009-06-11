package com.mintdigital.hemlock{
    import com.mintdigital.hemlock.utils.URLUtils;
    import flash.external.ExternalInterface;
    
    public class HemlockEnvironment{
        public static const ENVIRONMENT_DEVELOPMENT:String  = 'development';
        public static const ENVIRONMENT_STAGING:String      = 'staging';
        public static const ENVIRONMENT_PRODUCTION:String   = 'production';
        
        // Used to determine if we've checked for a custom value yet;
        // essentially, these flags allow us to cache a non-default
        // value for either of these variables.
        private static var _debugFlag:Boolean = false;
        
        // Used to actually hold the cached variable values.
        private static var _debugValue:Boolean;
        
        public static var ENVIRONMENT:String;
        public static var SERVER:String;
        public static var POLICY_PORT:String = '8040';
        public static var SOURCE_PATH:String;
        public static var _debug:Boolean;
        public static var SKIN:*;
        public static var API_PATH:String;
        public static var SHARED_OBJECT_SESSION_NAME:String;
        
        
        
        //--------------------------------------
        //  Helpers
        //--------------------------------------
        
        public static function isDevelopment():Boolean{
            return ENVIRONMENT == ENVIRONMENT_DEVELOPMENT;
        }
        
        public static function isStaging():Boolean{
            return ENVIRONMENT == ENVIRONMENT_STAGING;
        }
        
        public static function isProduction():Boolean{
            return ENVIRONMENT == ENVIRONMENT_PRODUCTION;
        }
        
        // Returns a boolean based on whether or not the 
        // application is in debug mode. It first checks
        // do see if we're in an environment that can be 
        // scripted with Javascript. Then it calls a getUrl 
        // method defined in index.html. 
        
        // With the URL in hand, it parses the string to see
        // if there are relevent key value pairs appended, ie:
        // debug=bool. If this pair is present, it assigns that
        // value to _debugValue. If not, it uses the default 
        // defined in the local environment file.
        public static function get debug():Boolean {
            if (!_debugFlag) {
                if (ExternalInterface.available) {
                    var url:String = String(ExternalInterface.call("function() { return window.location.href.toString(); }"));
                        // TODO: Refactor to use com.mintdigital.hemlock.utils.JavaScript
                    var debugParam:String = URLUtils.getParam(url, "debug");
                    _debugValue = debugParam ? debugParam == 'true' : _debug;
                } else {
                    _debugValue = _debug;
                }
                _debugFlag = true;
            }
            // _debugFlag = true;
            // _debugValue = true;
            return _debugValue;
        }
        
    }
}
