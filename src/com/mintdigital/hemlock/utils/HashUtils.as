package com.mintdigital.hemlock.utils{
    public class HashUtils{
        
        /*
        This class provides helper methods for treating an object literal as a
        more developer-friendly hash.
        */
        
        // TODO: Convert to a Hash class, so that methods can be called on instances?
        // - May need to be a dynamic class for adding methods to prototype
        
        public static function toString(hash:Object):String{
            var parts:Array /* of Strings */ = [];
            for(var key:String in hash){
                parts.push(key + ' = ' + hash[key]);
            }
            return '[Hash : ' + parts.join(' | ') + ']';
        }
        
        public static function merge(defaults:Object, replacements:Object = null):Object{
            // Merges `defaults` (string : *) with `replacements` Ruby-style:
            // `defaults` are the base, and `replacements` overwrite them.
            // Returns the result without modifying `defaults`.
            
            if(!replacements){ return defaults; }
            
            var results:Object = {};
            
            // Copy defaults to results
            for(var key:String in defaults){ results[key] = defaults[key]; }
            
            // Overwrite results with replacements
            for(key in replacements){ results[key] = replacements[key]; }
            
            return results;   
        }
        
        public static function except(hash:Object, keysToRemove:Array):Object{
            // Removes key-values pairs from `hash` where the key is in
            // `keysToRemove`. Returns the result without modifying `hash`.
            
            if(!keysToRemove || keysToRemove.length == 0){ return hash; }
            
            var results:Object = {};
            for(var key:String in hash){
                if(keysToRemove.indexOf(key) == -1){
                    results[key] = hash[key];
                }
            }
            return results;
        }
        
        public static function keys(hash:Object):Array{
            var keys:Array /* of Strings */ = [];
            for(var key:String in hash){
                keys.push(key);
            }
            return keys;
        }
        
        public static function values(hash:Object):Array{
            var values:Array /* of * */ = [];
            for each(var value:* in hash){
                values.push(value);
            }
            return values;
        }
        
        public static function length(hash:Object):uint{
            var length:uint = 0;
            for(var key:String in hash){ length++; }
            return length;
        }
        
    }
}
