package com.mintdigital.hemlock.utils{
    public class URLUtils{
        
        private static var _url:String;
        private static var _pairs:Object;
        
        public static function getParam(url:String, key:String):String {
            _url = url;
            _pairs = {};
            return pairs[key];
        }
        
        private static function get pairs():Object {
            var pair:Array;
            var urlParams:Array = _url.match(/[\?\&]([\S]*?)(?=(?:\&|\Z))/i);
            
            _pairs = {};
            if (urlParams) {
                urlParams.forEach(function(el:*, i:int, a:Array):void {
                    pair = el.split("=");
                    _pairs[pair[0]] = pair[1];
                });
            }
            return _pairs;
        }
        
    }
}
