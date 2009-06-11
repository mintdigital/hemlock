package com.mintdigital.hemlock.display{
    import com.mintdigital.hemlock.utils.HashUtils;

    import mx.effects.Fade;
    import mx.effects.Move;
    import mx.events.EffectEvent;
    
    import flash.events.TimerEvent;
    import flash.filters.BlurFilter;
    import flash.geom.Matrix;
    import flash.utils.Timer;
    
    public class HemlockSpriteEffects{
        public static const DEFAULT_DURATION:Number = 0.25;
        
        public static function fade(sprite:HemlockSprite, options:Object):void{
            // See HemlockSprite for documentation.
            
            options = HashUtils.merge({
                from:       sprite.alpha,
                to:         sprite.alpha,
                duration:   DEFAULT_DURATION
            }, options);
            
            var effect:Fade = new Fade();
            effect.alphaFrom    = options.from;
            effect.alphaTo      = options.to;
            effect.duration     = options.duration * 1000;
            if(effect.alphaTo > 0){ sprite.show(); }
            
            effect.play([ sprite ]);
            
            if(effect.alphaTo == 0 || options.onComplete){
                effect.addEventListener(EffectEvent.EFFECT_END, function(event:EffectEvent):void{
                    if(effect.alphaTo == 0){ sprite.hide(); }
                    if(options.onComplete){ options.onComplete(); }
                });
            }
        }
        
        public static function move(sprite:HemlockSprite, options:Object):void{
            // See HemlockSprite for documentation.
            
            options = HashUtils.merge({
                xFrom:      sprite.x,
                yFrom:      sprite.y,
                xTo:        sprite.x,
                yTo:        sprite.y,
                duration:   DEFAULT_DURATION
            }, options);
            
            /*
            var effect:Move = new Move();
            if(options.xTo){
                effect.xFrom    = options.xFrom;
                effect.xTo      = options.xTo;
            }else if(options.xBy){
                effect.xBy      = options.xBy;
            }
            if(options.yTo){
                effect.yFrom    = options.yFrom;
                effect.yTo      = options.yTo;
            }else if(options.yBy){
                effect.yBy      = options.yBy;
            }
            effect.play([ sprite ]);
            
            if(options.onComplete){
                effect.addEventListener(EffectEvent.EFFECT_END, function(event:EffectEvent):void{
                    options.onComplete();
                });
            }
            */
            
            // mx.effects.Move seems to only work with Flex UI components (not
            // Sprites), so we'll do this effect manually for now with linear
            // easing.
            
            // Generic effect variables
            var fps:Number = 24;
                // Frames per second; higher is smoother, but more CPU-hungry
            var duration:Number = options.duration;
            var repeatCount:Number = duration * fps;
            var timer:Timer = new Timer(1000 / fps, repeatCount);
            
            // Effect-specific variables
            var xFrom:Number = options.xFrom;
            var yFrom:Number = options.yFrom;
            var xTo:Number = options.xBy ? xFrom + options.xBy : options.xTo;
            var yTo:Number = options.yBy ? yFrom + options.yBy : options.yTo;
            var xDelta:Number = (xTo - xFrom) / repeatCount;
            var yDelta:Number = (yTo - yFrom) / repeatCount;
            
            timer.addEventListener(TimerEvent.TIMER, onTick);
            timer.addEventListener(TimerEvent.TIMER_COMPLETE, onComplete);
            timer.start();
            
            function onTick(event:TimerEvent):void{
                if(xDelta != 0){ sprite.x += xDelta; }
                if(yDelta != 0){ sprite.y += yDelta; }
            }
            
            function onComplete(event:TimerEvent):void{
                sprite.setPosition(xTo, yTo);
                if(options.onComplete){
                    // Run callback function from options, if any
                    options.onComplete();
                }
            }
        }
        
        // TODO: `resize` effect, widthDelta / heightDelta, sprite.grow(), sprite.shrink()
        // - http://livedocs.adobe.com/flex/3/langref/mx/effects/Resize.html
        
        // TODO: `zoom` effect
        // - http://livedocs.adobe.com/flex/3/langref/mx/effects/Zoom.html
        
        // TODO: `highlight` effect; default to yellow ColorTransform
        // - Update TTGameCard::highlight to use this
        
        // TODO: `blind` effect, vertical (default) or horizontal
        
        public static function flip(oldSprite:HemlockSprite, newSprite:HemlockSprite, options:Object = null):void{
            // See HemlockSprite for documentation.
            
            // TODO: Option to change direction: horizontal (default), vertical
            // TODO: Replace with 3-D flip effect (don't steal!)
            // - Skew sprites in a 3-D manner; use matrix transform
            //   - Desired effect: http://www.afcomponents.com/components/flip_as3/
            //   - http://www.flashandmath.com/bridge/cardtake1/
            //   - If Flash 10 is available: http://livedocs.adobe.com/flex/3/langref/flash/display/DisplayObject.html#rotationZ
            
            options = HashUtils.merge({
                duration: 0.375 // 0.25 is too short to make effect look good
            }, options);
            
            oldSprite.show();
            newSprite.hide();
            
            // Generic effect variables
            var fps:Number = 24;
                // Frames per second; higher is smoother, but more CPU-hungry
            var duration:Number = options.duration;
            var repeatCount:Number = duration * fps;
            var timer:Timer = new Timer(1000 / fps, repeatCount);
            
            // Effect-specific variables
            var origWidth:Number = oldSprite.width;
            var origX:Number = oldSprite.x;
            var tickCount:uint = 0; // Increments after each timer tick

            timer.addEventListener(TimerEvent.TIMER, onTick);
            timer.addEventListener(TimerEvent.TIMER_COMPLETE, onComplete);
            timer.start();
            
            function onTick(event:TimerEvent):void{
                // Get all quadratic up in here
                // (fastest animation at start and end; slowest at middle)
                var quadR:Number = origWidth;
                var quadX:Number = Math.min(tickCount, repeatCount - tickCount + 1) * (origWidth * 2 / repeatCount);
                if(tickCount < (repeatCount / 2)){
                    // Only show oldSprite for first half
                    oldSprite.show(); newSprite.hide();
                }else{
                    // Only show newSprite for second half
                    oldSprite.hide(); newSprite.show();
                }
                var quadY:Number = Math.sqrt(Math.pow(quadR, 2) - Math.pow(quadX, 2));
                
                // Update dimensions and positions
                var newWidth:Number = quadY;
                var newX:Number = origX + ((origWidth - newWidth) / 2);
                if(newSprite.visible){
                    newSprite.width = newWidth; newSprite.x = newX;
                }else{ // oldSprite.visible
                    oldSprite.width = newWidth; oldSprite.x = newX;
                }
                
                // Update blur
                var blurX:Number = Math.pow(2, Math.min(2, Math.min(tickCount, repeatCount - tickCount + 1)));
                    // BlurFilter is optimized for powers of 2; cap blurring
                    // at 2^2 because higher values look silly.
                newSprite.filters = oldSprite.filters = [ new BlurFilter(blurX, 0) ];
                
                tickCount++;
            }
            
            function onComplete(event:TimerEvent):void{
                // sprite.setPosition(xTo, yTo);
                
                newSprite.width = oldSprite.width = origWidth;
                newSprite.x = oldSprite.x = origX;
                newSprite.filters = oldSprite.filters = [];
                
                if(options.onComplete){
                    // Run callback function from options, if any
                    options.onComplete();
                }
            }
            
        }
        
        // TODO: `glow` effect
        // - http://livedocs.adobe.com/flex/3/langref/mx/effects/Glow.html
        
        // TODO: `rotate` effect
        // - http://livedocs.adobe.com/flex/3/langref/mx/effects/Rotate.html
        
    }
}
