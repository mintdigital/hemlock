package com.mintdigital.hemlock.events{
    import com.mintdigital.hemlock.data.JID;
    
    import flash.events.Event;

    // This event is used for standard app communication (i.e., between
    // XMPPClient and container/widgets).
    
    // When creating new types of events, create a subclass of HemlockEvent.
    
    final public class AppEvent extends HemlockEvent{
        
        public static const ROOM_JOINED:String              = 'room_joined';        // Current user has joined a room
            // TODO: Rename to ROOM_JOIN
        public static const ROOM_LEAVE:String               = 'room_leave';         // Current user has left a room
        public static const ROOM_USER_JOIN:String           = 'room_userJoin';      // Another user has joined the room
        public static const ROOM_USER_LEAVE:String          = 'room_userLeave';     // Another user has left the room
        public static const ROOM_CONFIGURED:String          = 'room_configured';    // Final step of updating a room's configuration

        public static const PRESENCE_CREATE:String          = 'presence_create';
        public static const PRESENCE_UPDATE:String          = 'presence_update';
        
        // TODO: Move to separate ChatEvent class
        public static const CHAT_MESSAGE:String             = 'message_chatMessage';    // Chat message
        public static const CHATROOM_STATUS:String          = 'chatroom_status';
            // TODO: Rename to CHAT_STATUS
                
        public static const CONFIGURATION_COMPLETE:String   = 'configuration_complete';
        public static const CONFIGURATION_START:String      = 'configuration_start';
        public static const CONFIGURATION_ERROR:String      = 'configuration_error';
        
        public static const DISCOVERY_ITEMS_FOUND:String    = 'discovery_itemsFound';
        public static const DISCOVERY_USERS_FOUND:String    = 'discovery_itemsFound';
        
        public static const CONNECTION_DESTROY:String       = 'connection_destroy';
        public static const IO_ERROR:String                 = 'io_error';
        public static const STREAM_ERROR:String             = 'stream_error';

        public static const SESSION_CREATE_SUCCESS:String   = 'session_createSuccess';
        public static const SESSION_CREATE_FAILURE:String   = 'session_createFailure';
        public static const SESSION_DESTROY:String          = 'session_destroy';
        
        public static const REGISTRATION_ERRORS:String      = 'registration_errors';
        public static const REGISTRATION_START:String       = 'registration_start';
        
        public static const VERSION:String                  = 'version';
        public static const VERSION_REQUEST:String          = 'version_request';
        
        public static const AFFILIATION_UPDATE:String       = 'affiliation_update';
        public static const ITEM_UPDATE:String              = 'item_update';
        public static const ROLE_UPDATE:String              = 'role_update';
        
        public function AppEvent(type:String, options:Object = null){
            super(type, options);
        }
        
        override public function clone():Event{
            return new AppEvent(type, options);
        }
        
        override public function toString():String{
              return formatHemlockEventToString('AppEvent');
        }

        public function get jid():JID { return options.jid; }
        
    }
}
