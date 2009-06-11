package com.mintdigital.hemlock.clients{
    import com.mintdigital.hemlock.HemlockEnvironment;
    import com.mintdigital.hemlock.Logger;
    import flash.net.URLLoader;
    import flash.net.URLLoaderDataFormat;
    import flash.net.URLRequest;
    import flash.net.URLRequestMethod;
    import flash.net.URLVariables;
    import flash.events.Event;
    
    public class HTTPClient {
        private var _apiRoot:String;
        
        public function HTTPClient(apiRoot:String){
            _apiRoot = apiRoot;
        }
        
        //TODO should return boolean
        // TODO: Don't accept just one listener function, but options hash
        // - Desired function call: get('/some/url', { onComplete: ..., onError: ... })
        // - Also do this with post()
        public function get(resource:String, listener:Function=null):void{
            var request:URLRequest = new URLRequest();
            request.url = _apiRoot + resource;

            var loader:URLLoader = new URLLoader();
            
            if(listener != null){
                loader.addEventListener(Event.COMPLETE, listener);   
            }
            
            try{
                loader.load(request);
            }catch(error:Error){
                Logger.fatal('HTTPClient::get() : Failed to load URL: '
                    + request.url + ' | Error: ' + error);
            }
        }

        public function post(resource:String, options:String):Object{
            var variables:URLVariables = new URLVariables(options);

            var request:URLRequest = new URLRequest();
            request.url = _apiRoot + resource;
            request.method = URLRequestMethod.POST;
            request.data = variables;

            var loader:URLLoader = new URLLoader();
            loader.dataFormat = URLLoaderDataFormat.VARIABLES;
            try{
                loader.load(request);
            }catch(error:Error){
                Logger.fatal('HTTPClient::post() : Failed to load URL: '
                    + request.url + ' | Error: ' + error);
            }
            
            return loader.data;
        }
    }
}