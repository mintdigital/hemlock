package com.mintdigital.hemlock.display{
    import com.mintdigital.hemlock.HemlockEnvironment;
    // import com.mintdigital.hemlock.Logger;
    import com.mintdigital.hemlock.utils.HashUtils;
    
    import flash.display.InteractiveObject;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.utils.clearTimeout;
    import flash.utils.setTimeout;
    
    public class Tooltip extends HemlockSprite{
        
        protected static const SKIN:* = HemlockEnvironment.SKIN;
        protected static var _defaultOptions:Object = {
            bg:                 SKIN.BGBlock,
            secondsBeforeShow:  0.125,
            secondsBeforeHide:  10,
            followMouse:        false
        };
        protected var views:Object = {};
        protected var timeouts:Object = {};
        private var _target:InteractiveObject;
        private var _text:String;
        
        public function Tooltip(target:InteractiveObject, text:String, options:Object = null){
            // Logger.debug('Tooltip::Tooltip()');
            
            options = HashUtils.merge(_defaultOptions, options);
            super(options);
            _target = target;
            _text   = text;
            
            createViews();
            addTargetListeners();
            hide();
            
            if(target.stage){
                addToStage();
            }else{
                target.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
            }
        }
        
        
        
        //--------------------------------------
        //  Views
        //--------------------------------------
        
        protected function createViews():void{
            // Create background
            views.bg = new options.bg();
            
            // Create text
            views.text = new TextField();
            views.text.text = text;
            views.text.autoSize = TextFieldAutoSize.LEFT;
            
            // Add views
            addChildren(views.bg, views.text);
        }
        
        protected function addToStage():void{
            // Logger.debug('Tooltip::addToStage()');

            target.stage.addChild(this);
        }
        
        override public function show(options:Object = null):void{
            super.show();
            timeouts.hide = setTimeout(hide, options.secondsBeforeHide * 1000);
        }
        
        protected function moveToCursor(mouseX:Number, mouseY:Number):void{
            var xOffset:Number  = 5,    // Pixels away from actual cursor location
                yOffset:Number  = 5,
                x:Number        = mouseX + xOffset,
                y:Number        = mouseY + yOffset;
            
            // Gravitate toward center of stage
            if(x > target.stage.width  * 2/3){ x -= this.width  - (xOffset * 2); }
            if(y > target.stage.height * 2/3){ y -= this.height - (yOffset * 2); }
            
            setPosition(x, y);
        }
        
        
        
        //--------------------------------------
        //  Events
        //--------------------------------------
        
        protected function addTargetListeners():void{
            // Logger.debug('Tooltip::addTargetListeners()');
            
            target.addEventListener(MouseEvent.MOUSE_OVER,  onTargetMouseOver);
            target.addEventListener(MouseEvent.MOUSE_OUT,   onTargetMouseOut);
            if(options.followMouse){
                target.addEventListener(MouseEvent.MOUSE_MOVE, onTargetMouseMove);
            }
        }
        
        protected function onAddedToStage(event:Event):void{
            // Logger.debug('Tooltip::onAddedToStage()');
            
            addToStage();
            target.removeEventListener(event.type, onAddedToStage);
        }
        
        protected function onTargetMouseOver(event:MouseEvent):void{
            // Logger.debug('Tooltip::onTargetMouseOver()');
            
            moveToCursor(event.stageX, event.stageY);
            timeouts.show = setTimeout(show, options.secondsBeforeShow * 1000);
            target.stage.setChildIndex(this, target.stage.numChildren - 1); // Move to front
        }
        
        protected function onTargetMouseMove(event:MouseEvent):void{
            if(this.visible){
                moveToCursor(event.stageX, event.stageY);
            }
        }
        
        protected function onTargetMouseOut(event:MouseEvent):void{
            // Logger.debug('Tooltip::onTargetMouseOut()');
            
            if(timeouts.show){
                clearTimeout(timeouts.show);
                delete timeouts.show;
            }
            if(timeouts.hide){
                clearTimeout(timeouts.hide);
                delete timeouts.hide;
            }
            hide();
        }
        
        
        
        //--------------------------------------
        //  Properties
        //--------------------------------------
        
        public function get target():InteractiveObject  { return _target; }
        
        public function get text():String               { return _text; }
        public function set text(value:String):void     { _text = value; views.text.text = text; }
        
    }
}
