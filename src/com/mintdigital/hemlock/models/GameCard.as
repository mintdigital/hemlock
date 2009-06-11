package com.mintdigital.hemlock.models{
    // import com.mintdigital.hemlock.Logger;
    import com.mintdigital.hemlock.data.JID;
    import com.mintdigital.hemlock.utils.HashUtils;
    
    public class GameCard{
        private var _name:String;
        private var _value:Object;
        private var _owner:JID;
        
        public function GameCard(name:String, value:Object){
            // name: unique identifier; should be able to look up value based on this
            // value: object hash containing any necessary data for this card
            
            _name = name;
            _value = value;
        }
        
        public function toString(options:Object = null):String{
            options = HashUtils.merge({
                showValues: true
            }, options);
            
            var string:String = '[GameCard : ';
            string += 'name = ' + _name;
            if(options.showValues){
                string += ' | value = ' + HashUtils.toString(_value);
            }
            string += ' | owner = ' + _owner + ']';
            return string;
        }
        
        
        
        //--------------------------------------
        //  Properties
        //--------------------------------------
        
        public function get name():String           { return _name; }
        
        public function get value():Object          { return _value; }
        
        public function get owner():JID             { return _owner; }
        public function set owner(value:JID):void   { _owner = value; }
        
    }
}
