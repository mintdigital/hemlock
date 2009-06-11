package com.mintdigital.hemlock.widgets.debug{
    import com.mintdigital.hemlock.widgets.IDelegateEvents;
    import com.mintdigital.hemlock.widgets.HemlockWidget;
    import com.mintdigital.hemlock.widgets.HemlockWidgetDelegate;
    
    import flash.events.MouseEvent;
    import flash.system.System;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;
        
    public class DebugWidgetEvents extends HemlockWidgetDelegate implements IDelegateEvents{
        
        public function DebugWidgetEvents(widget:HemlockWidget){
            super(widget);
        }
        
        public function registerListeners():void{
            widget.registerListener(views.toggle,              MouseEvent.CLICK,   onLogToggle);
            widget.registerListener(views.controls.mark,       MouseEvent.CLICK,   onControlMarkClick);
            widget.registerListener(views.controls.clear,      MouseEvent.CLICK,   onControlClearClick);
            widget.registerListener(views.controls.copyAll,    MouseEvent.CLICK,   onControlCopyAllClick);
        }

        //--------------------------------------
        //  Handlers
        //--------------------------------------

        private function onLogToggle(event:MouseEvent):void{
            if(views.log.visible){
                views.log.visible = false;
                views.toggle.text = 'show debugger';
                views.toggle.backgroundColor= views.colors.dark;
                views.toggle.textColor      = views.colors.light;
            }else{
                views.log.visible = true;
                views.toggle.text = 'hide debugger';
                views.toggle.backgroundColor= views.colors.light;
                views.toggle.textColor      = views.colors.dark;
            }
        }

        private function onControlMarkClick(event:MouseEvent):void{
            widget.addText('\n---------------------------------------');
            widget.addText('-- ' + new Date() + ' --');
            widget.addText("---------------------------------------\n");
        }

        private function onControlClearClick(event:MouseEvent):void{
            widget.resetText();
        }

        private function onControlCopyAllClick(event:MouseEvent):void{
            views.logText.setSelection(0, views.logText.length - 1);
            System.setClipboard(views.logText.text);
        }

    }
}