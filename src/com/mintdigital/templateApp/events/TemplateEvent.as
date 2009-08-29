package %%package_name%%.events{
    import com.mintdigital.hemlock.events.HemlockEvent;
    import flash.events.Event;

    public class %%event_name%% extends HemlockEvent{

        //  When creating your own Hemlock app:
        //
        //  1.  Run `rake hemlock:generate:container[MyApp]`, changing `MyApp`
        //      to your app's real name.
        //
        //  2.  Replace `TYPE_ONE`, etc. with the event types you plan to use.
        //      For example, if you're creating `GameEvent`, you might want to
        //      define `GameEvent.BEGIN`, `GameEvent.END`, and
        //      `GameEvent.STATE` (for periodically sending the state of the
        //      game to each user to ensure proper data syncing).
        //
        //  3.  Update the `TYPES` array to list your event types.
        //
        //  4.  Update the event's matching strategy (see
        //      `TemplateEventStrategy.as`) as needed.

        public static const TYPE_ONE:String     = '%%app_name_downcase_first%%_typeOne';
        public static const TYPE_TWO:String     = '%%app_name_downcase_first%%_typeTwo';
        public static const TYPE_THREE:String   = '%%app_name_downcase_first%%_typeThree';

        public static const TYPES:Array /* of Strings */ = [
            TYPE_ONE, TYPE_TWO, TYPE_THREE
        ];

        public function %%event_name%%(type:String, options:Object = null){
            super(type, options);
        }

        override public function clone():Event{
            return new %%event_name%%(type, options);
        }

        override public function toString():String{
            return formatHemlockEventToString('%%event_name%%');
        }

    }
}
