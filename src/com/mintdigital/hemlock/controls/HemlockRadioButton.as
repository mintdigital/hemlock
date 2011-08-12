package com.mintdigital.hemlock.controls{
    // import com.mintdigital.hemlock.Logger;
    import com.mintdigital.hemlock.utils.HashUtils;
    
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.events.MouseEvent;

    public class HemlockRadioButton extends HemlockControl{
        
        // When a radio button is checked, all other radio buttons in its
        // namespace are marked as unchecked. Names should be unique within a
        // namespace.
        
        // Usage:
        // - new HemlockRadioButton('participants', 'participants-' + user.jid.toString(), user, { ... });
        
        private var _namespace:String;
        private var _overlay:Sprite;
        private var _checked:Boolean = false;
        protected static var _instances:Object = {};
            /* <namespace:String> : [ <HemlockRadioButton>, <HemlockRadioButton>, ... ] */
        protected static var _defaultOptions:Object = {
            // TODO: Create dedicated default assets
            width:          skin.RADIO_BUTTON_WIDTH || 20,
            height:         skin.RADIO_BUTTON_HEIGHT || 20,
            bg:             skin.ButtonBasic,
            bgHover:        skin.ButtonBasicHover,
            bgActive:       skin.ButtonBasicActive,
            bgChecked:      skin.ButtonBasicActive,
            checked:        false
        };
        
        public function HemlockRadioButton(namespace:String, name:String, value:Object, options:Object = null){
            options = HashUtils.merge(_defaultOptions, options);
            
            _namespace = namespace;
            if(!_instances[namespace]){
                _instances[namespace] = [];
            }
            
            // Add backgrounds
            var background:DisplayObject;
            var backgrounds:Object = {};
            backgrounds[STATE_NORMAL]   = addChild(new options.bg());
            backgrounds[STATE_HOVER]    = addChild(new options.bgHover());
            backgrounds[STATE_ACTIVE]   = addChild(new options.bgActive());
            backgrounds[STATE_CHECKED]  = addChild(new options.bgChecked());
            
            // Set dimensions
            for each(background in backgrounds){
                background.width = options.width;
                background.height = options.height;
            }
            
            // Add invisible "button" sprite; exists only for changing cursor
            _overlay = new Sprite();
            with(_overlay.graphics){
                // Fill sprite graphics to prop it open to given size
                beginFill(0x000000, 0);
                drawRect(0, 0, options.width, options.height);
                endFill();
            }
            addChild(_overlay);
            with(_overlay){
                width       = options.width;
                height      = options.height;
                buttonMode  = true; // Changes to hand pointer on hover
            }
            
            super(name, value, options);

            _backgrounds = backgrounds;
            checked = !!options.checked;
            
            registerListeners();
            startListeners();
            
            _instances[namespace].push(this);
        }
        
        
        
        //--------------------------------------
        //  Events
        //--------------------------------------
        
        override public function registerListeners():void{
            registerListener(_overlay,  MouseEvent.MOUSE_OVER,  onMouseEvent);
            registerListener(_overlay,  MouseEvent.MOUSE_OUT,   onMouseEvent);
            registerListener(_overlay,  MouseEvent.MOUSE_UP,    onMouseEvent);
            registerListener(_overlay,  MouseEvent.MOUSE_DOWN,  onMouseEvent);
        }
        
        private function onMouseEvent(event:MouseEvent):void{
            // Logger.debug('HemlockRadioButton::onMouseEvent() : type = ' + event.type);
            
            switch(event.type){
                case MouseEvent.MOUSE_OUT:
                    switchState(checked ? STATE_CHECKED : STATE_NORMAL);
                    break;
                case MouseEvent.MOUSE_OVER:
                case MouseEvent.MOUSE_UP:
                    switchState(checked ? STATE_CHECKED : STATE_HOVER);
                    break;
                case MouseEvent.MOUSE_DOWN:
                    switchState(checked ? STATE_CHECKED : STATE_ACTIVE);
                    checked = true;
                    if(skin.SoundButtonClick){
                        (new skin.SoundButtonClick()).play();
                    }
                    break;
            }
        }
        
        
        
        //--------------------------------------
        //  Properties
        //--------------------------------------
        
        public static function get defaultOptions():Object          { return _defaultOptions; }
        public static function set defaultOptions(value:Object):void{ _defaultOptions = value; }
        
        public function get namespace():String          { return _namespace; }
        
        public function get checked():Boolean           { return _checked; }
        public function set checked(value:Boolean):void {
            if(value){
                // Uncheck all other radio buttons in this namespace
                for each(var button:HemlockRadioButton in _instances[namespace]){
                    button.checked = false;
                }
            }
            _checked = value;
            if(!checked){
                // If button is changing to checked, switchState() is called
                // in onMouseEvent().
                switchState(STATE_NORMAL);
            }
        }
        
    }
}
