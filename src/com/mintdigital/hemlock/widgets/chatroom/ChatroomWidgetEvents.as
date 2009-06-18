package com.mintdigital.hemlock.widgets.chatroom{
    import com.mintdigital.hemlock.HemlockEnvironment;
    import com.mintdigital.hemlock.Logger;
    import com.mintdigital.hemlock.data.JID;
    import com.mintdigital.hemlock.data.Message;
    import com.mintdigital.hemlock.data.Presence;
    import com.mintdigital.hemlock.display.HemlockSprite;
    import com.mintdigital.hemlock.events.AppEvent;
    import com.mintdigital.hemlock.events.PresenceEvent;
    import com.mintdigital.hemlock.models.Roster;
    import com.mintdigital.hemlock.models.User;
    import com.mintdigital.hemlock.utils.StringUtils;
    import com.mintdigital.hemlock.widgets.HemlockWidget;
    import com.mintdigital.hemlock.widgets.HemlockWidgetDelegate;
    import com.mintdigital.hemlock.widgets.IDelegateEvents;
    
    import flash.events.TextEvent;
    import flash.events.MouseEvent;
    import flash.events.KeyboardEvent;
    import flash.ui.Keyboard;
    
    public class ChatroomWidgetEvents extends HemlockWidgetDelegate implements IDelegateEvents{
        
        public function ChatroomWidgetEvents(widget:HemlockWidget){
            super(widget);
        }
        
        
        
        //--------------------------------------
        //  Initializers
        //--------------------------------------
        
        public function registerListeners():void{
            widget.registerListener(views.messageInput, KeyboardEvent.KEY_DOWN, onMessageInput);
            widget.registerListener(views.messageButton,MouseEvent.CLICK,       onMessageButton);
            widget.registerListener(views.room,         TextEvent.LINK,         onLinkEvent);
            
            widget.registerListener(widget.dispatcher,  AppEvent.CHAT_MESSAGE,      onChatMessage);            
            widget.registerListener(widget.dispatcher,  AppEvent.ROOM_USER_JOIN,    onRoomUserJoined);            
            widget.registerListener(widget.dispatcher,  AppEvent.CHATROOM_STATUS,   onChatroomStatus);            
            widget.registerListener(widget.dispatcher,  AppEvent.ROOM_USER_LEAVE,   onRoomUserLeave);
            widget.registerListener(widget.dispatcher,  AppEvent.PRESENCE_CREATE,   onPresence);
            widget.registerListener(widget.dispatcher,  AppEvent.PRESENCE_UPDATE,   onPresence);
        }
        
        
        
        //--------------------------------------
        //  Handlers > UI
        //--------------------------------------
    
        private function onMessageInput(event:KeyboardEvent):void{
            if(event.keyCode == Keyboard.ENTER){ widget.sendChatMessage(); }
        }

        private function onMessageButton(event:MouseEvent):void{
            widget.sendChatMessage();
        }

        private function onLinkEvent(e:TextEvent):void {
            container.leaveRoom(new JID(e.text));
        }
        
        
        
        //--------------------------------------
        //  Handlers > App
        //--------------------------------------
        
        private function onChatMessage(event:AppEvent) : void {
            var msg:String;

            var message:Message = event.options.xmppMessage;
            if(event.from.toBareJID().toString() != widget.bareJID.toString()){ return; }

            if (message.body != null){
                msg = '<span class="nickname">' + widget.getNick(event.options.from) + ':</span> '
                    + StringUtils.escapeHTML(message.body);
                widget.displayChatMessage(msg, event.createdAt, event.type)

                skin.playSound('chatMessage');

                /*
                // Testing: Display avatar of last messager in chat log
                if(views.lastAvatar){
                    removeChild(views.lastAvatar);
                }
                if(container.client.avatar){
                    views.lastAvatar = new Loader();
                    views.lastAvatar.loadBytes(container.client.avatar);
                    views.lastAvatar.alpha = 0.25;
                    views.lastAvatar.blendMode = BlendMode.LAYER;
                    views.lastAvatar.x = views.room.x + 10;
                    views.lastAvatar.y = views.room.y + 10;
                    addChild(views.lastAvatar);
                }
                */
            }
        }
        
        private function onRoomUserJoined(event:AppEvent):void{
            if(event.from.toBareJID().toString() != widget.bareJID.toString()){ return; }
            var msg:String = event.from.resource + ' has entered the room';
            widget.displayChatMessage(msg, event.createdAt)        
        }
        
        private function onChatroomStatus(event:AppEvent):void{
            widget.displayChatMessage(event.message, event.createdAt, event.type)
        }

        private function onRoomUserLeave(event:AppEvent):void{
            var msg:String = event.from + ' has left the room';
            widget.displayChatMessage(msg, event.createdAt)
        }

        private function onPresence(event:AppEvent):void{
            var presenceFrom:JID = event.options.presenceFrom,
                presenceType:String = event.options.presenceType;
            
            if (presenceFrom.toBareJID().toString() != widget.bareJID) { return; }
            
            var user:User = new User(presenceFrom, presenceFrom.resource, event.options.status);
            if(!user.nickname || user.nickname == ''){ return; }
            
            // Announce new presence
            var msg:String = user.nickname + ' is now ' + (presenceType || 'available');
            widget.displayChatMessage(msg, event.createdAt);
            
            // Update roster
            // if (presenceType != PresenceEvent.STATUS_OFFLINE) {
            if(presenceType != Presence.UNAVAILABLE_TYPE){
                widget.roster.push(user);
            } else {
                widget.roster.remove(user);
            }

            // Update roster view
            widget.updateRosterView(presenceType);
        }
        
    }
}