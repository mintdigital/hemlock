// For com.mintdigital.hemlock.widgets.countdown.CountdownWidget

override public function registerListeners():void{
    registerListener(timer, TimerEvent.TIMER, onTimerEvent);
    registerListener(timer, TimerEvent.TIMER_COMPLETE, onTimerEvent);
}



//--------------------------------------
//  Handlers
//--------------------------------------

private function onTimerEvent(event:TimerEvent):void{
    switch(event.type){
        case TimerEvent.TIMER:
            setSeconds(timer.repeatCount - timer.currentCount);
            break;
        case TimerEvent.TIMER_COMPLETE:
            reset();
            break;
    }
}
