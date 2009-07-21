package com.mintdigital.hemlock.widgets.template{
    import com.mintdigital.templateApp.events.TemplateEvent;

    import com.mintdigital.hemlock.Logger;
    import com.mintdigital.hemlock.display.HemlockSprite;
    import com.mintdigital.hemlock.utils.HashUtils;
    import com.mintdigital.hemlock.widgets.HemlockWidget;

    public class TemplateWidget extends HemlockWidget{

        // When creating your own Hemlock app:
        //
        // 1. Copy `com/mintdigital/templateApp/widgets/template` to your
        //    app's `widgets` directory, rename the files inside, and update
        //    all mentions of `TemplateWidget` to match your new widget's
        //    name.
        //
        // 2. Update `TemplateWidgetViews.as` according to its instructions.
        //
        // 3. Update `TemplateWidgetEvents.as` according to its instructions.

        public function TemplateWidget(parentSprite:HemlockSprite, options:Object = null){
            super(parentSprite, HashUtils.merge({
                delegates: {
                    views:  new TemplateWidgetViews(this),
                    events: new TemplateWidgetEvents(this)
                }
            }, options));
        }

    }
}
