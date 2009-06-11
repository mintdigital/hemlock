package com.mintdigital.hemlock.widgets.drawing{
    import com.mintdigital.hemlock.Logger;
    import com.mintdigital.hemlock.display.HemlockSprite;
    import com.mintdigital.hemlock.events.AppEvent;
    import com.mintdigital.hemlock.events.DrawEvent;
    import com.mintdigital.hemlock.widgets.IDelegateEvents;
    import com.mintdigital.hemlock.widgets.HemlockWidget;
    import com.mintdigital.hemlock.widgets.HemlockWidgetDelegate;
    
    import flash.events.MouseEvent;
    import flash.utils.setInterval;
    
    public class DrawingWidgetEvents extends HemlockWidgetDelegate implements IDelegateEvents{
        
        public function DrawingWidgetEvents(widget:HemlockWidget){
            super(widget);
        }
        
        
        
        //--------------------------------------
        //  Initializers
        //--------------------------------------
        
        public function registerListeners():void{
            Logger.debug('DrawingWidget::registerListeners()');

            // Listen for local events
            widget.registerListener(views.canvas,       MouseEvent.MOUSE_DOWN,  onCanvasMouseDown);
            widget.registerListener(views.clearButton,  MouseEvent.CLICK,       onClearButtonClick);
            widget.registerListener(views.eraser,       MouseEvent.CLICK,       onEraserClick);

            // Register listeners on local brush colors
            var i:uint, max:uint;
            for(i = 0, max = views.brushColors.numChildren; i < max; i++){
                var brushColorBox:HemlockSprite = views.brushColors.getChildAt(i) as HemlockSprite;
                widget.registerListener(brushColorBox, MouseEvent.CLICK, onBrushColorClick);
            }

            // Register listeners on local brush thicknesses
            for(i = 0, max = views.brushThicknesses.numChildren; i < max; i++){
                var brushThicknessBox:HemlockSprite = views.brushThicknesses.getChildAt(i) as HemlockSprite;
                widget.registerListener(brushThicknessBox, MouseEvent.CLICK, onBrushThicknessClick);
            }

            // Listen for external events
            widget.registerListener(dispatcher, AppEvent.PRESENCE_UPDATE,  onPresenceUpdate);
            widget.registerListener(dispatcher, DrawEvent.BRUSH,           onDrawBrush);
            widget.registerListener(dispatcher, DrawEvent.COORDS,          onDrawCoords);
            widget.registerListener(dispatcher, DrawEvent.CLEAR,           onDrawClear);
        }
        
        
        
        //--------------------------------------
        //  Handlers > Views
        //--------------------------------------
        
        private function onCanvasMouseDown(event:MouseEvent):void{
            Logger.debug('DrawingWidget::onCanvasMouseDown()');

            var jidString:String = jid.toString(),
                coords:Array /* of [x,y] */ = widget.boundCoords([event.localX, event.localY]),
                numCoordsToProcessPerInterval:Number = 10;

            // Draw dot in local UI
            var brush:Object = widget.brushes[jidString];
            delegates.views.drawDot({
               x:           coords[0],
               y:           coords[1],
               color:       brush.color,
               thickness:   brush.thickness
            });

            // Start listening for mouse movements
            views.canvas.addEventListener(MouseEvent.MOUSE_MOVE,    onCanvasMouseMove);
            views.canvas.addEventListener(MouseEvent.MOUSE_UP,      onCanvasMouseUp);
            views.canvas.addEventListener(MouseEvent.MOUSE_OUT,     onCanvasMouseUp);
                // NB: MouseEvent.MOUSE_UP and MOUSE_OUT use the same handler

            // Start queueing and sending mouse movements
            widget.coordQueueIntervals[jidString] = setInterval(
                widget.sendCoordQueue,
                widget.COORD_QUEUE_INTERVAL_DELAY,
                numCoordsToProcessPerInterval
            );

            // Queue initial mouse coordinates
            widget.coordQueues[jidString].push(coords);
        }

        private function onCanvasMouseMove(event:MouseEvent):void{
            var jidString:String = jid.toString(),
                currentCoords:Array /* of [x,y] */ = widget.boundCoords([event.localX, event.localY]),
                coordQueue:Array /* of [x,y]s */ = widget.coordQueues[jidString];

            // Update UI
            if(coordQueue.length > 0){
                var previousCoords:Array /* of [x,y]s */ = widget.boundCoords(coordQueue[coordQueue.length - 1]),
                    brush:Object = widget.brushes[jidString];
                delegates.views.drawLine({
                    fromX:      previousCoords[0],
                    fromY:      previousCoords[1],
                    toX:        currentCoords[0],
                    toY:        currentCoords[1],
                    color:      brush.color,
                    thickness:  brush.thickness
                });
            }

            // Queue new coordinates to be sent
            widget.coordQueues[jidString].push(currentCoords);
        }

        private function onCanvasMouseUp(event:MouseEvent):void{
            Logger.debug('DrawingWidget::onCanvasMouseUp() : type = ' + event.type);
                // Triggers with MouseEvent.MOUSE_UP or MOUSE_OUT

            var jidString:String = jid.toString();

            // Stop listening for mouse movements
            views.canvas.removeEventListener(MouseEvent.MOUSE_MOVE, onCanvasMouseMove);
            views.canvas.removeEventListener(MouseEvent.MOUSE_UP,   onCanvasMouseUp);
            views.canvas.removeEventListener(MouseEvent.MOUSE_OUT,  onCanvasMouseUp);

            // Queue end-of-path sentinel value
            widget.coordQueues[jidString].push([-1, -1]);
                // TODO: Move to END_OF_PATH:Array constant
        }

        private function onClearButtonClick(event:MouseEvent):void{
            Logger.debug('DrawingWidget::onClearButtonClick()');

            delegates.views.resetCanvas();
            widget.sendDataMessage(DrawEvent.CLEAR, {
                from:   jid.toString()
            });
        }

        private function onBrushColorClick(event:MouseEvent):void{
            Logger.debug('DrawingWidget::onBrushColorClick()');

            var box:HemlockSprite = event.target as HemlockSprite,
                color:uint = box.options.data.color;
            widget.brushes[jid.toString()].color = color;
            delegates.views.highlightBrushColor(color);
            widget.sendBrushData('color');
        }

        private function onEraserClick(event:MouseEvent):void{
            Logger.debug('DrawingWidget::onEraserClick()');

            widget.brushes[jid.toString()].color = 0xFFFFFF;
            delegates.views.highlightEraser();
            widget.sendBrushData('color');
        }

        private function onBrushThicknessClick(event:MouseEvent):void{
            Logger.debug('DrawingWidget::onBrushThicknessClick()');

            var box:HemlockSprite = event.target as HemlockSprite,
                thickness:uint = box.options.data.thickness;
            widget.brushes[jid.toString()].thickness = thickness;
            delegates.views.highlightBrushThickness(thickness);
            widget.sendBrushData('thickness');
        }
        
        
        
        //--------------------------------------
        //  Handlers > App
        //--------------------------------------
        
        private function onPresenceUpdate(event:AppEvent):void{
            widget.sendBrushData();
        }

        private function onDrawBrush(event:DrawEvent):void{
            Logger.debug('DrawingWidget::onDrawBrush()');

            // Ignore if sent from this user
            if(jid.eq(event.from)){ return; }

            var from:String = event.from.toString();

            // Update sender's brush
            if(!widget.brushes[from]){ widget.brushes[from] = {}; }
            if(event.options.color){
                widget.brushes[from].color = event.options.color;
            }
            if(event.options.thickness){
                widget.brushes[from].thickness = event.options.thickness;
            }
        }

        private function onDrawCoords(event:DrawEvent):void{
            Logger.debug('DrawingWidget::onDrawCoords()');

            // Ignore if sent from this user
            if(jid.eq(event.from)){ return; }

            // Draw lines
            var coords:Array /* of [x,y]s */ = event.options.coords,
                from:String = event.from.toString(),
                msPerLine:Number = 10; // milliseconds; simulates human-speed drawing

            widget.coordQueues[from] =
                widget.coordQueues[from]
                ? widget.coordQueues[from].concat(coords)
                : coords;

            if(!widget.coordQueueIntervals[from]){
                widget.coordQueueIntervals[from] =
                    setInterval(widget.processCoordQueue, msPerLine, from);
            }
        }

        private function onDrawClear(event:DrawEvent):void{
            Logger.debug('DrawingWidget::onDrawClear()');

            if(event.from && event.from.resource){
                dispatcher.dispatchEvent(new AppEvent(AppEvent.CHATROOM_STATUS, {
                    message: event.from.resource + ' cleared the canvas'
                }));
            }

            // Clear if sent from someone else
            if(!jid.eq(event.from)){ delegates.views.resetCanvas(); }
        }
        
    }
}
