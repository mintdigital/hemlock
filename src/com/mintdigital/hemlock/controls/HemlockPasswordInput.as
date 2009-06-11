package com.mintdigital.hemlock.controls{
    public class HemlockPasswordInput extends HemlockTextInput{
        // Usage:
        // - new HemlockPasswordInput('username', '');
        // - new HemlockPasswordInput('username', '', {
        //       width:      150,
        //       fontFamily: skin.FONT_HELVETICA
        //   });
        
        public function HemlockPasswordInput(name:String, value:Object, options:Object = null){
            super(name, value, options);
            _textField.displayAsPassword = true;
        }
        
        
        
        //--------------------------------------
        //  Properties
        //--------------------------------------
        
        public static function get defaultOptions():Object              { return _defaultOptions; }
        public static function set defaultOptions(value:Object):void    { _defaultOptions = value; }
        
    }
}
