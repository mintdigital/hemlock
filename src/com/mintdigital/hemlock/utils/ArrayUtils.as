package com.mintdigital.hemlock.utils{
    public class ArrayUtils{
        
        public static function max(array:Array /* of Numbers */):Number{
            var value:Number = array[0];
            for(var i:uint = 1, max:uint = array.length; i < max; i++){
                if(array[i] > value){ value = array[i]; }
            }
            return value;
        }
        
        public static function min(array:Array /* of Numbers */):Number{
            var value:Number = array[0];
            for(var i:uint = 1, max:uint = array.length; i < max; i++){
                if(array[i] < value){ value = array[i]; }
            }
            return value;
        }
        
        public static function map(originalArray:Array /* of * */, attribute:String):Array{
            // Before:
            // array.map(function(item:*, index:int, array:Array):uint{ return item.id });
            
            // After:
            // ArrayUtils.map(array, 'id');
            
            return originalArray.map(function(item:*, index:int, array:Array):*{
                return item[attribute];
            });
        }
        
        public static function rand(array:Array /* of * */):*{
            // Returns a random element in `array`.
            
            return array[Math.floor(Math.random() * array.length)];
        }
        
        public static function toSentence(array:Array /* of Strings */):String{
            // Input:               Output:
            // ['A', 'B', 'C']      'A, B, and C'
            // ['A', 'B']           'A and B'
            // ['A']                'A'
            
            // Ported from Ruby on Rails, Array#to_sentence
            
            // TODO: Add options support for wordsConnector, etc.
                        
            var sentence:String = array[0],
                numItems:uint = array.length,
                wordsConnector:String = ', ',
                twoWordsConnector:String = ' and ',
                lastWordConnector:String = ', and ';
            switch(numItems){
                case 0:     sentence = ''; break;
                case 1:     sentence = array[0]; break;
                case 2:     sentence = array[0] + twoWordsConnector + array[1]; break;
                default:    sentence = array.slice(0, numItems - 1).join(wordsConnector)
                                + lastWordConnector + array[numItems - 1]; break;
            }
            return sentence;
        }
        
    }
}
