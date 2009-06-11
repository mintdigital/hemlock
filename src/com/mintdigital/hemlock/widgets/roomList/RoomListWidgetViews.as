package com.mintdigital.hemlock.widgets.roomList{
    import com.mintdigital.hemlock.HemlockEnvironment;
    import com.mintdigital.hemlock.Logger;
    import com.mintdigital.hemlock.controls.HemlockButton;
    import com.mintdigital.hemlock.controls.HemlockScrollBar;
    import com.mintdigital.hemlock.display.HemlockLabel;
    import com.mintdigital.hemlock.display.HemlockSprite;
    import com.mintdigital.hemlock.widgets.HemlockWidget;
    import com.mintdigital.hemlock.widgets.HemlockWidgetDelegate;
    import com.mintdigital.hemlock.widgets.IDelegateViews;

    import flash.events.Event;
    import flash.display.BlendMode;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;
    import flash.text.TextField;
    import flash.text.TextFieldType;

    import org.jivesoftware.xiff.data.forms.FormField;
    
    public class RoomListWidgetViews extends HemlockWidgetDelegate implements IDelegateViews{

        public function RoomListWidgetViews(widget:HemlockWidget){
            super(widget);
        }

        public function createViews():void{
            Logger.debug('RoomListWidget::createViews()');

            // Prepare screens
            widget.createScreens(
                RoomListWidget.SCREEN_LIST,
                RoomListWidget.SCREEN_FORM
            );

            // Prepare positions and sizes
            var positions:Object = {}, sizes:Object = {};
            positions.header = { x: 10, y: 10 };
            sizes.header = {
                width:  options.width - (positions.header.x * 2),
                height: 30
            };
            sizes.createRoomButton = {
                width:  Math.max(200, options.width - 20),
                height: 40
            };
            positions.createRoomButton = {
                x:  (options.width - sizes.createRoomButton.width) * 0.5,
                y:  options.height - sizes.createRoomButton.height - 10
            };
            sizes.listScrollBar = { thickness: 20 };
            positions.list = {
                x:  10,
                y:  positions.header.y + sizes.header.height + 10
            };
            sizes.list = {
                width:  options.width - (positions.list.x * 2)
                        - sizes.listScrollBar.thickness - 5,
                height: positions.createRoomButton.y - 10 - positions.list.y
            }
            sizes.empty = { width: sizes.list.width, height: 50 };
            positions.empty = {
                x:  (options.width  - sizes.empty.width)  * 0.5,
                y:  (options.height - sizes.empty.height) * 0.5
            }
            positions.listScrollBar = {
                x:  positions.list.x + sizes.list.width + 5,
                y:  positions.list.y
            };

            // Create background
            views.background = new skin.BGBlock();
            views.background.width = options.width;
            views.background.height = options.height;

            // Create header
            views.header = new TextField();
            with(views.header){
                x           = positions.header.x;
                y           = positions.header.y;
                width       = sizes.header.width;
                height      = sizes.header.height;
                embedFonts  = true;
                selectable  = false;
                text        = options.strings.allRooms;
            }
            var headerFormat:TextFormat = new TextFormat();
            with(headerFormat){
                color   = options.headerColor;
                font    = skin.FONT_PRIMARY_BOLD;
                size    = 20;
            }
            views.header.setTextFormat(views.header.defaultTextFormat = headerFormat);

            // Create room creation button
            views.createRoomButton = new HemlockButton('createRoomButton', 'new', {
                x:          positions.createRoomButton.x,
                y:          positions.createRoomButton.y,
                width:      sizes.createRoomButton.width,
                height:     sizes.createRoomButton.height,
                fontSize:   18,
                label:      options.strings.newRoomButton
            });

            // Create empty text (no rooms yet)
            views.empty = new TextField();
            with(views.empty){
                x           = positions.empty.x;
                y           = positions.empty.y;
                width       = sizes.empty.width;
                height      = sizes.empty.height;
                alpha       = 0.25;
                blendMode   = BlendMode.LAYER;
                embedFonts  = true;
                selectable  = false;
                text        = options.strings.noRooms;
            }
            var emptyFormat:TextFormat = new TextFormat();
            with(emptyFormat){
                align   = TextFormatAlign.CENTER;
                color   = 0x000000;
                font    = skin.FONT_PRIMARY;
                size    = 24;
            }
            views.empty.setTextFormat(views.empty.defaultTextFormat = emptyFormat);

            // Create list
            views.list = new HemlockSprite({
                x:      positions.list.x,
                y:      positions.list.y
            });
            with(views.list.graphics){
                beginFill(0xFFFFFF, 0); // Prop open
                drawRect(0, 0, sizes.list.width, sizes.list.height);
                endFill();
            }
            views.list.setSize(sizes.list.width, sizes.list.height);
            views.listScrollBar = new HemlockScrollBar(views.list, {
                x:          positions.listScrollBar.x,
                y:          positions.listScrollBar.y,
                thickness:  sizes.listScrollBar.thickness
            });

            views.configFormCompleteButton = new HemlockButton('configFormCompleteButton', 'create', {
                x:      20,
                width:  175,
                label:  options.strings.createRoomButton
            });

            views.configFormCancelButton = new HemlockButton('configFormCancelButton', 'cancel', {
                x:      views.configFormCompleteButton.x + views.configFormCompleteButton.width + 10,
                width:  75,
                label:  'Cancel'
            });

            views.configFormLabel = new HemlockLabel(options.strings.newRoomLabel, views.configFormCompleteButton, {
                width: 260,
                height: 30,
                x: 20,
                y: 100
            });

            // Add views to widget
            var listScreen:HemlockSprite = widget.getScreen(RoomListWidget.SCREEN_LIST),
                formScreen:HemlockSprite = widget.getScreen(RoomListWidget.SCREEN_FORM);
            widget.addChild(views.background);
            widget.addChild(views.header);
            listScreen.addChild(views.empty);
            listScreen.addChild(views.listScrollBar);
            listScreen.addChild(views.list);
            listScreen.addChild(views.createRoomButton);
            formScreen.addChild(views.configFormLabel);
            formScreen.addChild(views.configFormCompleteButton);
            formScreen.addChild(views.configFormCancelButton);
            widget.showScreen(RoomListWidget.SCREEN_LIST);

            widget.updateSize();

            views.formFields = [];
        }

        internal function addListItem(itemName:String, jidString:String):HemlockSprite{
            Logger.debug('RoomListWidget::addListItem()');

            const HEIGHT:uint = 50;
            var roomName:String = itemName.replace(/\s*\((\w+\,\s)?(\d+)\)$/, '');
            var numPlayers:uint = parseInt(itemName.match(/\s*\((\w+\,\s)?(\d+)\)$/)[2]);
            // Assumes itemName is in format "roomName (11)" or "roomName (private, 11)"

            // views.list.show();
            // views.listScrollBar.show();
            widget.showScreen(RoomListWidget.SCREEN_LIST);
            views.empty.visible = false;

            // Prepare positions and sizes
            var positions:Object = {}, sizes:Object = {};
            positions.listItem  = { x: 0, y: views.list.numChildren * HEIGHT };
            sizes.listItem      = { width: views.list.width, height: HEIGHT };
            sizes.joinButton    = { width: 80, height: 30 };
            positions.joinButton = {
                x:  (sizes.listItem.width  - sizes.joinButton.width),
                y:  0
            }
            positions.titleText = { x: 0, y: 0 };
            sizes.titleText     = {
                width:  sizes.listItem.width - sizes.joinButton.width,
                height: HEIGHT * 0.4
            };
            positions.playersText = {
                x:  0,
                y:  positions.titleText.y + sizes.titleText.height
            };
            sizes.playersText = {
                width:  sizes.titleText.width,
                height: sizes.listItem.height - sizes.titleText.height
            };

            var listItem:HemlockSprite = new HemlockSprite({
                x:  positions.listItem.x,
                y:  positions.listItem.y
            });

            // Create "join game" button
            var joinButton:HemlockButton = new HemlockButton('joinGame', jidString, {
                x:      positions.joinButton.x,
                y:      positions.joinButton.y,
                width:  sizes.joinButton.width,
                height: sizes.joinButton.height,
                label:  options.strings.joinRoomButton
            });

            // Create room title text
            var titleText:TextField = new TextField();
            titleText.width = views.list.width - joinButton.width;
            with(titleText){
                x           = positions.titleText.x;
                y           = positions.titleText.y;
                width       = sizes.titleText.width;
                height      = sizes.titleText.height;
                embedFonts  = true;
                selectable  = false;
                // text        = roomName + '\u2019s game';
                text        = roomName;
            }
            var titleFormat:TextFormat = new TextFormat();
            with(titleFormat){
                color   = options.roomTitleColor;
                font    = skin.FONT_PRIMARY;
                size    = 18;
            }
            titleText.setTextFormat(titleText.defaultTextFormat = titleFormat);

            // Create "# players" text
            var playersText:TextField = new TextField();
            playersText.width = views.list.width - joinButton.width;
            with(playersText){
                x           = positions.playersText.x;
                y           = positions.playersText.y;
                width       = sizes.playersText.width;
                height      = sizes.playersText.height;
                embedFonts  = true;
                selectable  = false;
                text        = numPlayers + ' '
                                + (numPlayers == 1 ? options.strings.participant : options.strings.participants);
            }
            var playersFormat:TextFormat = new TextFormat();
            with(playersFormat){
                color   = options.roomMetaColor;
                font    = skin.FONT_PRIMARY;
                size    = 14;
            }
            playersText.setTextFormat(playersText.defaultTextFormat = playersFormat);

            listItem.addChild(titleText);
            listItem.addChild(playersText);
            listItem.addChild(joinButton);

            views.list.addChild(listItem);
            listItem.setSize(sizes.listItem.width, sizes.listItem.height);

            views.list.dispatchEvent(new Event(Event.CHANGE)); // Notify scrollbar
            return listItem;
        }
    }
}
