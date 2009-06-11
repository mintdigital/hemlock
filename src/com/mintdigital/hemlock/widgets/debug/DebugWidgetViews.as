package com.mintdigital.hemlock.widgets.debug{
    import com.mintdigital.hemlock.widgets.IDelegateViews;
    import com.mintdigital.hemlock.widgets.HemlockWidget;
    import com.mintdigital.hemlock.widgets.HemlockWidgetDelegate;
    import com.mintdigital.hemlock.controls.HemlockScrollBar;
    
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;
    import flash.display.Sprite;
    
    public class DebugWidgetViews extends HemlockWidgetDelegate implements IDelegateViews{
        public function DebugWidgetViews(widget:HemlockWidget){
            super(widget);
        }
 
        public function createViews():void{
            views.colors = {
                dark:   0x000000,
                light:  0x009900
            };

            // Prepare positions and sizes
            var positions:Object = {}, sizes:Object = {};
            sizes.toggle = {
                width:  120,
                height: 20
            };
            positions.log = { x: 0, y: 0 };
            sizes.log = {
                width:  options.width,
                height: options.height - sizes.toggle.height
            };
            sizes.controlPanel = {
                width:  sizes.log.width - 10,
                height: 20
            };
            sizes.logScrollBar = { thickness: 10 };
            positions.logText = { x: 5, y: 5 };
            sizes.logText = {
                width:  sizes.log.width - (positions.logText.x * 3) - sizes.logScrollBar.thickness,
                height: sizes.log.height - (positions.logText.y * 3) - sizes.controlPanel.height
            };
            positions.logScrollBar = {
                x:  positions.logText.x + sizes.logText.width + positions.logText.x,
                y:  positions.logText.y
            };
            positions.controlPanel = {
                x:  positions.logText.x,
                y:  positions.logText.y + sizes.logText.height + 5
            };
            positions.toggle = {
                x:  options.width - sizes.toggle.width,
                y:  positions.log.y + sizes.log.height
            };

            // Create log
            views.log = new Sprite();
            views.log.graphics.beginFill(views.colors.dark, 0.85);
            views.log.graphics.drawRect(0, 0, sizes.log.width, sizes.log.height);
            views.log.graphics.endFill();
            with(views.log){
                width   = sizes.log.width;
                height  = sizes.log.height;
            }

            // Create log text
            views.logText = new TextField();
            with(views.logText){
                width       = sizes.logText.width;
                height      = sizes.logText.height;
                x           = positions.logText.x;
                y           = positions.logText.y;
                alwaysShowSelection = true;
                wordWrap    = true;
            }

            // Create log text format
            var logTextFormat:TextFormat = new TextFormat();
            logTextFormat.color = views.colors.light;
            logTextFormat.font  = 'Courier';
            logTextFormat.size  = 12;
            views.logText.setTextFormat(views.logText.defaultTextFormat = logTextFormat);

            // Initialize log text
            widget.resetText();

            // Create log scrollbar
            views.logScrollBar = new HemlockScrollBar(views.logText, {
                x:          positions.logScrollBar.x,
                y:          positions.logScrollBar.y,
                thickness:  sizes.logScrollBar.thickness,
                colors:     {
                    thumb:  views.colors.light
                }
            });

            // Create views.controlPanel and views.controls
            createControls(positions, sizes);

            // Initialize log
            views.log.visible = false;
            views.log.addChild(views.logText);
            views.log.addChild(views.controlPanel);
            views.log.addChild(views.logScrollBar);
            views.log.width     = sizes.log.width;
            views.log.height    = sizes.log.height;

            // Create toggle control
            views.toggle = new TextField();
            views.toggle.width          = sizes.toggle.width;
            views.toggle.height         = sizes.toggle.height;
            views.toggle.x              = positions.toggle.x;
            views.toggle.y              = positions.toggle.y;
            views.toggle.background     = true;
            views.toggle.backgroundColor= views.colors.dark;
            views.toggle.selectable     = false;
            views.toggle.text           = 'show debugger';

            // Create toggle control format
            var toggleFormat:TextFormat = new TextFormat();
            toggleFormat.align  = TextFormatAlign.CENTER;
            toggleFormat.color  = views.logText.defaultTextFormat.color;
            toggleFormat.font   = views.logText.defaultTextFormat.font;
            toggleFormat.size   = 12;
            views.toggle.setTextFormat(views.toggle.defaultTextFormat = toggleFormat);

            // Add views
            widget.addChild(views.log);
            widget.addChild(views.toggle);
            widget.updateSize();
        }

        private function createControls(positions:Object, sizes:Object):void{
            // Create controls background
            views.controlPanel = new Sprite();
            with(views.controlPanel.graphics){
                beginFill(0, 0); // Prop open
                drawRect(0, 0, sizes.controlPanel.width, sizes.controlPanel.height);
                endFill();
            }
            with(views.controlPanel){
                x       = positions.controlPanel.x;
                y       = positions.controlPanel.y;
            }

            views.controls = {};

            // Create control format
            var controlFormat:TextFormat = new TextFormat();
            controlFormat.align = TextFormatAlign.CENTER;
            controlFormat.color = views.colors.dark;
            controlFormat.font  = views.logText.defaultTextFormat.font;
            controlFormat.size  = 12;

            // Create "mark" control
            views.controls.mark = new TextField();
            with(views.controls.mark){
                width   = 50;
                text    = 'mark';
            }

            // Create "clear" control
            views.controls.clear = new TextField();
            with(views.controls.clear){
                width   = 50;
                text    = 'clear';
            }

            // Create "select all" control
            views.controls.copyAll = new TextField();
            with(views.controls.copyAll){
                width   = 70;
                text    = 'copy all';
            }

            // Make controls uniform
            var orderedControls:Array = [
                views.controls.mark,
                views.controls.copyAll,
                views.controls.clear
            ];
            for(var i:uint, numControls:uint = orderedControls.length; i < numControls; i++){
                var control:TextField = orderedControls[i];
                control.height          = views.controlPanel.height;
                control.x               = (i > 0 ? orderedControls[i-1].x + orderedControls[i-1].width + 5 : 0);
                control.background      = true;
                control.backgroundColor = views.colors.light;
                control.selectable      = false;
                control.setTextFormat(control.defaultTextFormat = controlFormat);
                views.controlPanel.addChild(control);
            }
        }       
    }
}