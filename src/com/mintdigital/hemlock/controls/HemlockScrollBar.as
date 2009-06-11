package com.mintdigital.hemlock.controls{
    import com.mintdigital.hemlock.HemlockEnvironment;
    import com.mintdigital.hemlock.Logger;
    import com.mintdigital.hemlock.utils.HashUtils;
    
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Rectangle;
    import flash.text.TextField;
    
    public class HemlockScrollBar extends HemlockControl{
        public static const HORIZONTAL:String   = 'h';
        public static const VERTICAL:String     = 'v';
        public static const NAME_SUFFIX:String  = '_scrollbar';
        
        public var views:Object = {};
        private var _content:DisplayObject;
        private var _contentSize:Number;
        private var positionProperty:String;    // 'y' if vertical, 'x' if horizontal
        private var sizeProperty:String;        // 'height' if vertical, 'width' if horizontal
        private var contentIsTextField:Boolean;
        private var _percentage:Number = 0.0;
        private var isVertical:Boolean;
        protected static var _defaultOptions:Object = {
            direction:      VERTICAL,
            thickness:      skin.SCROLL_BAR_THICKNESS || 20,
                                // Width if vertical, height if horizontal
            minThumbSize:   skin.SCROLL_BAR_LENGTH || 15,
                                // Height if vertical, width if horizontal
            colors: {
                bg:     0xCCCCCC, // Set null to be transparent
                thumb:  0xEEEEEE
            }
        };
        
        public function HemlockScrollBar(content:DisplayObject, options:Object = null){
            _content = content;
            contentIsTextField = (_content is TextField);
            
            options = HashUtils.merge(_defaultOptions, options);
            switch(options.direction){
                case VERTICAL:
                    options.width   = options.thickness;
                    options.height  = _content.height;
                    isVertical      = true;
                    positionProperty= 'y';
                    sizeProperty    = 'height';
                    break;
                case HORIZONTAL:
                    options.width   = _content.width;
                    options.height  = options.thickness;
                    isVertical      = false;
                    positionProperty= 'x';
                    sizeProperty    = 'width';
                    break;
                default:
                    Logger.fatal('HemlockScrollBar::HemlockScrollBar() : Invalid direction: ' + options.direction);
                    break;
            }
            if(!options.name){
                options.name = content.name + NAME_SUFFIX;
            }
            
            super(options.name, '', options);
            
            createViews();
            registerListeners();
            startListeners();
        }
        
        public function createViews():void{
            // http://www.actionscript.org/forums/archive/index.php3/t-88342.html
            
            if(!contentIsTextField){
                // Crop content
                content.scrollRect = new Rectangle(0, 0, content.width, content.height);
                    // Assumes that content currently has intended dimensions
                    // TODO: Accept options contentWidth and contentHeight
                    // - Use these options when setting scrollbar dimensions
            }
            
            if(isVertical){
                var sizes:Object = {
                    bg:     { width: options.width, height: options.height },
                    thumb:  { width: options.width, height: 50 }
                };
                var useCustomColors:Boolean = (options.colors != defaultOptions.colors);
                
                // Create background
                if(skin.ScrollBarVerticalBG && !useCustomColors){
                    views.bg = new skin.ScrollBarVerticalBG();
                    sizes.bg.width = skin.SCROLL_BAR_THICKNESS;
                }else{
                    // TODO: Create rounded ends
                    // - Update setSize() and updateThumbSize() also
                    
                    views.bg = new Sprite();
                    with(views.bg.graphics){
                        if(options.colors && options.colors.bg){
                            beginFill(options.colors.bg);
                        }else{
                            beginFill(0, 0); // Prop open
                        }
                        drawRect(0, 0, sizes.bg.width, sizes.bg.height);
                        endFill();
                    }
                }
                views.bg.width  = sizes.bg.width;
                views.bg.height = sizes.bg.height;

                // Create scroll thumb
                if(skin.ScrollBarVerticalThumb && !useCustomColors){
                    views.thumb = new skin.ScrollBarVerticalThumb();
                    sizes.thumb.width = skin.SCROLL_BAR_THICKNESS;
                }else{
                    // TODO: Create rounded ends
                    // - Update updateThumbSize() also
                    
                    views.thumb = new Sprite();
                    with(views.thumb.graphics){
                        if(options.colors && options.colors.thumb){
                            beginFill(options.colors.thumb);
                        }else{
                            beginFill(0, 0); // Prop open
                        }
                        drawRect(0, 0, sizes.thumb.width, sizes.thumb.height);
                        endFill();
                    }
                }
                views.thumb.width   = sizes.thumb.width;
                views.thumb.height  = sizes.thumb.height;
                
                // Create scroll thumb grip
                if(skin.ScrollBarVerticalThumbGrip && !useCustomColors){
                    // TODO: Use updateThumbGrip() instead?
                    views.thumbGrip = new skin.ScrollBarVerticalThumbGrip();
                    sizes.thumbGrip = {
                        width:  skin.SCROLL_BAR_THUMB_GRIP_THICKNESS,
                        height: skin.SCROLL_BAR_THUMB_GRIP_LENGTH
                    };
                    
                    // views.thumb.addChild(views.thumbGrip);
                    with(views.thumbGrip){
                        x       = (sizes.thumb.width  - sizes.thumbGrip.width)  * 0.5;
                        y       = (sizes.thumb.height - sizes.thumbGrip.height) * 0.5;
                        width   = sizes.thumbGrip.width;
                        height  = sizes.thumbGrip.height;
                    }
                }
            }else{
                // Create background
                // FIXME: Implement
                
                // Create scroll thumb
                // FIXME: Implement
            }
            
            // Wrap up
            addChild(views.bg);
            addChild(views.thumb);
            if(views.thumbGrip){ addChild(views.thumbGrip); }
            setSize(options.width, options.height);
        }
        
        override public function registerListeners():void{
            registerListener(this,          Event.ADDED_TO_STAGE,       onAddToStage);
            registerListener(this,          Event.REMOVED_FROM_STAGE,   onRemoveFromStage);
            registerListener(views.thumb,   MouseEvent.MOUSE_DOWN,      onScrollThumbMouseDown);
            registerListener(this,          MouseEvent.MOUSE_WHEEL,     onMouseWheel);
            registerListener(content,       MouseEvent.MOUSE_WHEEL,     onMouseWheel);
            registerListener(views.bg,      MouseEvent.CLICK,           onBGClick);
            registerListener(content,       Event.CHANGE,               onContentChange);
        }
        
        override public function setSize(width:Number, height:Number):void{
            views.bg.width  = width;
            views.bg.height = height;
            super.setSize(width, height);
            updateThumbSize();
        }
        
        
        
        //--------------------------------------
        //  Event handlers
        //--------------------------------------
        
        private function onAddToStage(event:Event):void{
            registerListener(stage, MouseEvent.MOUSE_UP, onScrollThumbMouseUp);
            startListeners();
        }
        
        private function onRemoveFromStage(event:Event):void{
            stopListeners();
        }

        private function onScrollThumbMouseDown(event:MouseEvent):void{
            stage.addEventListener(MouseEvent.MOUSE_MOVE, onScrollThumbMouseMove);
                // This should presumably only run after the scrollbar has
                // added to the stage.
            
            var bounds:Rectangle = isVertical
                ? new Rectangle(0, 0, 0, height - views.thumb.height)
                : new Rectangle(0, 0, width - views.thumb.width, 0);
            views.thumb.startDrag(false, bounds);
        }
        
        private function onScrollThumbMouseMove(event:MouseEvent):void{
            event.updateAfterEvent();
                        
            scrollContent(
                views.thumb[positionProperty]
                / (this[sizeProperty] - views.thumb[sizeProperty])
            );
            updateThumbGrip();
        }
        
        private function onScrollThumbMouseUp(event:MouseEvent):void{
            stage.removeEventListener(MouseEvent.MOUSE_MOVE, onScrollThumbMouseMove);
            views.thumb.stopDrag();
        }
        
        private function onMouseWheel(event:MouseEvent):void{
            var newPercentage:Number,
                deltaPixels:Number = event.delta * 2;
                    // Higher multiplier => more sensitive to scrolling
            
            if(contentIsTextField){
                newPercentage =
                    (views.thumb[positionProperty] - deltaPixels)
                    / (this[sizeProperty] - views.thumb[sizeProperty]);
            }else{
                newPercentage =
                    ((content.scrollRect[sizeProperty] * percentage) - deltaPixels)
                    / content.scrollRect[sizeProperty];
            }
            
            scrollContent(newPercentage);
            updateThumbPosition();
        }
        
        private function onBGClick(event:MouseEvent):void{
            // Scrolls content by one page.
            
            var newPercentage:Number = percentage,
                pagePercentage:Number,
                clickCoord:Number = event[isVertical ? 'localY' : 'localX'];
            
            if(contentIsTextField){
                var textField:TextField = content as TextField;
                pagePercentage =
                    textField[sizeProperty]
                    / textField[isVertical ? 'textHeight' : 'textWidth'];
            }else{
                pagePercentage = content.scrollRect[sizeProperty] / contentSize;
            }
            if(clickCoord < views.thumb[positionProperty]){
                newPercentage = percentage - pagePercentage;
            }else if(clickCoord > views.thumb[positionProperty] + views.thumb[sizeProperty]){
                newPercentage = percentage + pagePercentage;
            }
            
            scrollContent(newPercentage);
            updateThumbPosition();
        }
        
        private function onContentChange(event:Event):void{
            _contentSize = -1;
            updateThumbSize();
        }
        
        
        
        //--------------------------------------
        //  Internal helpers
        //--------------------------------------
        
        private function updateThumbSize():void{
            var thumbSize:Number = 0;
            
            if(contentIsTextField){
                thumbSize =
                    this[sizeProperty] * contentSize
                    / (content as TextField)[isVertical ? 'textHeight' : 'textWidth'];
            }else{
                thumbSize = this[sizeProperty] * content.scrollRect[sizeProperty] / contentSize;
            }

            visible = (thumbSize < contentSize);
            startListeners();
                // HemlockSprite listeners are stopped if not visible, but the
                // scrollbar's listeners should stay enabled to listen for
                // content events, e.g., Event.CHANGE.
            if(visible){
                if(thumbSize > contentSize)             { thumbSize = contentSize; }
                if(thumbSize < options.minThumbSize)    { thumbSize = options.minThumbSize; }

                views.thumb[sizeProperty] = thumbSize;
                
                updateThumbPosition();
            }
        }
        
        private function updateThumbPosition():void{
            var thumbPosition:Number;
            
            if(contentIsTextField){
                var textField:TextField = content as TextField;
                if(isVertical){
                    if(textField.scrollV + 1 == textField.maxScrollV){
                        percentage = 1;
                    }else{
                        percentage = (textField.scrollV - 1) / (textField.maxScrollV - 1);
                    }
                }else{
                    percentage = (textField.scrollH - 1) / (textField.maxScrollH - 1);
                }
            }
            
            thumbPosition = (content[sizeProperty] - views.thumb[sizeProperty]) * percentage;
            if(thumbPosition + views.thumb[sizeProperty] > content[sizeProperty]){
                views.thumb[sizeProperty] = content[sizeProperty] - thumbPosition;
            }
            views.thumb[positionProperty] = thumbPosition;
            updateThumbGrip();
        }
        
        private function updateThumbGrip():void{
            // Updates the thumb grip's size and position.
            
            if(!views.thumbGrip){ return; }

            views.thumbGrip.x   = views.thumb.x + ((views.thumb.width  - views.thumbGrip.width)  * 0.5);
            views.thumbGrip.y   = views.thumb.y + ((views.thumb.height - views.thumbGrip.height) * 0.5);
            views.thumbGrip[isVertical ? 'width' : 'height'] = skin.SCROLL_BAR_THUMB_GRIP_THICKNESS;
            views.thumbGrip[isVertical ? 'height' : 'width'] = skin.SCROLL_BAR_THUMB_GRIP_LENGTH;
        }
        
        private function scrollContent(newPercentage:Number):void{
            // `newPercentage` is the target percentage distance of the scroll
            // thumb from the top/left of the scrollbar. This should be
            // between 0.0 and 1.0 inclusive.
            
            percentage = newPercentage;
            
            if(contentIsTextField){
                var textField:TextField = content as TextField;
                if(isVertical){
                    textField.scrollV = Math.round(textField.maxScrollV * percentage);
                }else{
                    textField.scrollH = Math.round(textField.maxScrollH * percentage);
                }
            }else{
                var rect:Rectangle = content.scrollRect;
                rect[positionProperty] = (contentSize - content.scrollRect[sizeProperty]) * percentage;
                content.scrollRect = rect;
            }
        }
        
        

        //--------------------------------------
        //  Properties
        //--------------------------------------

        public function get content():DisplayObject             { return _content; }
        public function set content(value:DisplayObject):void   { _content = value; }
        
        public function get contentSize():Number{
            // Returns the current height (if vertical) or width (if
            // horizontal) of `content`, depending on what type of
            // DisplayObject it is.
            
            if(!_contentSize || _contentSize < 0){
                if(content is DisplayObjectContainer){
                    // Get distance to end of farthest child
                    var doc:DisplayObjectContainer = (content as DisplayObjectContainer);
                    for(var i:uint = 0, max:uint = doc.numChildren; i < max; i++){
                        var child:DisplayObject = doc.getChildAt(i);
                        _contentSize = Math.max(_contentSize, child[positionProperty] + child[sizeProperty]);
                    }
                }else{
                    // Get natural width/height
                    _contentSize = content[sizeProperty];
                }
            }
            return Number(_contentSize);
        }
        
        public function get percentage():Number{
            // Current percentage distance of scroll thumb from top/left.
            // 0.0 to 1.0 inclusive.
            return _percentage;
        }
        public function set percentage(value:Number):void{
            _percentage = Number(isNaN(value) ? 0 : value < 0 ? 0 : value > 1 ? 1 : value);
        }
        
        public static function get defaultOptions():Object              { return _defaultOptions; }
        public static function set defaultOptions(value:Object):void    { _defaultOptions = value; }
        
    }
}
