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

            var escapedArg:String;
            args.forEach(function(arg:*, index:int, array:Array):void{
                escapedArg = arg.replace(new RegExp('"', 'gm'), '\\"');
                run('function(){ alert("' + escapedArg + '"); }');
            });
        }
        
        public static function log(...args):void{
            if(!ExternalInterface.available){
                Logger.error('JavaScript::log() : ExternalInterface not available.');
                return;
            }

            var escapedArg:String;
            args.forEach(function(arg:*, index:int, array:Array):void{
                escapedArg = arg.replace(new RegExp('"', 'gm'), '\\"');
                run(
                    (<![CDATA[ function(){
                        if(window.console && window.console.log){
                            window.console.log("{{arg}}");
                        }else{
                            alert("{{arg}}");
                        }
                    } ]]>).toString().
                        replace(new RegExp('{{arg}}', 'gm'), escapedArg)
                );
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
