package com.mintdigital.hemlock.widgets.drawing{
    import com.mintdigital.hemlock.Logger;
    import com.mintdigital.hemlock.display.HemlockSprite;
    import com.mintdigital.hemlock.events.AppEvent;
    import com.mintdigital.hemlock.events.DrawEvent;
    import com.mintdigital.hemlock.utils.ArrayUtils;
    import com.mintdigital.hemlock.utils.HashUtils;
    import com.mintdigital.hemlock.widgets.HemlockWidget;
    
    import flash.utils.clearInterval;

    public class DrawingWidget extends HemlockWidget{
        // NOTE: This widget's drawing abilities are much smoother when
        //       DebugWidget is disabled.
        
        public const COORD_QUEUE_INTERVAL_DELAY:Number = 250; // milliseconds
        public const BRUSH_COLORS:Array /* of uints */ = [
            0xCC0000,   // Red
            0xFF9900,   // Orange
            0xFFFF33,   // Yellow
            0x00CC00,   // Green
            0x66CCFF,   // Sky blue
            0x0000CC,   // Blue
            0xCC00CC,   // Purple
            0x663300,   // Brown
            0xFFECCF,   // Flesh
            0x999999,   // Gray
            0x010101    // Black; 0x000000 can't be sent for some reason
        ];
        public const BRUSH_THICKNESSES:Array /* of uints */ = [5, 10, 20];
        public const DEFAULT_BRUSH_COLOR:uint = 0x999999;
        public const DEFAULT_BRUSH_THICKNESS:uint = 5;
        
        internal var brushes:Object = {};
            // Key:     JID string
            // Value:   Object of brush data (e.g., color, thickness)
        internal var coordQueues:Object = {};
            // Key:     JID string
            // Value:   Array of [x,y] coordinates for that user
        internal var coordQueueIntervals:Object = {};
            // Key:     JID string
            // Value:   uint ID of an interval for processing user's coordQueue
        
        public function DrawingWidget(parentSprite:HemlockSprite, options:Object = null){
            // super(parentSprite, options);
            super(parentSprite, HashUtils.merge({
                delegates: {
                    views:  new DrawingWidgetViews(this),
                    events: new DrawingWidgetEvents(this)
                }
            }, options));
            
            // Send intro text to ChatroomWidget, if any
            var intro:String =
                'This is a demo of DrawingWidget, which lets people '
                 + 'draw together on a single canvas.';
            dispatcher.dispatchEvent(new AppEvent(AppEvent.CHATROOM_STATUS, {
                message: intro
            }));
            
            // Prepare coordinate queue for current user
            coordQueues[jid.toString()] = [];
            
            // Prepare brush for current user
            brushes[jid.toString()] = {
                color:      DEFAULT_BRUSH_COLOR,
                thickness:  DEFAULT_BRUSH_THICKNESS
            };
            delegates.views.highlightBrushColor(DEFAULT_BRUSH_COLOR);
            delegates.views.highlightBrushThickness(DEFAULT_BRUSH_THICKNESS);
        }
        
        
        
        //--------------------------------------
        //  Internal helpers
        //--------------------------------------
        
        internal function boundCoords(coords:Array /* of [x,y] */):Array /* of [x,y] */{
            // Modifies `coords` if either x or y is out of bounds, and
            // returns the result.
            
            if(!views.canvas){ return coords; }
            
            // Set margin to radius of widest brush so that, when the brush is
            // used, its outer edges don't extend past canvas.
            const MARGIN:uint = ArrayUtils.max(BRUSH_THICKNESSES) * 0.5;
            
            var minX:uint = MARGIN, minY:uint = MARGIN,
                maxX:uint = views.canvas.width - MARGIN,
                maxY:uint = views.canvas.height - 50 - MARGIN;
            coords[0] = Math.max(minX, Math.min(maxX, coords[0]));
            coords[1] = Math.max(minY, Math.min(maxY, coords[1]));
            return coords;
        }
        
        internal function sendBrushData(key:String = null):void{
            // Sends a DataMessage containing the current user's brush data.
            // If `key` is provided, only the matching brush data is sent.
            
            Logger.debug('DrawingWidget::sendBrushData()');
            
            var jidString:String = jid.toString(),
                brush:Object = brushes[jidString],
                payload:Object = { from: jidString };
            
            if(key){
                payload[key] = brush[key];
            }else{
                payload = HashUtils.merge(payload, brush);
            }
            
            sendDataMessage(DrawEvent.BRUSH, payload);
        }
        
        internal function sendCoordQueue(limit:uint = 0):void{
            // `limit` determines how many coordinate pairs to send from
            // `coordQueue`. If `limit` is 0, all coordinate pairs are
            // sent.
            
            Logger.debug('DrawingWidget::sendCoordQueue() : limit = ' + limit);
            
            var jidString:String = jid.toString(),
                finalCoords:Array /* [x,y] */,
                coordQueue:Array /* of [x,y]s */ = coordQueues[jidString];
            
            if(limit < 1 || limit >= coordQueue.length){
                limit = coordQueue.length;
                finalCoords = coordQueue[limit - 1];
            }
            
            var coords:Array /* of [x,y]s */ = coordQueues[jidString].splice(0, limit);
            
            sendDataMessage(DrawEvent.COORDS, {
                from:       jidString,
                coords:     coords
            });
            if(finalCoords){
                if(finalCoords[0] != -1 || finalCoords[1] != -1){
                    // Preserve final coords as start of next line
                    coordQueues[jidString] = [finalCoords];
                }else{
                    // User signaled end-of-path
                    clearCoordQueue(jidString);
                }
            }
        }
        
        internal function processCoordQueue(jidString:String):void{
            // Draws the next line in the coordinate queue for the given user.
            
            Logger.debug('DrawingWidget::processCoordQueue() : jidString = ' + jidString);
            
            var coordQueue:Array /* of [x,y]s */ = coordQueues[jidString],
                brush:Object = brushes[jidString];
            
            if(coordQueue.length == 0){
                clearCoordQueue(jidString);
                return;
            }
            
            // Check if sender ended path
            while(coordQueue.length > 0
                && (coordQueue[0] && coordQueue[0][0] == -1 && coordQueue[0][1] == -1
                    || coordQueue[1] && coordQueue[1][0] == -1 && coordQueue[1][1] == -1)
                ){
                while(coordQueue[0] && coordQueue[0][0] == -1 && coordQueue[0][1] == -1){
                    coordQueues[jidString].shift(); // Remove end-of-path coord
                    coordQueue = coordQueues[jidString];
                }
                while(coordQueue[1] && coordQueue[1][0] == -1 && coordQueue[1][1] == -1){
                    delegates.views.drawDot({
                        x:          coordQueue[0][0],
                        y:          coordQueue[0][1],
                        color:      brush.color,
                        thickness:  brush.thickness
                    });
                    coordQueues[jidString].shift(); // Remove dot coord
                    coordQueues[jidString].shift(); // Remove end-of-path coord
                    coordQueue = coordQueues[jidString];
                }
            }
            
            if(coordQueue.length > 1){
                delegates.views.drawLine({
                    fromX:      coordQueue[0][0],
                    fromY:      coordQueue[0][1],
                    toX:        coordQueue[1][0],
                    toY:        coordQueue[1][1],
                    color:      brush.color,
                    thickness:  brush.thickness
                });
                coordQueues[jidString].shift();
                coordQueue = coordQueues[jidString];
            }else if(coordQueue.length == 0){
                clearCoordQueue(jidString);
            }
        }
        
        internal function clearCoordQueue(jidString:String):void{
            // Clears the coordinate queue for given user.
            
            coordQueues[jidString] = [];
            clearInterval(coordQueueIntervals[jidString]);
            coordQueueIntervals[jidString] = NaN;
        }
        
        internal function clearCoordQueues():void{
            // Clears coordinate queues for all users and stops drawing.
            
            Logger.debug('DrawingWidget::clearCoordQueues()');
            
            for(var jidString:String in coordQueues){
                clearCoordQueue(jidString);
            }
        }
        
    }
}
