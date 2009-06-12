package com.mintdigital.drawingDemo.containers{
    import com.mintdigital.hemlock.HemlockEnvironment;
    import com.mintdigital.hemlock.Logger;
    import com.mintdigital.hemlock.containers.HemlockContainer;
    import com.mintdigital.hemlock.data.JID;
    import com.mintdigital.hemlock.events.AppEvent;
    import com.mintdigital.hemlock.skins.hemlockSoft.HemlockSoftSkin;
    import com.mintdigital.hemlock.strategies.DrawEventStrategy;
    import com.mintdigital.hemlock.strategies.RoomEventStrategy;
    import com.mintdigital.hemlock.utils.GraphicsUtils;
    import com.mintdigital.hemlock.utils.HashUtils;
    import com.mintdigital.hemlock.widgets.chatroom.ChatroomWidget;
    import com.mintdigital.hemlock.widgets.debug.DebugWidget;
    import com.mintdigital.hemlock.widgets.drawing.DrawingWidget;
    import com.mintdigital.hemlock.widgets.roomList.RoomListWidget;
    import com.mintdigital.hemlock.widgets.signin.SigninWidget;

    [SWF(width="1000", height="665", backgroundColor="#CCCCCC")]
    public class DrawingDemoContainer extends HemlockContainer{

        private var _userJID:JID;



        //--------------------------------------
        //  Initializers
        //--------------------------------------

        public function DrawingDemoContainer(){
            initialize();
            client.addEventStrategies([
                new RoomEventStrategy(),
                new DrawEventStrategy()
            ]);

            // Add background to prop open
            GraphicsUtils.fill(graphics, { width: width, height: height }, 0xCCCCCC, 1);

            // Set up widgets
            addDebugWidget();
            addInitialWidgets();

            // Wrap up
            if(widgets.debug){ moveChildToFront(widgets.debug); }
            setSize(width, height);
        }

        override protected function initialize():void{
            include '../../../../config/environment.as';
            HemlockEnvironment.SKIN = HemlockSoftSkin;
        }



        //--------------------------------------
        //  Events > Initializers
        //--------------------------------------

        override public function registerListeners():void{
            Logger.debug('DrawingDemoContainer::registerListeners()');
            super.registerListeners();

            registerListener(dispatcher,    AppEvent.ROOM_JOINED,               onRoomJoined);
            registerListener(dispatcher,    AppEvent.CONFIGURATION_START,       onConfigurationStart);
            registerListener(dispatcher,    AppEvent.CONFIGURATION_COMPLETE,    onConfigurationComplete);
        }



        //--------------------------------------
        //  Events > Handlers
        //--------------------------------------

        private function onRoomJoined(event:AppEvent):void{
            var data:Object = event.options;
            if(data.jid.node != JID.TYPE_SESSION && widgets[data.jid.node] == null){
                _userJID = data.jid;
                switch(data.jid.type){
                    case JID.TYPE_CHAT:
                        addChatroomWidget();
                        removeRoomListWidget();
                        break;
                    case JID.TYPE_APP:
                        addDrawingWidget();
                        break;
                }
                setSize(width, height);
                if(widgets.debug){ moveChildToFront(widgets.debug); }
            }
        }

        private function onConfigurationStart(event:AppEvent):void{
            var jid:JID = event.from;
            if(jid.type == JID.TYPE_APP){
                // Mark the app room private so that it doesn't appear in RoomListWidget
                configureChatRoom(jid, { 'muc#roomconfig_publicroom' : [0] });
            }
        }

        private function onConfigurationComplete(event:AppEvent):void{
            var jid:JID = event.from;
            if(jid.type == JID.TYPE_CHAT){
                client.createChatRoom(JID.TYPE_APP, domain, jid.key);
            }
        }

        override protected function onSessionCreateSuccess(event:AppEvent):void{
            super.onSessionCreateSuccess(event);

            removeInitialWidgets();

            // addMenuWidget();
            addRoomListWidget();

            // Give feedback
            skin.playSound('signIn');

            // Update widget positions and sizes
            setSize(width, height);
        }



        //--------------------------------------
        //  View helpers
        //--------------------------------------

        private function addInitialWidgets():void{
            var newWidgets:Array /* of HemlockWidgets */ = [];
            
            // Prepare coordinates
            var coords:Object = {};
            coords.signin = {
                width:  300,
                height: 220
            };
            coords.signin.x = (width  - coords.signin.width)  * 0.5;
            coords.signin.y = (height - coords.signin.height) * 0.5;
            
            // Show widget
            if(widgets.signin){
                widgets.signin.show();
            }else{
                widgets.signin = new SigninWidget(this, coords.signin);
                newWidgets.push(widgets.signin);
            }

            addWidgets(newWidgets);
            if(widgets.debug){ moveChildToFront(widgets.debug); }
        }

        private function removeInitialWidgets():void{
            if(widgets.signin){ widgets.signin.hide(); }
        }

        private function addRoomListWidget():void{
            // Prepare coordinates
            var coords:Object = {};
            coords.roomList = {
                width:  300,
                height: 450
            };
            coords.roomList.x = (width  - coords.roomList.width)  * 0.5;
            coords.roomList.y = (height - coords.roomList.height) * 0.5;
            
            // Show widget
            if(widgets.roomList){
                widgets.roomList.show();
            }else{
                widgets.roomList = new RoomListWidget(this, HashUtils.merge({
                    roomType:   JID.TYPE_APP,
                    strings:    HashUtils.merge(RoomListWidget.defaultOptions.strings, {
                        allRooms:           'Current drawings',
                        newRoomButton:      'Start a new drawing',
                        noRooms:            'No drawings yet',
                        newRoomLabel:       'Drawing details:',
                        createRoomButton:   'Let me draw stuff!',
                        joinRoomButton:     'Join',
                        participant:        'person',
                        participants:       'people'
                    })
                }, coords.roomList));

                addWidgets([ widgets.roomList ]);
                if(widgets.debug){ moveChildToFront(widgets.debug); }
            }
        }

        private function removeRoomListWidget():void{
            if(widgets.roomList){ widgets.roomList.hide(); }
        }

        private function addDebugWidget():void{
            if(!HemlockEnvironment.debug){ return; }
            
            // TODO: Move to HemlockContainer
            // - HemlockContainer should automatically keep DebugWidget in
            //   front whenever another child is added
            
            // Prepare coordinates
            var coords:Object = {};
            coords.debug = {
                width:  310,
                height: height
            };
            coords.debug.x = (width - coords.debug.width);
            coords.debug.y = 0;
            
            // Show widget
            widgets.debug = new DebugWidget(this, coords.debug);
            addWidgets([ widgets.debug ]);
        }

        private function addChatroomWidget():void{
            var coords:Object = prepareCoordinates();

            widgets.chatroom = new ChatroomWidget(this, HashUtils.merge({
                jid: _userJID
            }, coords.chatroom));
            addWidgets([ widgets.chatroom ]);
        }

        private function addDrawingWidget():void{
            var coords:Object = prepareCoordinates();

            widgets.drawing = new DrawingWidget(this, HashUtils.merge({
                jid: _userJID
            }, coords.drawing));
            addWidgets([ widgets.drawing ]);
        }

        private function prepareCoordinates():Object{
            // var maxWidth:Number = width, maxHeight:Number = height;
            var maxWidth:Number = 1000, maxHeight:Number = 650;
                // DrawingWidget assumes that every user's instance has the
                // same dimensions.
            
            // Prepare coordinates
            var coords:Object = {};
            coords.chatroom = {
                y:      10,
                width:  300,
                height: maxHeight - 20
            };
            coords.chatroom.x = maxWidth - coords.chatroom.width - 10;
            coords.drawing = {
                x:      10,
                y:      coords.chatroom.y,
                width:  maxWidth - coords.chatroom.width - 30,
                height: coords.chatroom.height
            };
            
            // TODO: Memoize in a private var
            
            return coords;
        }



        //--------------------------------------
        //  Misc helpers
        //--------------------------------------

        // Override to specify type JID.TYPE_CHAT
        override public function createChatRoom(roomType:String):void {
            Logger.debug("TopTrumps::createChatRoom()");
            client.createChatRoom(JID.TYPE_CHAT, domain);
        }

        // Override to join the game at the same time.
        override public function joinChatRoom(toJID:JID):void {
            super.joinChatRoom(toJID);
            client.joinChatRoom(new JID(
                toJID.toString().replace(JID.TYPE_CHAT + '_', JID.TYPE_APP + '_') + '/' + client.username
            ));
        }



        //--------------------------------------
        //  Properties
        //--------------------------------------

        override public function get width():Number     { return stage.stageWidth; }
        override public function get height():Number    { return stage.stageHeight; }

    }
}
