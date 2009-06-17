package com.mintdigital.hemlock.widgets.roomList {
    import com.mintdigital.hemlock.Logger;
    import com.mintdigital.hemlock.controls.HemlockButton;
    import com.mintdigital.hemlock.controls.HemlockTextInput;
    import com.mintdigital.hemlock.data.JID;
    import com.mintdigital.hemlock.events.AppEvent;
    import com.mintdigital.hemlock.widgets.HemlockWidget;
    import com.mintdigital.hemlock.widgets.HemlockWidgetDelegate;
    import com.mintdigital.hemlock.widgets.IDelegateEvents;

    import org.jivesoftware.xiff.data.forms.FormField;
    import org.jivesoftware.xiff.data.forms.FormExtension;

    import flash.events.Event;    
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.ui.Keyboard;

    public class RoomListWidgetEvents extends HemlockWidgetDelegate implements IDelegateEvents {
    
        public function RoomListWidgetEvents(widget:HemlockWidget){
            super(widget);
        }

        public function registerListeners():void{
            // Register view listeners
            widget.registerListener(views.createRoomButton,            MouseEvent.CLICK, onNewRoomEvent);
            widget.registerListener(views.configFormCompleteButton,    MouseEvent.CLICK, onCreateRoomEvent);
            widget.registerListener(views.configFormCancelButton,      MouseEvent.CLICK, onCancellationEvent);
            
            // Register container/dispatcher listeners
            widget.registerListener(widget.dispatcher,  AppEvent.ROOM_CONFIGURED,           onRoomChange);
            widget.registerListener(widget.dispatcher,  AppEvent.ROOM_JOINED,               onRoomChange);
            widget.registerListener(widget.dispatcher,  AppEvent.ROOM_USER_LEAVE,           onRoomChange);
            widget.registerListener(widget.dispatcher,  AppEvent.CONFIGURATION_START,       onConfigurationStart);
            widget.registerListener(widget.dispatcher,  AppEvent.CONFIGURATION_COMPLETE,    onConfigurationComplete);
            widget.registerListener(widget.dispatcher,  AppEvent.DISCOVERY_ITEMS_FOUND,     onDiscoveryItemsFound);
        }
        


        //--------------------------------------
        //  Handlers > Views
        //--------------------------------------

        private function onJoinRoomButtonClick(event:MouseEvent):void{
            Logger.debug('RoomListWidget::onJoinRoomButtonClick()');
        
            var button:HemlockButton = event.target.parent as HemlockButton;
            container.joinChatRoom(new JID(button.value as String));
        }

        private function onNewRoomEvent(event:MouseEvent):void {
            container.createChatRoom(widget.roomType);
        }
        
        private function onCreateRoomEvent(event:MouseEvent):void {
            widget.createRoom();
        }
        
        private function onCancellationEvent(event:MouseEvent):void {
            widget.hideConfigForm();
        }
        
        private function onFormFieldKeyDown(event:KeyboardEvent):void{
            if(event.keyCode == Keyboard.ENTER){ widget.createRoom(); }
        }
        
        
        
        //--------------------------------------
        //  Handlers > App
        //--------------------------------------
        
        private function onRoomChange(event:AppEvent):void{
            Logger.debug('RoomListWidgetEvents::onRoomChange() : type = ' + event.type);
            
            container.discoChatRooms();
            widget.hideConfigForm();
        }
        
        private function onConfigurationStart(event:AppEvent):void {
            if (event.from.type == JID.TYPE_SESSION) { return; }
            
            widget.toJID = event.from;
            widget.showScreen(RoomListWidget.SCREEN_FORM);

            // FIXME: Move to views delegate!
            for each(var field:FormField in event.options.fields) {
                if (field.type == FormExtension.FIELD_TYPE_TEXT_SINGLE) {
                    var textInput:HemlockTextInput = configField(field);
                    widget.addChild(textInput);
                    widget.registerListener(textInput, KeyboardEvent.KEY_DOWN, onFormFieldKeyDown);
                }
            }
            widget.startListeners();

            views.header.text = views.createRoomButton.label;
            views.configFormCompleteButton.y = configFormInputY;
            views.configFormCancelButton.y = configFormInputY;
            widget.updateSize();
        }
        
        private function onConfigurationComplete(event:AppEvent):void {
            container.discoChatRooms();
        }
        
        private function onDiscoveryItemsFound(event:AppEvent):void {
            Logger.debug('RoomListWidgetEvents::onDiscoveryItemsFound()');
            
            var items:Array /* of * */ = widget.updateRoomList(event.options.items);

            // Listen to new "join" buttons in list
            var numRooms:uint = views.list.numChildren;
            for(var i:uint = numRooms - items.length; i < numRooms; i++){
                var button:HemlockButton = views.list.getChildAt(i).getChildByName('join') as HemlockButton;
                widget.registerListener(button, MouseEvent.CLICK, onJoinRoomButtonClick);
            }
            widget.startListeners();
        }
        
        private function get configFormInputY():int {
            // FIXME: Move to views delegate!
            return ((views.formFields.length * 40)      // Approx control height
                    + (views.formFields.length * 5))    // Margin
                    + (views.configFormLabel.y + views.configFormLabel.height);
        }

        public function configField(formField:FormField):HemlockTextInput {
            // FIXME: Move to views delegate!
            var newConfigField:HemlockTextInput = new HemlockTextInput(formField.name, '', {
                x:              20,
                y:              configFormInputY,
                width:          260,
                defaultText:    formField.label,
                maxChars:       100
            });
            views.formFields.push(newConfigField);
        
            return newConfigField;
        }

    }
}
