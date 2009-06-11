package com.mintdigital.hemlock.display{
    import com.mintdigital.hemlock.Logger;
    import com.mintdigital.hemlock.display.HemlockSpriteEffects;
    import com.mintdigital.hemlock.utils.HashUtils;
    
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.geom.Matrix;
    import flash.utils.setTimeout;
    
    public class HemlockSprite extends Sprite{
        protected var _listeners:Array /* of Objects */ = [];
        protected var _options:Object /* of string : * */ = {};
        protected static var _defaultOptions:Object /* of string : * */ = {};
        
        public function HemlockSprite(options:Object = null){
            if(!options){ options = {}; }
            _options = options;
            
            if(parent){
                var parentSprite:HemlockSprite = parent as HemlockSprite;
            }
            
            if(options.x)       { x = options.x; }
            if(options.y)       { y = options.y; }
            if(options.width)   { width  = options.width;  }
            if(options.height)  { height = options.height; }
            if(options.visible === true || options.visible === false){
                options.visible ? show() : hide();
            }
            if(options.name)    { name = options.name; }
            // TODO: Instead loop through expected options and check if defined
        }
        
        public function setPosition(x:Number, y:Number):void{
            // Changes this object's x and y. To get this object's original x
            // and y, use options.x and options.y.
            
            this.x = x;
            this.y = y;
        }
        
        public function setSize(width:Number, height:Number):void{
            // Change this object's width and height. To get this object's
            // original width and height, use options.width and
            // options.height.
            
            this.width  = width;
            this.height = height;
        }
        
        public function updateSize():void{
            // Automatically called after addChild() and addChildren() to
            // avoid rendering issues.
            // Source: http://www.kirupa.com/forum/showthread.php?p=2397349
            
            if(!_options){ return; }
            if(_options.width) { this.width  = _options.width; }
            if(_options.height){ this.height = _options.height; }
        }
        
        public function updateDimensions():void{
            // DEPRECATED. Use updateSize() instead: its name matches
            // setSize().
            
            updateSize();
        }
        
        public function show():void     { visible = true; }
        public function hide():void     { visible = false; }
        public function toggle():void   { visible = !visible; }
            // See also the overridden `visible` setter for this class.
        
        override public function addChild(child:DisplayObject):DisplayObject{
            super.addChild(child);
            updateSize();
            return child;
        }
        
        public function addChildren(... displayObjects):void{
            for each(var displayObject:DisplayObject in displayObjects){
                super.addChild(displayObject);
            }
            updateSize();
        }
        
        public function moveChildToBack(displayObject:DisplayObject):void{
            // Moves `displayObject` to the lowest possible z-index.
            setChildIndex(displayObject, 0);
        }
        
        public function moveChildToFront(displayObject:DisplayObject):void{
            // Moves `displayObject` to the highest possible z-index.
            setChildIndex(displayObject, numChildren - 1);
        }
        


        //--------------------------------------
        //  Effects
        //--------------------------------------
        
        public function fadeOut(options:Object = null):void{
            /*
            Usage:
            - mySprite.fade(); // Fades to alpha = 0
            - mySprite.fade({
                  to: 0.5,
                  duration: 0.75
              }); // Fades to alpha = 0.5 in 0.75 seconds
            
            Options:
            - from:         Original alpha (0.0 to 1.0); defaults to current alpha
            - to:           Target alpha (0.0 to 1.0); defaults to 0
            - duration:     Number of seconds
            - onComplete:   Function to run after effect
            */
            
            options = HashUtils.merge({
                from:       alpha,
                to:         0
            }, options);
            
            HemlockSpriteEffects.fade(this, options);
        }
        
        public function fadeIn(options:Object = null):void{
            /*
            Usage:
            - mySprite.fade(); // Fades to alpha = 1
            - mySprite.fade({
                  to: 0.5,
                  duration: 5
              }); // Fades to alpha = 0.5 in 5 seconds
            
            Options:
            - from:         Original alpha (0.0 to 1.0); defaults to 0
            - to:           Target alpha (0.0 to 1.0); defaults to 1
            - duration:     Number of seconds
            - onComplete:   Function to run after effect
            */
            
            options = HashUtils.merge({
                from:       0,
                to:         1
            }, options);
            
            HemlockSpriteEffects.fade(this, options);
        }
        
        public function move(options:Object):void{
            /*
            Usage:
            - mySprite.move({
                  xBy: -10,
                  yBy: 20
              }); // Moves left 10px and down 20px
            - mySprite.move({
                  xFrom: 10,
                  xTo:   90,
                  duration: 5
              }); // Moves x-coordinate from 10 to 90 in 5 seconds
            
            Options:
            - xBy:          Number of pixels to move along the x-axis
            - xFrom:        Starting x-coordinate
            - xTo:          Ending x-coordinate
            - yBy:          Number of pixels to move along the y-axis
            - yFrom:        Starting y-coordinate
            - yTo:          Ending y-coordinate
            - duration:     Number of seconds
            - onComplete:   Function to run after effect
            */
            
            if(!options){ options = {}; }
            HemlockSpriteEffects.move(this, options);
        }
        
        public function dropOut(options:Object = null):void{
            /*
            Usage:
            - mySprite.dropOut(); // Moves down and fades
            - mySprite.dropOut({
                  y: 50
                  duration: 5
              }); // Moves down 50px and fades in 5 seconds
            
            Options:
            - alphaFrom:    Alpha (0.0 to 1.0) to fade from; defaults to current alpha
            - alphaTo:      Alpha (0.0 to 1.0) to fade to; defaults to 0
            - x:            Number of pixels to move along the x-axis; defaults to 0
            - y:            Number of pixels to move along the y-axis; defaults to 20
            - duration:     Number of seconds
            - onComplete:   Function to run after effect
            */
            
            // TODO: Update to use BlurFilter (more blurY as effect continues)
            
            options = HashUtils.merge({
                y: 10
            }, options);
            
            // Rename options.x and options.y to options.xBy and options.yBy
            options = HashUtils.merge({
                xBy:    options.x,
                yBy:    options.y
            }, options);
            delete options.x;
            delete options.y;
            
            // Pull out onComplete so that it's not run after each effect
            var onComplete:Function = options.onComplete;
            if(options.onComplete){ delete options.onComplete; }
            
            fadeOut(options);
            move(HashUtils.merge({
                // Only attach onComplete to one effect
                onComplete: onComplete
            }, options));
        }
        
        // TODO: `dropIn` effect
        
        public function flip(newSprite:HemlockSprite, options:Object = null):void{
            /*
            Usage:
            - oldSprite.flip(newSprite); // 3-D flip to newSprite
            - oldSprite.flip(newSprite, {
                  duration: 5
              }); // 3-D flip to newSprite in five seconds
            */
            
            if(!options){ options = {}; }
            HemlockSpriteEffects.flip(this, newSprite, options);
        }
        
        // TODO: Subclasses for buttons and other inputs?
        // - HemlockSprite
        //   > HemlockForm
        //     - Attributes: controls:Array of HemlockControls
        //     - Events: HemlockFormEvent.SUBMIT
        //     - Has many text inputs, password inputs, and buttons, with one button marked as default
        //     - Exists for handling text input tab indexes, routing Return/Enter to default button, and collecting input values in an object
        //   > HemlockLabel
        //     - Attributes: target:HemlockControl
        //     - Clicking gives focus to target
        //   > HemlockControl
        //     - Attributes: namespace:String (unique among other namespaces), name:String (unique within namespace), id:String (unique combination of namespace and name), value:Object, text:String, textField:TextField, textFormat:TextFormat, eventHandlers:Object of {eventType:Function}
        //     - Methods: focus()
        //     > HemlockTextField
        //       - Attributes: defaultText:String
        //       - Events: HemlockTextInput.FOCUS (is this built into TextField?)
        //       > HemlockPasswordField
        //     > HemlockButton
        //   > HemlockModal
        //     > HemlockNotice
        //     > HemlockError
        //   > HemlockProgress
        //     - Attributes: currentIncrement:uint|null, totalIncrements:uint|null
        //     - If no increments are given, instead show repeating animation, e.g., spinner, horizontal barber pole
        // TODO: Automatically start/stop HemlockControl listeners when removed from stage (see DisplayObject docs for events) or shown/hidden
        
        
        
        //--------------------------------------
        //  Internal helpers
        //--------------------------------------
        
        // ...
        
        
        
        //--------------------------------------
        //  Events
        //--------------------------------------
        
        public function registerListeners():void{
            // Registers listeners for automatic adding/removing.
            
            /* Override me if needed */
        }
        
        public function unregisterListeners():void {
            stopListeners();
            _listeners = [];
        }
        
        public function registerListener(listenee:*, eventType:String, eventHandler:Function, options:Object = null):void{
            // Adds listener data to _listeners, which is used in
            // startListeners() and stopListeners() automatically.
            
            // Supported options:
            // - useCapture:Boolean (default = false)
            
            // Logger.debug('HemlockSprite::registerListener() : eventType = ' + eventType);
            // Logger.debug('HemlockSprite::registerListener() : eventHandler = ' + eventHandler);
            
            // TODO: Handle duplicates
            // - Ignore if duplicate listenee, eventType, eventHandler, and options
            // - Overwrite if differs only on options
            _listeners.push(HashUtils.merge({
               listenee:        listenee,
               eventType:       eventType,
               eventHandler:    eventHandler,
               useCapture:      false
            }, options));
        }
        
        public function startListeners():void{
            // Adds listeners according to _listeners, which is constructed
            // via registerListener().
            
            for each(var listener:Object in _listeners){
                listener.listenee.addEventListener(listener.eventType, listener.eventHandler, listener.useCapture);
            }
        }
        
        // TODO: public function startListener(eventType:String):void
        // - Logger.error if eventType wasn't registered
        
        public function stopListeners():void{
            // Removes listeners according to _listeners, which is constructed
            // via registerListener().
            
            for each(var listener:Object in _listeners){
                listener.listenee.removeEventListener(listener.eventType, listener.eventHandler, listener.useCapture);
            }
        }
        
        // TODO: public function stopListener(eventType:String):void
        // - Logger.error if eventType wasn't registered
        
        public static function getVerticalMatrix():Matrix{
            // Returns matrix for making vertical gradients
            
            // TODO: Cache in a private member var/const

            var verticalMatrix:Matrix = new Matrix();
            verticalMatrix.createGradientBox(100, 100, 0.5 * Math.PI, 0, 0); // 90 degrees
            return verticalMatrix;
        }
        
        
        
        //--------------------------------------
        //  Properties
        //--------------------------------------
        
        public function get options():Object{ return _options; }

        public static function get defaultOptions():Object              { return _defaultOptions; }
        public static function set defaultOptions(value:Object):void    { _defaultOptions = value; }
        
        override public function set visible(value:Boolean):void{
            super.visible = value;
            value ? startListeners() : stopListeners();
        }
        
    }
}
