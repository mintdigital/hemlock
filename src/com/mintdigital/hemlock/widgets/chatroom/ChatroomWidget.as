package com.mintdigital.hemlock.widgets.chatroom{
    import com.mintdigital.hemlock.HemlockEnvironment;
    import com.mintdigital.hemlock.Logger;
    import com.mintdigital.hemlock.data.Message;
    import com.mintdigital.hemlock.widgets.HemlockWidget;
    import com.mintdigital.hemlock.controls.HemlockButton;
    import com.mintdigital.hemlock.controls.HemlockTextInput;
    import com.mintdigital.hemlock.data.JID;
    import com.mintdigital.hemlock.data.Presence;
    import com.mintdigital.hemlock.display.HemlockSprite;
    import com.mintdigital.hemlock.models.Roster;
    import com.mintdigital.hemlock.models.User;
    import com.mintdigital.hemlock.utils.ArrayUtils;
    import com.mintdigital.hemlock.utils.HashUtils;
    import com.mintdigital.hemlock.utils.StringUtils;

    import flash.events.Event;
    
    /*
    // Imports for testing avatar support:
    import flash.display.BlendMode;
    import flash.display.Loader;
    */
    
    public class ChatroomWidget extends HemlockWidget {
        
        private var eventTypes:Object;
        protected var _room:String = 'chat';
        protected static var _defaultOptions:Object = {
            bg:                     skin.BGBlock,
            paddingN:               skin.CHATROOM_WIDGET_PADDING_N || 10,
            paddingS:               skin.CHATROOM_WIDGET_PADDING_S || 15,
            paddingW:               skin.CHATROOM_WIDGET_PADDING_W || 15,
            paddingE:               skin.CHATROOM_WIDGET_PADDING_E || 15,
            roomStyleSheet:         null, // Override with a StyleSheet object
            messageButtonWidth:     60,
            messageButtonHeight:    null, // Defaults to height of views.messageInput
            messageButtonBG:        HemlockButton.defaultOptions.bg,
            messageButtonBGHover:   HemlockButton.defaultOptions.bgHover,
            messageButtonBGActive:  HemlockButton.defaultOptions.bgActive,
            messageInputFontSize:   HemlockTextInput.defaultOptions.fontSize,
            showRoster:             true,
            showTimestamps:         true,
            strings: {
                messageInput:   'Say something!',
                messageButton:  'Post',
                rosterText:     'Currently in the chatroom: '
            }
        };
        
        public function ChatroomWidget(parentSprite:HemlockSprite, options:Object = null){
            _options = options = HashUtils.merge(_defaultOptions, options);
            
            roster = new Roster();
            
            super(parentSprite, HashUtils.merge({
                delegates: {
                    views:  new ChatroomWidgetViews(this),
                    events: new ChatroomWidgetEvents(this) 
                }
            }, options));
        }
        
        public function updateRosterView(presenceType:String):void {
            if(!this.views.roster){ return; }
            
            var rosterText:String = options.strings.rosterText || 'Currently in the chatroom: ';
            rosterText += ArrayUtils.toSentence(ArrayUtils.map(roster, 'nickname'));
            
            this.views.roster.text = rosterText;
        }
        
        public function displayChatMessage(msg:String, createdAt:Date, cssClass:String = 'presence'):void {
            insertTextIntoRoom(msg, createdAt, {
                cssClass: cssClass
            });
        }
        
        public function getNick(jid:JID) : String {
            return jid.resource;
                // TODO: This is currently the same as the username, because
                // that's what's set as the container's JID when the session
                // is created. This should ideally be the user's nickname,
                // which either the user could supply upon login, or could
                // later be stored in the Jabber database.
        }

        internal function insertTextIntoRoom(text:String, timestamp:Date, options:Object = null) : void {
            if(!options){ options = {}; }
            if(!options.cssClass){ options.cssClass = 'status'; }
            
            // Track whether to scroll; should be false if user manually
            // changed scroll position.
            var scrollToBottom:Boolean = (
                views.room.scrollV == 0
                || views.room.scrollV == views.room.maxScrollV
                );
            
            var newText:String;
            newText = '<p class="' + options.cssClass + '">';
            if(this.options.showTimestamps){
                newText += '<span class="timestamp" style="color:#999">('
                    // + timestamp.toLocaleTimeString()
                    + timestamp.hours + ':' + (timestamp.minutes < 10 ? '0' : '') + timestamp.minutes
                        // TODO: Accept a widget constructor option for switching between 12- and 24-hour clock
                    + ')</span> ';
            }
            newText += text + '</p>';
            views.room.htmlText += newText;
            
            // Notify scrollbar
            views.room.dispatchEvent(new Event(Event.CHANGE));
            
            // Scroll to bottom if appropriate
            if(scrollToBottom){ views.room.scrollV = views.room.maxScrollV; }
        }
        
        internal function sendChatMessage():void{
            var msg:String = StringUtils.trim(views.messageInput.value);
            if(msg.length > 0){ sendMessage(msg); }
            views.messageInput.value = '';
            
            /*
            // FIXME: Testing; disable
            if(msg == '/invisible'){
                // TODO: Figure out why presence doesn't go through with "type" attribute
                sendPresence({ show: Presence.SHOW_AWAY, type: Presence.INVISIBLE_TYPE }); // Allows for updating views
                container.updatePrivacyList(jid, 'presence-out', 'deny');
            }else if(msg == '/visible'){
                sendPresence({ show: Presence.SHOW_CHAT, type: Presence.VISIBLE_TYPE });
                container.updatePrivacyList(jid, 'presence-out', 'allow');
            }else if(msg == '/brb'){
                sendPresence({ show: Presence.SHOW_AWAY });
            }else if(msg == '/bak'){
                sendPresence({ show: Presence.SHOW_CHAT });
            }
            */
        }
        
        override public function get room():String {
            return _room + "@" + domain;
        }
        
        
        
        //--------------------------------------
        //  Properties
        //--------------------------------------
        
        public static function get defaultOptions():Object              { return _defaultOptions; }
        public static function set defaultOptions(value:Object):void    { _defaultOptions = value; }
        
    }
}
