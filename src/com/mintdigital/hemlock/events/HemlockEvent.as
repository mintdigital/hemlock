package com.mintdigital.hemlock.events{
    import com.mintdigital.hemlock.data.JID;
    
    import flash.events.Event;
  
    public class HemlockEvent extends Event{
        // Base class for all custom Hemlock events.
        
        /*
        HemlockEvent subclasses should have their own set of public static
        constants here, such as SEND and RECEIVE. Their values should be
        namespaced according to the event's name. Examples:
        - FooEvent.SEND = 'foo_send'
        - BarEvent.RECEIVE = 'bar_receive'
        - FooBarEvent.SEND_SUCCESS = 'fooBar_sendSuccess'
        */
        
        private var _createdAt:Date;
        private var _options:Object;
        
        public function HemlockEvent(type:String, options:Object = null){
            _options = options || {};
            _createdAt = _options.createdAt || new Date();
                // TODO: Ensure that _createdAt stores UTC time. Convert to local time only in views
            _options.bubbles = _options.bubbles || false;
            _options.cancelable = _options.cancelable || false;

            super(type, _options.bubbles, _options.cancelable);
        }
        
        public function get createdAt():Date    { return _createdAt; }
        public function get options():Object    { return _options; }
        
        // Getters for frequently-used options:
        public function get message():String    { return _options.message; }
        public function get error():String      { return _options.error; }
        public function get errorCode():Number  { return _options.errorCode; }
        public function get from():JID          { return new JID(_options.from.toString()); }
        override public function get bubbles():Boolean   { return _options.bubbles; }
        override public function get cancelable():Boolean{ return _options.cancelable; }
        
        protected function formatHemlockEventToString(eventClass:String):String{
            return formatToString(eventClass, 'type', 'message', 'error', 'errorCode', 'from');
        }
        
        // Subclasses should override the following:
        
        override public function clone():Event{
            return new HemlockEvent(type, options);
        }

        override public function toString():String{
            return formatHemlockEventToString('HemlockEvent');
        }
    }
}
