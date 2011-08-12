package com.mintdigital.hemlock.widgets.roomList {
    import com.mintdigital.hemlock.HemlockEnvironment;
    import com.mintdigital.hemlock.Logger;
    import com.mintdigital.hemlock.controls.HemlockButton;
    import com.mintdigital.hemlock.controls.HemlockTextInput;
    import com.mintdigital.hemlock.data.JID;
    import com.mintdigital.hemlock.display.HemlockLabel;
    import com.mintdigital.hemlock.display.HemlockSprite;
    import com.mintdigital.hemlock.utils.HashUtils;
    import com.mintdigital.hemlock.widgets.HemlockWidget;
    
    import flash.display.BlendMode;
    import flash.display.DisplayObject;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.events.TextEvent;
    import flash.text.AntiAliasType;
    import flash.text.TextField;
    import flash.text.TextFieldType;
    import flash.text.StyleSheet;
    
    public class RoomListWidget extends HemlockWidget {
        
        public static const SCREEN_LIST:String  = 'screen_list';
        public static const SCREEN_FORM:String  = 'screen_form';

        private var eventTypes:Object;
        protected var _room:String = 'roomList';
        internal var rooms:Object = {};
        private var _configOptions:Object = {};
        private var _toJID:JID;
        protected static var _defaultOptions:Object = {
            maxParticipants:        0, // 0: Unlimited participants
            headerColor:            0x000000,
            roomTitleColor:         0x000000,
            roomMetaColor:          0x000000,
            strings: {
                allRooms:           'Current rooms',
                newRoomButton:      'Start a new room',
                noRooms:            'No rooms yet',
                newRoomLabel:       'Room details:',
                createRoomButton:   'Create my room!',
                joinRoomButton:     'Join room',
                participant:        'person',
                participants:       'people'
            }
        };
        
        public function RoomListWidget(parentSprite:HemlockSprite, options:Object = null){
            options = HashUtils.merge(_defaultOptions, options);
            super(parentSprite, HashUtils.merge({
                delegates: {
                    views:  new RoomListWidgetViews(this),
                    events: new RoomListWidgetEvents(this) 
                }
            }, options));
        }
        
        
        
        //--------------------------------------
        //  Internal helpers
        //--------------------------------------
        
        internal function updateRoomList(items:Array /* of * */):Array{
            // Adds JIDs of items to `rooms` that aren't already there, and
            // returns an array of all items that were added.
            
            var currentItems:Array /* of * JID strings */ = [];
            var item:*;
            var listItem:HemlockSprite;
            for each(item in items){
                if(item.name.replace(/\s*\((\w+\,\s)?\d+\)$/g, '') != 'session'){
                    // We want to keep track of all items that should 
                    // still be in the room list.
                    currentItems.push(item.jid);
                    
                    if(HashUtils.keys(rooms).indexOf(item.jid) >= 0){
                        // Room exists; update it
                        delegates.views.updateListItem(item.jid, item.name);
                    }else{
                        // Room is new; create its view and add to `rooms`
                        rooms[item.jid] = item.name;
                        listItem = delegates.views.addListItem(item.jid, item.name);
                    }
                }
            }
            
            (function():void{
                var roomJIDString:String;
                for each(var key:String in HashUtils.keys(rooms)) {
                    // If a room's jid isn't present in the currentItems
                    // collection, that means that it is no longer available.
                    // Therefore, it should be removed from `rooms` collection,
                    // and from the stage.
                    if (currentItems.indexOf(key) == -1) {
                        delete rooms[key];
                        delegates.views.removeListItem(key);
                    }
                }
            })();
            
            return currentItems;
        }
        
        public function createRoom():void{
            // views.createRoomButton.visible = true;
            
            for each(var fieldInput:HemlockTextInput in views.formFields) {
                _configOptions[fieldInput.name] = [fieldInput.value];
            }
            _configOptions['muc#roomconfig_publicroom'] = [1]; // Makes room publicly visible
            // TODO: Randomize room name if blank
            container.configureRoom(_toJID, _configOptions);
            
            // Update UI
            // TODO: Allow button disabling; needs testing
            // views.configFormCompleteButton.disable({ label: 'Creating...' });
            // views.configFormCancelButton.disable();
            hideConfigForm();
        }
        
        public function hideConfigForm():void {
            // FIXME: Move to views.as!
            
            for each(var fieldInput:HemlockTextInput in views.formFields) {
                removeChild(fieldInput);
            }
            views.formFields = [];
            _toJID = null;
            _configOptions = {};
            
            views.header.text = options.strings.allRooms;
            showScreen(SCREEN_LIST);
            views.empty.visible = (views.list.numChildren == 0);
        }
        


        //--------------------------------------
        //  Properties
        //--------------------------------------
        
        public static function get defaultOptions():Object              { return _defaultOptions; }
        public static function set defaultOptions(value:Object):void    { _defaultOptions = value; }
        
        public function get roomType():String {
            return _options.roomType;
        }
 
        public function set toJID(jid:JID):void {
            _toJID = jid;
        }
       
    }
}