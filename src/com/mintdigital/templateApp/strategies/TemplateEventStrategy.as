package %%app_package%%.strategies{
    import %%app_package%%.events.%%event_class%%;

    import com.mintdigital.hemlock.data.JID;
    import com.mintdigital.hemlock.strategies.IEventStrategy;
    import com.mintdigital.hemlock.strategies.DataMessageEventStrategy;

    public class %%strategy_class%% extends DataMessageEventStrategy implements IEventStrategy{

        //  When creating your own Hemlock app:
        //
        //  1.  Run `rake hemlock:generate:container[%%container_key%%]`,
        //      which generates `%%container_class%%.as` and others.
        //
        //  2.  OPTIONAL: In most cases, just the constructor will do.
        //      However, you can override `getEventOptions` to transform event
        //      options based on the event type. See the example below, which
        //      converts JID strings into actual JID objects.

        public function %%strategy_class%%(){
            super({
                eventClass: %%event_class%%,
                eventTypes: %%event_class%%.TYPES
            });
        }

        /*
        override protected function getEventOptions(eventType:String, options:Object):Object{
            switch(eventType){
                case %%event_class%%.TYPE_ONE:
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
