package com.mintdigital.hemlock.controls{
    import com.mintdigital.hemlock.HemlockEnvironment;
    import com.mintdigital.hemlock.display.HemlockSprite;
    
    import flash.display.BlendMode;
        
    public class HemlockControl extends HemlockSprite{
        private var _value:Object;
            // _value: Internal value to be returned when the control is
            // activated via user interaction, such as clicking a
            // HemlockButton or modifying a HemlockTextField.
        protected var _backgrounds:Object = {}; /* of string : Sprite */
        
        public static const STATE_NORMAL:String     = 'normal';
        public static const STATE_HOVER:String      = 'hover';
        public static const STATE_ACTIVE:String     = 'active';
        public static const STATE_FOCUS:String      = 'focus';
        public static const STATE_CHECKED:String    = 'checked';
        
        public function HemlockControl(name:String, value:Object, options:Object = null){
            if(!options){ options = {}; }
            
            this.name = name;
            this.value = value;
            
            super(options);
            // TODO: Call registerListeners() and startListeners() automatically?
        }
        
        /*
        // TODO: Add disable()/enable() support for controls
        // - Call registerListener() on the control instead of the widget;
        //   see HemlockButton
        public function disable():void{
            stopListeners();
            alpha = 0.5;
            blendMode = BlendMode.LAYER;
        }
        
        public function enable():void{
            startListeners();
            alpha = 1;
        }
        */
        // TODO: Add disable()/enable() overrides for HemlockTextInput: _textField.type = TextFieldType.DYNAMIC/INPUT, respectively
        
        public function focus():HemlockControl{
            if(stage){ stage.focus = this; }
            return this;
        }
        
        public function switchState(newState:String):void{
            // newState: STATE_NORMAL, STATE_HOVER, etc.
            
            for(var state:String in _backgrounds){
                _backgrounds[state].visible = (state == newState);
            }
        }
        
        
        
        //--------------------------------------
        //  Properties
        //--------------------------------------
        
        public function get value():Object              { return _value; }
        public function set value(newValue:Object):void { _value = newValue; }
        
        public function get backgrounds():Object        { return _backgrounds; }
        
        public static function get skin():*             { return HemlockEnvironment.SKIN; }
        
    }
}
