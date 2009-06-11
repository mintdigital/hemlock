package com.mintdigital.hemlock.widgets.debug{
    import com.mintdigital.hemlock.Logger;
    import com.mintdigital.hemlock.HemlockEnvironment;
    import com.mintdigital.hemlock.display.HemlockSprite;
    import com.mintdigital.hemlock.widgets.HemlockWidget;
    import com.mintdigital.hemlock.events.AppEvent;
    import com.mintdigital.hemlock.utils.HashUtils;
    
    import flash.events.Event;
    import flash.display.BlendMode;
    import flash.system.Security;
    
    public class DebugWidget extends HemlockWidget {
        
        private var eventTypes:Object;
        
        public function DebugWidget(parentSprite:HemlockSprite, options:Object = null){
            Logger.addLogFunction(addText);
            super(parentSprite, HashUtils.merge({
                delegates: {
                    views: new DebugWidgetViews(this),
                    events: new DebugWidgetEvents(this)
                }
            }, options));
        }
        
        public function addText(text:String):void{
            var scrollToBottom:Boolean = (
                views.logText.scrollV == 0
                || views.logText.scrollV == views.logText.maxScrollV
                );
            views.logText.text += text + "\n";
            views.logText.dispatchEvent(new Event(Event.CHANGE)); // Notify scrollbar
            if(scrollToBottom){
                views.logText.scrollV = views.logText.maxScrollV;
            }
        }
        
        public function resetText():void{
            views.logText.text = '';
            addText("Hemlock debug log\n");
            addText('Server: ' + HemlockEnvironment.SERVER);
            addText('Security.sandboxType: ' + Security.sandboxType);
            
            // TODO: Add hook for showing anything else, like latest Git commit
        }
        
    }
}
