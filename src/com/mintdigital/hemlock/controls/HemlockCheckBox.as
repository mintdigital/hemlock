package com.mintdigital.hemlock.controls{
    import com.mintdigital.hemlock.utils.HashUtils;
    
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    
    public class HemlockCheckBox extends HemlockControl{
        // Usage:
        // - new HemlockCheckBox('participants-' + user.jid.toString(), user, { ... });
        
        private var _overlay:Sprite;
        private var _checked:Boolean = false;
        protected static var _defaultOptions:Object = {
            // TODO: Create dedicated default assets
            width:          skin.CHECK_BOX_WIDTH || 20,
            height:         skin.CHECK_BOX_HEIGHT || 20,
            bg:             skin.ButtonBasic,
            bgHover:        skin.ButtonBasicHover,
            bgActive:       skin.ButtonBasicActive,
            bgChecked:      skin.ButtonBasicActive,
            checked:        false
        };
        
        public function HemlockCheckBox(name:String, value:Object, options:Object = null){
            options = HashUtils.merge(_defaultOptions, options);
            
            if(options.checked){
                _checked = true;
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
            switchState(STATE_NORMAL);
            
            registerListeners();
            startListeners();
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
            // Logger.debug('HemlockCheckBox::onMouseEvent() : type = ' + event.type);
            
            switch(event.type){
                case MouseEvent.MOUSE_OUT:
                    if(!_checked){ switchState(STATE_NORMAL); }
                    break;
                case MouseEvent.MOUSE_OVER:
                case MouseEvent.MOUSE_UP:
                    if(!_checked){ switchState(STATE_HOVER); }
                    break;
                case MouseEvent.MOUSE_DOWN:
                    switchState(_checked ? STATE_ACTIVE : STATE_CHECKED);
                    _checked = !_checked;
                    if(skin.SoundButtonClick){
                        (new skin.SoundButtonClick()).play();
                    }
                    break;
            }
        }
        
        
        
        //--------------------------------------
        //  Properties
        //--------------------------------------
        
        public static function get defaultOptions():Object              { return _defaultOptions; }
        public static function set defaultOptions(value:Object):void    { _defaultOptions = value; }
        
    }
}
