package com.mintdigital.hemlock.utils{
    public class NumberUtils{
        
        public static function ordinalize(theInt:int):String{
            var ord:String, lastDigit:uint = theInt % 10;
            
            if(theInt == 11 || theInt == 12 || theInt == 13){
                ord = theInt + 'th';
            }else{
                switch(lastDigit){
                    case 1:     ord = theInt + 'st'; break;
                    case 2:     ord = theInt + 'nd'; break;
                    case 3:     ord = theInt + 'rd'; break;
                    default:    ord = theInt + 'th'; break;
                }
            }
            
            return ord;
        }
        
    }
}
