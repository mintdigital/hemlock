package com.mintdigital.hemlock{
    import com.mintdigital.hemlock.HemlockEnvironment;

    import flash.events.EventDispatcher;
    
    public class Logger extends EventDispatcher{
        /*
        Usage:
        - Use addLogFunction() to register additional logging methods. For
          example, DebugWidget calls `Logger.addLogFunction(addText)`.
        - To trigger, call `Logger.debug('Some debug string')` or others.
        */
        
        private static var _logFunctions:Array /* of Functions */ = [];
        
        public static function addLogFunction(fn:Function):void{
            _logFunctions.push(fn);
        }
        
        public static function debug(text:String):void{
            logText(text, [
                HemlockEnvironment.ENVIRONMENT_DEVELOPMENT,
                HemlockEnvironment.ENVIRONMENT_STAGING
            ]);
        }
        
        public static function info(text:String):void{
            logText(text, [
                HemlockEnvironment.ENVIRONMENT_DEVELOPMENT,
                HemlockEnvironment.ENVIRONMENT_STAGING
            ]);
        }
        
        public static function warn(text:String):void{
            logText(text, [
                HemlockEnvironment.ENVIRONMENT_DEVELOPMENT,
                HemlockEnvironment.ENVIRONMENT_STAGING
            ]);
        }
        
        public static function error(text:String):void{
            logText(text, [
                HemlockEnvironment.ENVIRONMENT_DEVELOPMENT,
                HemlockEnvironment.ENVIRONMENT_STAGING,
                HemlockEnvironment.ENVIRONMENT_PRODUCTION
            ]);
        }
        
        public static function fatal(text:String):void{
            logText(text, [
                HemlockEnvironment.ENVIRONMENT_DEVELOPMENT,
                HemlockEnvironment.ENVIRONMENT_STAGING,
                HemlockEnvironment.ENVIRONMENT_PRODUCTION
            ]);
            // TODO: Halt execution; flash.system.System.exit()?
        }
        
        
        
        //--------------------------------------
        //  Internal helpers
        //--------------------------------------
        
        private static function logText(text:String, environments:Array):void{
            if(HemlockEnvironment.debug
                    && environments.indexOf(HemlockEnvironment.ENVIRONMENT) >= 0
                ){
                for each(var fn:Function in _logFunctions){
                    fn.call(null, text);
                }
                trace(text);
            }
        }
        
    }
}
