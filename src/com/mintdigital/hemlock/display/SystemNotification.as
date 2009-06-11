package com.mintdigital.hemlock.display{
    import com.mintdigital.hemlock.HemlockEnvironment;
    import com.mintdigital.hemlock.Logger;
    import com.mintdigital.hemlock.utils.HashUtils;
    
    import flash.display.BlendMode;
    import flash.display.GradientType;
    import flash.display.Sprite;
    import flash.display.Stage;
    import flash.text.AntiAliasType;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;


    import flash.display.DisplayObject; // For system notifications
    import flash.utils.setTimeout;      // For system notifications
    
    public class SystemNotification extends HemlockSprite{
        public static const TYPE_MESSAGE:String = 'message';
        public static const TYPE_ERROR:String = 'error';
        
        private var _stage:Stage;
        private var _text:String;

        protected static var _defaultOptions:Object = {
            type:       TYPE_MESSAGE,
            width:      200,
            borderWidth: 2,
            marginN:    10,
            marginS:    10,
            marginW:    10,
            marginE:    10,
            paddingN:   5,
            paddingS:   5,
            paddingW:   10,
            paddingE:   10,
            duration: 10
        };
        private var views:Object = {};
        
        public function SystemNotification(stage:Stage, text:String, options:Object = null){
            options = HashUtils.merge(_defaultOptions, options);
            
            _stage = stage;
            _text = text;
            _options = options;
            // super(options);
            
            createViews();
        }
        
        public function createViews():void{
            Logger.debug('SystemNotification::createViews()');
            
            this.x = _stage.stageWidth - options.width - options.marginE;
            this.y = options.marginN;

            // Create text
            views.text = new TextField();
            views.text.x = options.paddingW;
            views.text.y = options.paddingN;
            views.text.width = options.width - options.paddingW - options.paddingE;
            views.text.autoSize = TextFieldAutoSize.LEFT;
            views.text.embedFonts = true;
            views.text.textColor = 0xFFFFFF;
            views.text.text = _text;
            views.text.wordWrap = true;
            
            // Create text format
            var textFormat:TextFormat = new TextFormat();
            textFormat.color = 0xFFFFFF;
            textFormat.font = HemlockEnvironment.SKIN.FONT_PRIMARY;
            textFormat.size = 14;
            views.text.setTextFormat(views.text.defaultTextFormat = textFormat);
            
            // Create background
            // TODO: Draw directly to graphics of `this` -- no new sprite needed
            views.background = new Sprite();
            with(views.background.graphics){
                beginGradientFill(GradientType.LINEAR, [0x000000, 0x000000], [0.8, 1], [0x11, 0x44], HemlockSprite.getVerticalMatrix());
                    // TODO: Change background color to red if type == TYPE_ERROR
                lineStyle(options.borderWidth, 0x000000);
                drawRoundRect(0, 0, options.width, views.text.height + options.paddingN + options.paddingS, 20);
                endFill();
            }
            
            addChild(views.background);
            addChild(views.text);
        }

        public function displayIn(container:Sprite, callback:Function):void {
            var notifDisplayObject:DisplayObject = container.addChild(this);

            setTimeout(function():void{
                dropOut({
                    onComplete: function():void{
                        container.removeChild(notifDisplayObject);
                        callback();
                        // TODO: Remove `notif` from queue; ensure that notifs are removed in correct order
                    }
                });
            }, options.duration * 1000);
            
        }
        
        
        
        //--------------------------------------
        //  Internal helpers
        //--------------------------------------
        
        // ...
        
    }
}
