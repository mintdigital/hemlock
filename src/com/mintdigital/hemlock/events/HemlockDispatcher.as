package com.mintdigital.hemlock.events{
    import flash.events.EventDispatcher;

    public class HemlockDispatcher extends EventDispatcher{

        private static var _instance:HemlockDispatcher;

        public function HemlockDispatcher(enforcer:SingletonEnforcer){
            super();
        }

        public static function getInstance():HemlockDispatcher{
            if(!HemlockDispatcher._instance){
                HemlockDispatcher._instance = new HemlockDispatcher(new SingletonEnforcer());
            }
            return HemlockDispatcher._instance;
        }

    }
}

class SingletonEnforcer{}
