package %%package_name%%.strategies{
    import %%package_name%%.events.%%event_name%%;

    import com.mintdigital.hemlock.data.JID;
    import com.mintdigital.hemlock.strategies.IEventStrategy;
    import com.mintdigital.hemlock.strategies.DataMessageEventStrategy;

    public class %%strategy_name%% extends DataMessageEventStrategy implements IEventStrategy{

        //  When creating your own Hemlock app:
        //
        //  1.  Run `rake hemlock:generate:container[MyApp]`, changing `MyApp`
        //      to your app's real name.
        //
        //  2.  OPTIONAL: In most cases, just copying this constructor will
        //      do. However, you can override `getEventOptions` to transform
        //      event options based on the event type. See the example below,
        //      which takes JID strings and converts them into actual JID
        //      objects.

        public function %%strategy_name%%(){
            super({
                eventClass: %%event_name%%,
                eventTypes: %%event_name%%.TYPES
            });
        }

        /*
        override protected function getEventOptions(eventType:String, options:Object):Object{
            switch(eventType){
                case %%event_name%%.TYPE_ONE:
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
