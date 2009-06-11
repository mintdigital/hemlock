package com.mintdigital.hemlock.utils{
    import com.mintdigital.hemlock.Logger;
    
    import flash.external.ExternalInterface;

    public class JavaScript{
        
        public static function run(...args):void{
            if(!ExternalInterface.available){
                Logger.error('JavaScript::run() : ExternalInterface not available.');
                return;
            }

            args.forEach(function(arg:*, index:int, array:Array):void{
                ExternalInterface.call('(' + arg + ')');
            });
        }
        
        public static function alert(...args):void{
            if(!ExternalInterface.available){
                Logger.error('JavaScript::alert() : ExternalInterface not available.');
                return;
            }

            args.forEach(function(arg:*, index:int, array:Array):void{
                run('function(){ alert("' + arg + '"); }');
                    // TODO: Add escaping of double quotes
            });
        }
        
        public static function log(...args):void{
            if(!ExternalInterface.available){
                Logger.error('JavaScript::log() : ExternalInterface not available.');
                return;
            }
            
            args.forEach(function(arg:*, index:int, array:Array):void{
                run('function(){ if(console && console.log){ console.log("' + arg + '"); }else{ alert("' + arg + '"); } }');
                    // TODO: Add escaping of double quotes
            });
        }
        
        public static function redirect(location:String):void{
            if(!ExternalInterface.available){
                Logger.error('JavaScript::redirect() : ExternalInterface not available.');
                return;
            }
            
            run('function(){ window.location.href="' + location + '"; }');
        }
        
    }
}
