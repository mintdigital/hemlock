package com.mintdigital.hemlock.controls{
    import com.mintdigital.hemlock.HemlockEnvironment;
    import com.mintdigital.hemlock.display.HemlockSprite;
    import com.mintdigital.hemlock.utils.HashUtils;
    
    import flash.display.BlendMode;
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    // import flash.geom.Rectangle;
    import flash.text.AntiAliasType;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormatAlign;
    import flash.text.TextFormat;
    
    public class HemlockButton extends HemlockControl{
        // Usage:
        // - new HemlockButton('participants-' + user.jid.toString(), user);
        // - new HemlockButton('participants-' + user.jid.toString(), user, {
        //      label: user.nickname
        //   });
        
        private var _labelTextField:TextField;
        private var _disabled:Boolean;
        private var overlay:Sprite;
        protected static var _defaultOptions:Object = {
            width:          skin.BUTTON_WIDTH || 125,
            height:         skin.BUTTON_HEIGHT || 30,
            bg:             skin.ButtonBasic,
            bgHover:        skin.ButtonBasicHover,
            bgActive:       skin.ButtonBasicActive,
            color:          skin.BUTTON_COLOR,
            colorHover:     skin.BUTTON_HOVER_COLOR,
            colorActive:    skin.BUTTON_ACTIVE_COLOR,
            fontFamily:     skin.FONT_PRIMARY,
            fontSize:       14,
            // fontWeight:     'bold',
            label:          null // String
        };
        
        public function HemlockButton(name:String, value:Object, options:Object = null){
            options = HashUtils.merge(_defaultOptions, options);
            
            var label:Object = value;
            
            // Add button backgrounds
            var background:DisplayObject;
            var backgrounds:Object = {};
            backgrounds[STATE_NORMAL]   = addChild(new options.bg());
            backgrounds[STATE_HOVER]    = addChild(new options.bgHover());
            backgrounds[STATE_ACTIVE]   = addChild(new options.bgActive());
            
            // Set dimensions
            for each(background in backgrounds){
                background.width = options.width;
                background.height = options.height;
            }
            
            // Set label
            if(options.label is String){
                // Button labels can be either text (automatically handled
                // below) or some other object, like an image. To add a
                // non-text label to a button, leave options.label null,
                // then manually call addChild() to add and position
                // button contents.
                
                addTextLabel(options.label, options);
            }
            
            // Add invisible "button" sprite; exists only for changing cursor
            overlay = new Sprite();
            with(overlay.graphics){
                // Fill sprite graphics to prop it open to given size
                beginFill(0x000000, 0);
                drawRect(0, 0, options.width, options.height);
                endFill();
            }
            addChild(overlay);
            with(overlay){
                width       = options.width;
                height      = options.height;
                buttonMode  = true; // Changes to hand pointer on hover
            }
            
            super(name, value, options);

            _backgrounds = backgrounds;
            switchState(STATE_NORMAL);
            
            registerListeners();
            startListeners();
        }
        
        public function disable(options:Object = null):void{
            /*
            Usage:
            - button.disable();
            - button.disable({ label: 'Saving...' });
            */
            
            if(!options){ options = {}; }
            
            // Dim button
            alpha = 0.5;
            blendMode = BlendMode.LAYER;

            // Change text
            if(options.label){ label = options.label; }
            
            // Remove event listeners
            stopListeners();
            _disabled = true;
        }
        
        public function enable():void{
            // CAUTION: Not tested yet!
            
            // Un-dim button
            alpha = 1;
            
            // Reset to original text
            label = options.label;
            
            // Re-add event listeners
            startListeners();
            _disabled = false;
        }
        
        
        
        //--------------------------------------
        //  Events
        //--------------------------------------
        
        override public function registerListeners():void{
            registerListener(overlay,   MouseEvent.MOUSE_OVER,  onMouseEvent);
            registerListener(overlay,   MouseEvent.MOUSE_OUT,   onMouseEvent);
            registerListener(overlay,   MouseEvent.MOUSE_UP,    onMouseEvent);
            registerListener(overlay,   MouseEvent.MOUSE_DOWN,  onMouseEvent);
        }
        
        private function onMouseEvent(event:MouseEvent):void{
            // Logger.debug('HemlockButton::onMouseEvent() : type = ' + event.type);
            
            switch(event.type){
                case MouseEvent.MOUSE_OUT:
                    switchState(STATE_NORMAL);
                    break;
                case MouseEvent.MOUSE_OVER:
                case MouseEvent.MOUSE_UP:
                    switchState(STATE_HOVER);
                    break;
                case MouseEvent.MOUSE_DOWN:
                    switchState(STATE_ACTIVE);
                    if(skin.SoundButtonClick){
                        (new skin.SoundButtonClick()).play();
                    }
                    break;
            }
        }
        
        
        
        //--------------------------------------
        //  Internal helpers
        //--------------------------------------
        
        private function addTextLabel(label:String, options:Object):void{
            // Create label
            _labelTextField             = new TextField();
            _labelTextField.autoSize    = TextFieldAutoSize.CENTER;
            _labelTextField.antiAliasType = AntiAliasType.ADVANCED;
            _labelTextField.embedFonts  = true;
            _labelTextField.selectable  = false;
            _labelTextField.text        = label;
            _labelTextField.width       = options.width;
            
            // Style label
            var labelTextFormat:TextFormat = new TextFormat();
            labelTextFormat.align   = TextFormatAlign.CENTER;
            labelTextFormat.bold    = (options.fontWeight == 'bold');
            labelTextFormat.color   = options.color;
            labelTextFormat.font    = options.fontFamily;
            labelTextFormat.size    = options.fontSize;
            _labelTextField.setTextFormat(_labelTextField.defaultTextFormat = labelTextFormat);
            
            // Add label
            addChild(_labelTextField);
            _labelTextField.x = (options.width  - _labelTextField.width)  * 0.5;
            _labelTextField.y = (options.height - _labelTextField.height) * 0.5;
        }
        
        override public function switchState(newState:String):void{
            super.switchState(newState);
            
            if(_labelTextField){
                var newLabelFormat:TextFormat = _labelTextField.defaultTextFormat;
                switch(newState){
                    case STATE_NORMAL:
                        newLabelFormat.color = options.color;
                        _labelTextField.setTextFormat(newLabelFormat);
                        break;
                    case STATE_HOVER:
                        newLabelFormat.color = options.colorHover;
                        _labelTextField.setTextFormat(newLabelFormat);
                        break;
                    case STATE_ACTIVE:
                        newLabelFormat.color = options.colorActive;
                        _labelTextField.setTextFormat(newLabelFormat);
                        break;
                }
            }
        }
        
        
        
        //--------------------------------------
        //  Properties
        //--------------------------------------
        
        public function get labelTextField():TextField  { return _labelTextField; }
        
        public function get label():String              { return _labelTextField.text; }
        public function set label(value:String):void    { _labelTextField.text = value; }
        
        public function get disabled():Boolean          { return _disabled; }

        public static function get defaultOptions():Object              { return _defaultOptions; }
        public static function set defaultOptions(value:Object):void    { _defaultOptions = value; }
        
    }
}
