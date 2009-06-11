package com.mintdigital.hemlock.utils{
    public class DateUtils{
        
        public static const SECONDS:String  = 'dateUtils_seconds';
        public static const MINUTES:String  = 'dateUtils_minutes';
        public static const HOURS:String    = 'dateUtils_hours';
        public static const DAYS:String     = 'dateUtils_days';
        
        public static function secondsBetween(earlierDate:Date, laterDate:Date):int{
            var milliseconds:Number = laterDate.valueOf() - earlierDate.valueOf();
            return Math.round(milliseconds / 1000);
        }
        
        public static function fromNow(amount:uint, units:String):Date{
            // Usage:
            // DateUtils.fromNow(11, DateUtils.MINUTES);
            
            var secondsPerUnit:uint = 0;
            switch(units){
                case SECONDS:   secondsPerUnit = 1; break;
                case MINUTES:   secondsPerUnit = 60; break;
                case HOURS:     secondsPerUnit = 3600; break;
                case DAYS:      secondsPerUnit = 86400; break;
            }
            return new Date(new Date().valueOf() + (amount * secondsPerUnit * 1000));
        }
        
    }
}
