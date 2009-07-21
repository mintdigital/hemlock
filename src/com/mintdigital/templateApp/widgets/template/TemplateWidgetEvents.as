package com.mintdigital.templateApp.widgets.template{
    import com.mintdigital.hemlock.Logger;
    import com.mintdigital.hemlock.widgets.IDelegateEvents;
    import com.mintdigital.hemlock.widgets.HemlockWidget;
    import com.mintdigital.hemlock.widgets.HemlockWidgetDelegate;

    public class TemplateWidgetEvents extends HemlockWidgetDelegate implements IDelegateEvents{

        //  When creating your own Hemlock app:
        //
        //  1.  Follow the initial instructions in `TemplateWidget.as`.
        //
        //  2.  Update the `registerListeners` function to listen to events
        //      either from views (i.e., controls that the user interacts
        //      with), or from the network. If the container needs to handle
        //      network data before widgets do (e.g., the container must first
        //      update its model), the widget should listen to the container,
        //      which handles and re-dispatches the event when ready.
        //      Otherwise, if the container need not be involved, the widget
        //      can listen directly to `widget.dispatcher`.
        //
        //  3.  In the `Handlers` sections, implement all handlers used in
        //      `registerListeners`. These handler functions are typically
        //      `private`.

        public function TemplateWidgetEvents(widget:HemlockWidget){
            super(widget);
        }



        //--------------------------------------
        //  Initializers
        //--------------------------------------

        public function registerListeners():void{
            // `registerListeners()` is called automatically when the
            // container instantiates this widget.

            // Register view listeners
            widget.registerListener(views.myView,   MouseEvent.CLICK,       onMyViewClick);

            // Register container/dispatcher listeners
            widget.registerListener(container,      TemplateEvent.TYPE_ONE, onTemplateTypeOne);
            widget.registerListener(container,      TemplateEvent.TYPE_TWO, onTemplateTypeTwo);
        }



        //--------------------------------------
        //  Handlers > Views
        //--------------------------------------

        internal function onMyViewClick(event:MouseEvent):void{
            // ...
        }



        //--------------------------------------
        //  Handlers > App
        //--------------------------------------

        internal function onTemplateTypeOne(event:TemplateEvent):void{
            // ...
        }

        internal function onTemplateTypeTwo(event:TemplateEvent):void{
            // ...
        }

    }
}
