package com.mintdigital.hemlock.controls{
    import com.mintdigital.hemlock.display.HemlockSprite;
    import com.mintdigital.hemlock.utils.HashUtils;
    import com.mintdigital.hemlock.utils.StringUtils;
    import com.mintdigital.hemlock.HemlockEnvironment;
    
    import flash.display.BlendMode;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.FocusEvent;
    import flash.text.AntiAliasType;
    import flash.text.TextField;
    import flash.text.TextFieldType;
    import flash.text.TextFormat;
    
    public class HemlockTextInput extends HemlockControl{
        // Usage:
        // - new HemlockTextInput('username', '');
        // - new HemlockTextInput('username', '', {
        //       defaultText:  'username',
        //       fontFamily:   skin.FONT_HELVETICA
        //   });
        
        protected var _textField:TextField;
        protected var _defaultText:String;
        protected static var _defaultOptions:Object = {
            x:          0,
            y:          0,
            width:      200,
            height:     skin.TEXT_INPUT_HEIGHT,
            paddingN:   skin.TEXT_INPUT_PADDING_N || 5,
            paddingE:   skin.TEXT_INPUT_PADDING_E || 5,
            paddingS:   skin.TEXT_INPUT_PADDING_S || 5,
            paddingW:   skin.TEXT_INPUT_PADDING_W || 5,
            color:      skin.TEXT_INPUT_COLOR,
            fontFamily: skin.FONT_PRIMARY,
            fontSize:   14,
            type:       TextFieldType.INPUT
        };
        
        public function HemlockTextInput(name:String, value:Object, options:Object = null){
            options = HashUtils.merge(_defaultOptions, options);
            
            // Store value
            if(options.value){ value = options.value; }
            
            // Create backgrounds
            var background:Sprite;
            _backgrounds = {};
            _backgrounds[STATE_NORMAL] = addChild(new skin.BGTextInput());
            // TODO: STATE_HOVER; see HemlockButton
            // TODO: STATE_FOCUS
            
            // Create _textField
            _textField      = new TextField();
            _textField.x    = options.paddingW;
            _textField.y    = options.paddingN;
            _textField.antiAliasType = AntiAliasType.ADVANCED;
            _textField.embedFonts   = true;
            _textField.type         = options.type;
            addChild(_textField);
            
            // Set _textField format
            var textFieldFormat:TextFormat = new TextFormat();
            textFieldFormat.color   = options.color;
            textFieldFormat.font    = options.fontFamily;
            textFieldFormat.size    = options.fontSize;
            _textField.setTextFormat(_textField.defaultTextFormat = textFieldFormat);
                        
            // Set dimensions
            for each(background in _backgrounds){
                background.width = options.width;
                background.height = options.height;
            }
            _textField.width  = options.width  - options.paddingW - options.paddingE;
            _textField.height = options.height - options.paddingN - options.paddingS;
            
            super(name, value, options);
            
            // Create default text, if any
            if(options.defaultText){
                _defaultText = options.defaultText;
                if(value == ''){ showDefaultText(); }
            }
            
            // Pass additional options to _textField, if any
            if(options.maxChars){
                // Default: 0 (no limit)
                _textField.maxChars = options.maxChars;
            }
            if(options.restrict){
                // For restricting the kinds of characters allowed
                _textField.restrict = options.restrict;
            }
            
            switchState(STATE_NORMAL);
            registerListeners();
            startListeners();
            
        }
        
        private function showDefaultText():void{
            // Logger.debug('HemlockTextInput::showDefaultText()');
            _textField.alpha    = 0.5;
            _textField.blendMode = BlendMode.LAYER;
            _textField.text     = _defaultText;
        }
        
        private function hideDefaultText():void{
            _textField.alpha = 1;
            _textField.text = '';
        }
        
        
        
        //--------------------------------------
        //  Events
        //--------------------------------------
        
        override public function registerListeners():void{
            // registerListener(this, MouseEvent.MOUSE_OUT, onMouseEvent); // TODO: Add hover effects
            // registerListener(this, MouseEvent.MOUSE_OVER, onMouseEvent);
            registerListener(_textField, Event.CHANGE, onChange);
            if(_defaultText){
                registerListener(_textField, FocusEvent.FOCUS_IN, onFocusEvent);
                registerListener(_textField, FocusEvent.FOCUS_OUT, onFocusEvent);
            }
        }
        
        private function onChange(event:Event):void{
            value = _textField.text;
        }
        
        private function onFocusEvent(event:FocusEvent):void{
            // Logger.debug('HemlockTextInput::onFocusEvent() : type = ' + event.type);
            
            if(!_defaultText){ return; }
            switch(event.type){
                case FocusEvent.FOCUS_IN:
                    if(event.target.text == _defaultText){
                        hideDefaultText();
                    }
                    break;
                case FocusEvent.FOCUS_OUT:
                    if(StringUtils.isBlank(event.target.text)){
                        showDefaultText();
                    }
                    break;
            }
        }
        
        
        
        //--------------------------------------
        //  Properties
        //--------------------------------------
        
        public function get textField():TextField   { return _textField; }
        public function get defaultText():String    { return _defaultText; }
        
        override public function set value(newValue:Object):void{
            super.value = newValue;
            _textField.text = value as String;
        }
        
        public static function get defaultOptions():Object              { return _defaultOptions; }
        public static function set defaultOptions(value:Object):void    { _defaultOptions = value; }
        
    }
}
