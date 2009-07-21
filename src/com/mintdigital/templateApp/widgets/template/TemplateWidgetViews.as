package com.mintdigital.templateApp.widgets.template{
    import com.mintdigital.hemlock.Logger;
    import com.mintdigital.hemlock.display.HemlockSprite;
    import com.mintdigital.hemlock.utils.GraphicsUtils;
    import com.mintdigital.hemlock.utils.setProperties;
    import com.mintdigital.hemlock.widgets.IDelegateViews;
    import com.mintdigital.hemlock.widgets.HemlockWidget;
    import com.mintdigital.hemlock.widgets.HemlockWidgetDelegate;

    import flash.display.Shape;

    public class TemplateWidgetViews extends HemlockWidgetDelegate implements IDelegateViews{

        //  When creating your own Hemlock app:
        //
        //  1.  Follow the initial instructions in `TemplateWidget.as`.
        //
        //  2.  Update the `createViews` function to create the views (e.g.,
        //      backgrounds, controls) that you need to start with. Start by
        //      building the `coords` object, then create the actual views.
        //
        //  3.  In the `Helpers` section, write any other functions you'll
        //      need for creating or updating views during run-time. These
        //      should typically use the `internal` namespace so they can be
        //      used by the events delegate (see `TemplateWidgetEvents.as`).

        public function TemplateWidgetViews(widget:HemlockWidget){
            super(widget);
        }



        //--------------------------------------
        //  Initializers
        //--------------------------------------

        public function createViews():void{
            // `createViews()` is called automatically when the container
            // instantiates this widget.

            // Prepare coordinates
            var coords:Object = {};
            coords.widget = {
                width:  options.width,
                height: options.height
            };
            coords.myView = {
                width:  100,
                height: 100
            };
            coords.myView.x = (coords.widget.width  - coords.myView.width)  * 0.5;
            coords.myView.y = (coords.widget.height - coords.myView.height) * 0.5;
                // These x/y values will position `views.myView` (below) in
                // horizontal and vertical center of the widget.
            // [Add more view coordinates here]

            // Create background
            views.bg = new Shape();
                // Here, we opt to create a `Shape` to save memory; a `Shape`
                // object doesn't respond to user input, such as clicks.
            GraphicsUtils.fill(views.bg.graphics, coords.widget);
                // `GraphicsUtils.fill()` is used to prop open `views.bg` so
                // that it renders with the correct dimensions. Use this
                // *before* calling `setProperties`.
                //
                // To use `GraphicsUtils.fill()` to test the position and size
                // of `views.bg`, use:
                //
                //     GraphicsUtils.fill(views.bg.graphics, coords.widget, 0xFF0000, 1.0);
                //
                // `0x00FF00` is a hexadecimal color code for bright green,
                // and `1.0` is an alpha value indicating full color opacity.
            setProperties(views.bg, coords.widget);
                // Sets both the position and size of `views.bg` according to
                // `coords.widget`.

            // Create some other view
            views.myView = new HemlockSprite(coords.myView);
            GraphicsUtils.fill(views.myView.graphics, coords.myView);

            // Wrap up
            widget.addChildren(
                views.bg,
                views.myView
                // [Add more views here]
            );
        }



        //--------------------------------------
        //  Helpers
        //--------------------------------------

        // internal function doSomething():void{ ... }

    }
}
