package com.mintdigital.hemlock.display{
    import com.mintdigital.hemlock.HemlockEnvironment;
    import com.mintdigital.hemlock.Logger;
    import com.mintdigital.hemlock.utils.HashUtils;
    
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    import flash.utils.setTimeout;
    
    public class ErrorPopup extends HemlockSprite{
        protected var _text:String;
        protected static var _defaultOptions:Object = {
            width:      200,
            height:     100,
            duration:   15 // Seconds to remain visible
        };
        
        public function ErrorPopup(text:String, options:Object = null){
            Logger.debug('ErrorPopup::ErrorPopup()');
            
            _options = HashUtils.merge(_defaultOptions, options);
            _text = text;
            createViews();
            fadeIn();
        }
        
        public function displayIn(parent:DisplayObjectContainer):void{
            Logger.debug('ErrorPopup::displayIn()');
            
            var displayObject:DisplayObject = parent.addChild(this);
            
            setTimeout(function():void{
                dropOut({
                    onComplete: function():void{
                        parent.removeChild(displayObject);
                        if(options.onComplete){ options.onComplete(); }
                    }
                });
            }, options.duration * 1000);
        }
        
        
        
        //--------------------------------------
        //  Internal helpers
        //--------------------------------------
        
        protected function createViews():void{
            // To override this appearance in your app, create a subclass of
            // this class, and override this function.
            
            Logger.debug('ErrorPopup::createViews()');
            
            with(graphics){
                beginFill(0x990000);
                drawRoundRect(0, 0, options.width, options.height, 10);
                endFill();
            }
            
            var textField:TextField = new TextField();
            with(textField){
                width       = options.width - 20;
                height      = options.height - 20;
                // autoSize    = TextFieldAutoSize.LEFT;
                x           = (options.width  - width)  * 0.5;
                y           = (options.height - height) * 0.5;
                embedFonts  = true;
                selectable  = true; // Allows for easier error copypasting
                text        = _text;
                wordWrap    = true;
            }
            
            var textFormat:TextFormat = new TextFormat();
            with(textFormat){
                color   = 0xFFFFFF;
                font    = HemlockEnvironment.SKIN.FONT_PRIMARY;
                size    = 14;
            }
            textField.setTextFormat(textField.defaultTextFormat = textFormat);
            
            addChild(textField);
            width   = options.width;
            height  = options.height;
            x       = options.x;
            y       = options.y;
            
            // TODO: Apply flash.filters.DropShadowFilter
        }
        
        
        
        //--------------------------------------
        //  Properties
        //--------------------------------------
        
        public function get text():String   { return _text; }
            // If a setter is implemented, it should update _text and the
            // TextField view.
        
    }
}
