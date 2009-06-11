package com.mintdigital.hemlock.display {
    import flash.display.Sprite;
    import flash.display.Stage;

    public class SystemNotificationManager extends Object {
    
        private var _container:Sprite;
        private var _stage:Stage;
        private var _systemNotifications:Array = [];
        private var _queueRunning:Boolean = false;
        
        public function SystemNotificationManager(container:Sprite,stage:Stage) {
            super();
            _container = container;
            _stage = stage;
        }
    
        public function createNotification(message:String, error:String, duration:int):void {
            var notif:SystemNotification = new SystemNotification(_stage, message || error, {
                type: error ? SystemNotification.TYPE_ERROR : SystemNotification.TYPE_MESSAGE, 
                duration: duration
            });
            _systemNotifications.push(notif);
            if(!_queueRunning)
                runQueue();
        }
    
        private function runQueue():void {
            var notif:SystemNotification = _systemNotifications.shift();
            if(notif) {
                _queueRunning = true;
                displayNotification(notif);
            } else {
                _queueRunning = false;
            }    
        }
    
        private function displayNotification(notif:SystemNotification):void {
            notif.displayIn(_container, runQueue);
        }
    
    }
}
