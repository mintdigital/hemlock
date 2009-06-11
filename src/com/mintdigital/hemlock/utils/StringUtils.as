package com.mintdigital.hemlock.utils{
    public class StringUtils{
        
        public static function trim(string:String):String{
            // Removes whitespace from both ends of `string`.
            return string ? string.replace(/^\s*(.*)\s*$/, "$1") : '';
        }
        
        public static function isBlank(string:String):Boolean{
            // Returns true if `string` is empty or contains only whitespace.
            return string ? (string.match(/^[\s]*$/) != null) : true;
        }
        
        public static function escapeHTML(string:String):String{
            // Returns `string` with key HTML characters escaped.
            return string
                ? string.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
                : '';
        }
        
    }
}
