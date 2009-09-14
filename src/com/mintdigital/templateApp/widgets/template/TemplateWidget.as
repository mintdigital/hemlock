package %%widget_package%%{
    // import %%app_package%%.events.TemplateEvent;

    import com.mintdigital.hemlock.Logger;
    import com.mintdigital.hemlock.display.HemlockSprite;
    import com.mintdigital.hemlock.utils.HashUtils;
    import com.mintdigital.hemlock.widgets.HemlockWidget;

    public class %%widget_class%% extends HemlockWidget{

        //  When creating your own Hemlock app:
        //
        //  1.  Run `rake hemlock:generate:widget[%%widget_key%%]`,
        //      which generates `%%widget_class%%.as` and supporting files.
        //
        //  2.  Update `%%widget_events_class%%.as` according to its instructions.
        //
        //  3.  Update `%%widget_views_class%%.as` according to its instructions.

        public function %%widget_class%%(parentSprite:HemlockSprite, options:Object = null){
            super(parentSprite, HashUtils.merge({
                delegates: {
                    views:  new %%widget_views_class%%(this),
                    events: new %%widget_events_class%%(this)
                }
            }, options));
        }

    }
}
