package com.mintdigital.hemlock.widgets.drawing{
    import com.mintdigital.hemlock.Logger;
    import com.mintdigital.hemlock.controls.HemlockButton;
    import com.mintdigital.hemlock.display.HemlockSprite;
    import com.mintdigital.hemlock.utils.GraphicsUtils;
    import com.mintdigital.hemlock.utils.HashUtils;
    import com.mintdigital.hemlock.utils.setProperties;
    import com.mintdigital.hemlock.widgets.IDelegateViews;
    import com.mintdigital.hemlock.widgets.HemlockWidget;
    import com.mintdigital.hemlock.widgets.HemlockWidgetDelegate;
    
    import flash.display.DisplayObject;
    import flash.display.GradientType;
    
    public class DrawingWidgetViews extends HemlockWidgetDelegate implements IDelegateViews{
        
        public function DrawingWidgetViews(widget:HemlockWidget){
            super(widget);
        }
        
        
        
        //--------------------------------------
        //  Initializers
        //--------------------------------------
        
        public function createViews():void{
            Logger.debug('DrawingWidget::createViews()');

            var i:uint, max:uint;

            // Prepare coordinates
            var coords:Object = {};
            coords.canvas = {
                width:  options.width  - 20,
                height: options.height - 20
            };
            coords.canvas.x = (options.width  - coords.canvas.width)  * 0.5;
            coords.canvas.y = (options.height - coords.canvas.height) * 0.5;
            coords.clearButton = { width: 80, height: 30 };
            coords.clearButton.x = 20;
            coords.clearButton.y =
                coords.canvas.y + coords.canvas.height - coords.clearButton.height - 10;
            coords.brushColorBox = { width: 25 };
            coords.brushColors = {
                x:      coords.clearButton.x + coords.clearButton.width + 50,
                y:      coords.clearButton.y,
                width:  widget.BRUSH_COLORS.length * coords.brushColorBox.width,
                height: coords.clearButton.height
            };
            coords.brushColorBox.height = coords.brushColors.height - 4;
            coords.eraserControl = { width: 32, height: 20 };
            coords.eraser = {
                x:      coords.brushColors.x + coords.brushColors.width + 10,
                y:      coords.brushColors.y,
                width:  coords.eraserControl.width + 12,
                height: coords.brushColors.height
            };
            coords.eraserControl.x  = (coords.eraser.width  - coords.eraserControl.width)  * 0.5;
            coords.eraserControl.y  = (coords.eraser.height - coords.eraserControl.height) * 0.5;
            coords.brushThicknessBox = { width: 30 };
            coords.brushThicknesses = {
                // x:      coords.brushColors.x + coords.brushColors.width + 50,
                x:      coords.eraser.x + coords.eraser.width + 50,
                y:      coords.brushColors.y,
                width:  widget.BRUSH_THICKNESSES.length * coords.brushThicknessBox.width,
                height: coords.clearButton.height
            };
            coords.brushThicknessBox.height = coords.brushThicknesses.height - 4;

            // Create background
            with(widget.graphics){
                beginFill(0x442200, 1);
                drawRoundRect(0, 0, options.width, options.height, 20);
                endFill();
            }

            // Create canvas
            views.canvas = new HemlockSprite({
                x:  coords.canvas.x,
                y:  coords.canvas.y
            });
            resetCanvas([coords.canvas.width, coords.canvas.height]);
            views.canvas.setSize(coords.canvas.width, coords.canvas.height);

            // Create "clear" button
            views.clearButton = new HemlockButton('clear', '', HashUtils.merge({
                label:  'clear'
            }, coords.clearButton));

            // Create brushColors
            views.brushColors = new HemlockSprite(coords.brushColors);
            for(i = 0, max = widget.BRUSH_COLORS.length; i < max; i++){
                var brushColor:uint = widget.BRUSH_COLORS[i],
                    brushColorBox:HemlockSprite = new HemlockSprite({
                        x:      i * coords.brushColorBox.width,
                        y:      0,
                        data:   { color: brushColor }
                    });
                brushColorBox.buttonMode = true;
                with(brushColorBox.graphics){
                    // Prop open
                    GraphicsUtils.fill(brushColorBox.graphics, coords.brushColorBox);

                    // Draw brush color
                    beginGradientFill(
                        GradientType.LINEAR,
                        // [adjustBrightness(brushColor, 0x33), adjustBrightness(brushColor, -0xFF)],
                        [brushColor, adjustBrightness(brushColor, -0xFFFFFF)],
                        [1, 1], [0, 0xFF],
                        HemlockSprite.getVerticalMatrix()
                        );
                    drawRoundRect(4, 4, coords.brushColorBox.width - 8, coords.brushColorBox.height - 8, 10);
                    endFill();
                }
                views.brushColors.addChild(brushColorBox);
                brushColorBox.setSize(coords.brushColorBox.width, coords.brushColorBox.height);
            }
            views.brushColors.setSize(coords.brushColors.width, coords.brushColors.height);

            // Create eraser
            // Note: The eraser is the same as a white brush, but with a special icon
            //       to make it more recognizable for users.
            [Embed(source="assets/eraser.png")] var ImageEraser:Class;
            var eraserControl:DisplayObject = new ImageEraser();
            setProperties(eraserControl, coords.eraserControl);
            views.eraser = new HemlockSprite(coords.eraser);
            GraphicsUtils.fill(views.eraser.graphics, coords.eraser);
            views.eraser.addChild(eraserControl);
            views.eraser.updateSize();

            // Create brushThicknesses
            views.brushThicknesses = new HemlockSprite(coords.brushThicknesses);
            for(i = 0, max = widget.BRUSH_THICKNESSES.length; i < max; i++){
                var brushThickness:uint = widget.BRUSH_THICKNESSES[i],
                    brushThicknessBox:HemlockSprite = new HemlockSprite({
                        x:      i * (coords.brushThicknessBox.width + 2),
                        y:      0,
                        data:   { thickness: brushThickness }
                    });
                brushThicknessBox.buttonMode = true;
                with(brushThicknessBox.graphics){
                    // Prop open
                    GraphicsUtils.fill(brushThicknessBox.graphics, coords.brushThicknessBox);

                    // Draw brush thickness
                    beginGradientFill(
                        GradientType.LINEAR,
                            // TODO: Change to GradientType.RADIAL
                        [0x333333, 0x000000], [1, 1], [0, 0x33],
                        HemlockSprite.getVerticalMatrix()
                    );
                    drawCircle(
                        coords.brushThicknessBox.width  * 0.5,
                        coords.brushThicknessBox.height * 0.5,
                        brushThickness * 0.5
                    );
                    endFill();
                }
                views.brushThicknesses.addChild(brushThicknessBox);
                brushThicknessBox.setSize(coords.brushThicknessBox.width, coords.brushThicknessBox.height);
            }
            views.brushThicknesses.setSize(coords.brushThicknesses.width, coords.brushThicknesses.height);

            // Wrap up
            widget.addChildren(
                views.canvas,
                views.clearButton,
                views.brushColors,
                views.eraser,
                views.brushThicknesses
            );
        }



        //--------------------------------------
        //  Helpers
        //--------------------------------------

        internal function resetCanvas(dimensions:Array = null):void{
            widget.clearCoordQueues();

            if(!dimensions){
                dimensions = [views.canvas.width, views.canvas.height];
            }

            with(views.canvas.graphics){
                clear();
                beginFill(0xFFFFFF, 1);
                drawRoundRect(0, 0, dimensions[0], dimensions[1], 10);
                endFill();
            }
        }

        internal function drawLine(options:Object):void{
            Logger.debug('DrawingWidget::drawLine()');

            // TODO: Create alternative for smoother lines (Graphics::curveTo()?)
            // - Event handler should recognize whether user wants to draw an angle or a curve

            // Logger.debug('- '
            //     + options.fromX + ',' + options.fromY + ' to '
            //     + options.toX + ',' + options.toY
            // );

            if(!options.toX || !options.toY || !options.color || !options.thickness){
                return;
            }

            if(options.fromX && options.fromY){
                with(views.canvas.graphics){
                    moveTo(options.fromX, options.fromY);
                    lineStyle(options.thickness, options.color);
                    lineTo(options.toX, options.toY);
                }
            }else{
                drawDot({
                    x:          options.toX,
                    y:          options.toY,
                    color:      options.color,
                    thickness:  options.thickness
                });
            }
        }

        internal function drawDot(options:Object):void{
            Logger.debug('DrawingWidget::drawDot()');

            with(views.canvas.graphics){
                moveTo(options.x, options.y);
                    // Avoids lineTo() artifact bug with Flash 9
                    // Source: http://bugs.adobe.com/jira/browse/FP-753
                beginFill(options.color);
                lineStyle(); // Reset from drawLine()
                drawCircle(options.x, options.y, options.thickness * 0.5);
                endFill();
            }
        }

        private function adjustBrightness(color:uint, delta:int):uint{
            // Based on: http://www.actionscript.org/forums/showpost.php3?p=115392&postcount=4

            var r:uint = color >> 16;
            var g:uint = (color ^ color >> 16 << 16) >> 8;
            var b:uint = color >> 8 << 8 ^ color;

            var rNew:uint = Math.max(0, Math.min(0xFF, r + delta));
            var gNew:uint = Math.max(0, Math.min(0xFF, g + delta));
            var bNew:uint = Math.max(0, Math.min(0xFF, b + delta));

            return rNew << 16 ^ gNew << 8 ^ bNew;
        }

        internal function highlightBrushColor(color:uint):void{
            Logger.debug('DrawingWidget::highlightBrushColor()');

            var borderThickness:uint = 2;

            views.eraser.graphics.clear();
            for(var i:uint = 0, max:uint = views.brushColors.numChildren; i < max; i++){
                var box:HemlockSprite = views.brushColors.getChildAt(i) as HemlockSprite;
                if(box.options.data.color == color){
                    with(views.brushColors.graphics){
                        clear();
                        beginGradientFill(
                            GradientType.LINEAR,
                            [0xFFFFFF, 0x000000], [1, 0.125], [0, 0xFF],
                            HemlockSprite.getVerticalMatrix()
                        );
                        lineStyle(borderThickness, 0x000000, 0.675);
                        drawRoundRect(box.x, box.y, box.width, box.height, 15);
                        endFill();
                    }
                }
            }
        }

        internal function highlightEraser():void{
            Logger.debug('DrawingWidget::highlightEraser()');

            var borderThickness:uint = 2,
                coords:Object = {
                    eraser: {
                        width:  views.eraser.options.width,
                        height: views.eraser.options.height
                    }
                };

            views.brushColors.graphics.clear();
            with(views.eraser.graphics){
                beginGradientFill(
                    GradientType.LINEAR,
                    [0xFFFFFF, 0x000000], [1, 0.125], [0, 0xFF],
                    HemlockSprite.getVerticalMatrix()
                );
                lineStyle(borderThickness, 0x000000, 0.675);
                drawRoundRect(0, 0, coords.eraser.width, coords.eraser.height, 15);
                endFill();
            }
        }

        internal function highlightBrushThickness(thickness:uint):void{
            Logger.debug('DrawingWidget::highlightBrushThickness()');

            var borderThickness:uint = 2;

            for(var i:uint = 0, max:uint = views.brushThicknesses.numChildren; i < max; i++){
                var box:HemlockSprite = views.brushThicknesses.getChildAt(i) as HemlockSprite;
                if(box.options.data.thickness == thickness){
                    with(views.brushThicknesses.graphics){
                        clear();
                        beginGradientFill(
                            GradientType.LINEAR,
                            [0xFFFFFF, 0x000000], [1, 0.125], [0, 0xFF],
                            HemlockSprite.getVerticalMatrix()
                        );
                        lineStyle(borderThickness, 0x000000, 0.675);
                        drawRoundRect(box.x, box.y, box.width, box.height, 15);
                        endFill();
                    }
                }
            }
        }
        
    }
}
