package com.mintdigital.hemlock.display{
    import com.mintdigital.hemlock.controls.HemlockControl;
    import com.mintdigital.hemlock.utils.HashUtils;
    import com.mintdigital.hemlock.HemlockEnvironment;
    import flash.display.DisplayObject;
    import flash.events.MouseEvent;
    import flash.text.AntiAliasType;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;
    
    public class HemlockLabel extends HemlockSprite{
        // Usage:
        // - new HemlockLabel('Username:', views.username);
        // - new HemlockLabel('Username:', views.username, {
        //      size: 24
        //   });

        private static const LABEL_NAME_SUFFIX:String = ' (LABEL)';

        private var _content:DisplayObject;
        private var _target:Object;
        protected static var _defaultOptions:Object = {
            width:      200,
            height:     18,
            color:      HemlockEnvironment.SKIN.LABEL_COLOR || 0x333333,
            fontFamily: HemlockEnvironment.SKIN.FONT_PRIMARY,
            fontSize:   14,
            fontWeight: 'normal',
            textAlign:  TextFormatAlign.LEFT
        };
        
        public function HemlockLabel(content:*, target:HemlockControl, options:Object = null){
            options = HashUtils.merge(_defaultOptions, options);
            
            // Add label content
            if(content is String){
                var textFormat:TextFormat = new TextFormat();
                textFormat.align    = options.textAlign;
                textFormat.bold     = (options.fontWeight == 'bold');
                textFormat.color    = options.color;
                textFormat.font     = options.fontFamily;
                textFormat.size     = options.fontSize;
                
                var newContent:TextField = new TextField();
                newContent.defaultTextFormat = textFormat;
                newContent.width        = options.width;
                newContent.height       = options.height;
                newContent.antiAliasType = AntiAliasType.ADVANCED;
                newContent.embedFonts   = true;
                newContent.selectable   = false;
                newContent.text         = content;
                _content = newContent;
            }else{
                _content = content as DisplayObject;
            }
            addChild(_content);
            
            // Store target
            _target = target;
            
            super(options);
            registerListeners();
            startListeners();
        }
        
        
        
        //--------------------------------------
        //  Events
        //--------------------------------------
        
        override public function registerListeners():void{
            registerListener(this, MouseEvent.CLICK, onMouseClick);
        }
        
        private function onMouseClick(event:MouseEvent):void{
            if(event.type == MouseEvent.CLICK){
                _target.focus();
            }
        }
        
    }
}
