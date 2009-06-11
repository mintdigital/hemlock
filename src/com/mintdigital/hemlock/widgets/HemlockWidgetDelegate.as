package com.mintdigital.hemlock.widgets{
    import com.mintdigital.hemlock.HemlockEnvironment;
    import com.mintdigital.hemlock.data.JID;
    import com.mintdigital.hemlock.events.HemlockDispatcher;
    
    public class HemlockWidgetDelegate{
        private var _widget:HemlockWidget;
        
        public function HemlockWidgetDelegate(widget:HemlockWidget){
            _widget = widget;
        }
        
        
        
        //--------------------------------------
        //  Properties
        //--------------------------------------
        
        public function get widget():*              { return _widget; }
        public function get container():*           { return widget.container; }
        public function get dispatcher():HemlockDispatcher { return widget.dispatcher; }
        public function get delegates():Object      { return widget.delegates; }
        public function get jid():JID               { return widget.jid; }
        public function get options():Object        { return widget.options; }
        public function get skin():*                { return HemlockEnvironment.SKIN; }
        public function get views():Object          { return widget.views; }
        
    }
}
