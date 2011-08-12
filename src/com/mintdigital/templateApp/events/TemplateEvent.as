package com.mintdigital.templateApp.events{
    import com.mintdigital.hemlock.events.HemlockEvent;
    import flash.events.Event;

    public class TemplateEvent extends HemlockEvent{

        //  When creating your own Hemlock app:
        //
        //  1.  Copy `TemplateEvent.as` to your app's `events` directory,
        //      rename the file, and update all mentions of `TemplateEvent` to
        //      match your new event's name.
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

        public static const TYPE_ONE:String     = 'template_typeOne';
        public static const TYPE_TWO:String     = 'template_typeTwo';
        public static const TYPE_THREE:String   = 'template_typeThree';

        public static const TYPES:Array /* of Strings */ = [
            TYPE_ONE, TYPE_TWO, TYPE_THREE
        ];

        public function TemplateEvent(type:String, options:Object = null){
            super(type, options);
        }

        override public function clone():Event{
            return new TemplateEvent(type, options);
        }

        override public function toString():String{
            return formatHemlockEventToString('TemplateEvent');
        }

    }
}
