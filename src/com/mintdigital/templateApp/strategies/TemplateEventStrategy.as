package com.mintdigital.templateApp.strategies{
    import com.mintdigital.templateApp.events.TemplateEvent;

    import com.mintdigital.hemlock.data.JID;
    import com.mintdigital.hemlock.strategies.IEventStrategy;
    import com.mintdigital.hemlock.strategies.DataMessageEventStrategy;

    public class TemplateEventStrategy extends DataMessageEventStrategy implements IEventStrategy{

        //  When creating your own Hemlock app:
        //
        //  1.  Copy `TemplateEventStrategy.as` to your app's `strategies`
        //      directory, rename the file, and update all mentions of
        //      `TemplateEventStrategy` to match your new strategy's name.
        //
        //  2.  OPTIONAL: In most cases, just copying this constructor will
        //      do. However, you can override `getEventOptions` to transform
        //      event options based on the event type. See the example below,
        //      which takes JID strings and converts them into actual JID
        //      objects.

        public function TemplateEventStrategy(){
            super({
                eventClass: TemplateEvent,
                eventTypes: TemplateEvent.TYPES
            });
        }

        /*
        override protected function getEventOptions(eventType:String, options:Object):Object{
            switch(eventType){
                case TemplateEvent.TYPE_ONE:
                    if(options.someJID){
                        // Convert from String to JID
                        options.someJID = new JID(options.someJID);
                    }
                    break;
            }
            return options;
        }
        */

    }
}
