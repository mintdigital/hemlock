package com.mintdigital.hemlockLoaders{
    // Use a HemlockLoader if you want to display a progress bar or other
    // content while loading your HemlockContainer. Write a custom subclass to
    // change this loader's appearance.
    
    // To reduce file sizes of loader swfs, this is NOT compiled with Hemlock.
    // This means:
    // - None of the usual tools are available;
    // - There should be a separate HemlockLoaders.swc binary.
    
    import flash.display.Loader;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.events.ProgressEvent;
    import flash.external.ExternalInterface;
    import flash.net.URLRequest;
    import flash.net.URLVariables;
    import flash.text.TextField;
    import flash.utils.clearInterval;
    import flash.utils.setInterval;
    
    public class HemlockLoader extends Sprite{
        
        public var views:Object = {};
        
        protected const PERCENT_BEFORE_CONTENT_COMPLETE:Number  = 0.9;
            // When the loader content has loaded, _progress should have this
            // maximum value. It should only reach 1.0 when the target
            // content, e.g., HemlockContainer, has dispatched an
            // Event.COMPLETE to signify that it is ready to be displayed.
        protected var skin:*;
        protected var _progress:Number = 0; // 0.0 to 1.0, inclusive
        protected var contentCompletionInterval:uint;
        protected var flashvars:Object;
        
        public function HemlockLoader(){
            initialize();
            flashvars = this.loaderInfo.parameters;
            initializeStage();
            createViews();
            registerListeners();
            
            // Prepare loader
            var url:String = flashvars.loaderURL,
                urlRequest:URLRequest = new URLRequest(url);
            urlRequest.data = objectToURLVariables(flashvars);
                // Here, we use the loader's flashvars when requesting the
                // target swf so that the same flashvars are available to
                // the target. As a result, the target should be able to call
                // `this.loaderInfo.parameters`, and the result should be the
                // same regardless of whether the target had been loaded via
                // a HemlockLoader or straight from HTML.
            
            // Start loading
            views.loader.load(urlRequest);
        }
        
        protected function initialize():void{
            // Override this to use your own skin and other configurations.
            
            skin = {};
            skin.ProgressWrapper            = Sprite; // Class
            skin.PROGRESS_WRAPPER_WIDTH     = this.width; // Number
            skin.PROGRESS_WRAPPER_HEIGHT    = this.height; // Number
        }
        
        protected function initializeStage():void{
            // stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.scaleMode = StageScaleMode.SHOW_ALL;
                // Allow scaling so that browsers' page zoom (not text zoom)
                // doesn't chop off the Flash content.
            stage.align     = StageAlign.TOP_LEFT;
        }
        
        
        
        //--------------------------------------
        //  Views
        //--------------------------------------
        
        protected function createViews():void{
            // Prop open
            with(graphics){
                beginFill(0, 0);
                drawRect(0, 0, width, height);
                endFill();
            }
            
            // Create view for target content
            views.loader = new Loader();
            
            // Create progress views
            views.progressWrapper = new skin.ProgressWrapper();
            with(views.progressWrapper.graphics){
                beginFill(0, 0);
                drawRect(0, 0, skin.PROGRESS_WRAPPER_WIDTH, skin.PROGRESS_WRAPPER_HEIGHT);
                endFill();
            }
            with(views.progressWrapper){
                width   = skin.PROGRESS_WRAPPER_WIDTH;
                height  = skin.PROGRESS_WRAPPER_HEIGHT;
            }
            views.progressWrapper.x = (this.width  - views.progressWrapper.width)  * 0.5;
            views.progressWrapper.y = (this.height - views.progressWrapper.height) * 0.5;
            updateProgressView();
            addChild(views.progressWrapper);
        }
        
        protected function destroyViews():void{
            removeChild(views.progressWrapper);
        }
        
        protected function updateProgressView():void{
            // Updates your progress view according to `progress`. Override
            // this to use your own progress view code.
            
            // log('HemlockLoader::updateProgressView() : progress = ' + progress);
            
            if(!views.progress){
                // TODO: Create a decent default look
                views.progress          = new TextField();
                views.progress.width    = skin.PROGRESS_WRAPPER_WIDTH;
                views.progress.height   = skin.PROGRESS_WRAPPER_HEIGHT;
                views.progressWrapper.addChild(views.progress);
            }
            views.progress.text = 'Loading: ' + Math.round(progress * 100) + '%';
        }
        
        protected function showLoader(loader:Loader):void{
            // log('HemlockLoader::showLoader()');

            // Show target content
            addChild(loader);
            
            // Move views.progressWrapper to front
            setChildIndex(views.progressWrapper, numChildren - 1);
            
            // Start slowly faking progress up to 100%
            contentCompletionInterval = setInterval(function():void{
                var percentLeft:Number  = 1.0 - progress,
                    increment:Number    = Math.min(0.05, percentLeft * 0.5);
                        // Automatically increase by up to 5%, but reduce
                        // increment to simulate approaching 100% without
                        // actually reaching it (theoretically)
                progress = progress + increment;
                updateProgressView();
            }, 1000);
        }
        
        
        
        //--------------------------------------
        //  Events
        //--------------------------------------
        
        protected function registerListeners():void{
            views.loader.contentLoaderInfo.addEventListener(Event.OPEN,             onLoaderOpen);
            views.loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onLoaderProgress);
            views.loader.contentLoaderInfo.addEventListener(Event.COMPLETE,         onLoaderComplete);
        }
        
        protected function onLoaderOpen(event:Event):void{
            // log('HemlockLoader::onLoaderOpen()');
        }
        
        protected function onLoaderProgress(event:ProgressEvent):void{
            // log('HemlockLoader::onLoaderProgress()');
            
            progress = (event.bytesLoaded / event.bytesTotal) * PERCENT_BEFORE_CONTENT_COMPLETE;
                // Reduce progress to indicate that, after the target SWF has
                // loaded, it still needs to dispatch an Event.COMPLETE before
                // everything is fully loaded, e.g., initialization functions.
            updateProgressView();
        }
        
        protected function onLoaderComplete(event:Event):void{
            // log('HemlockLoader::onLoaderComplete()');
            
            views.loader.content.addEventListener(Event.COMPLETE, onLoaderContentComplete);
            showLoader(views.loader);
        }
        
        protected function onLoaderContentComplete(event:Event):void{
            // To trigger this, ensure that your HemlockContainer runs the
            // following when you want the loader views to disappear:
            // 
            //     dispatchEvent(new Event(Event.COMPLETE));
            
            // log('HemlockLoader::onLoaderContentComplete()');
            
            progress = 1;
            updateProgressView();
            destroyViews();
            
            clearInterval(contentCompletionInterval);
            contentCompletionInterval = NaN;
        }
        
        
        
        //--------------------------------------
        //  Helpers
        //--------------------------------------
        
        protected function objectToURLVariables(object:Object):URLVariables{
            var urlVariables:URLVariables = new URLVariables();
            for(var i:String in object){
                urlVariables[i] = object[i];
            }
            return urlVariables;
        }
        
        protected function log(description:String, value:* = undefined):void{
            if(!ExternalInterface.available){ return; }
            
            var output:String = description;
            if(value !== undefined){ output += ' = ' + value; }
            ExternalInterface.call('function(){ console.log("' + output + '"); }');
        }
        
        
        
        //--------------------------------------
        //  Properties
        //--------------------------------------
        
        override public function get width():Number { return stage.stageWidth; }
        override public function get height():Number{ return stage.stageHeight; }
        
        protected function get progress():Number            { return _progress; }
        protected function set progress(value:Number):void  { _progress = Math.max(0.0, Math.min(1.0, value)); }
        
    }
}
