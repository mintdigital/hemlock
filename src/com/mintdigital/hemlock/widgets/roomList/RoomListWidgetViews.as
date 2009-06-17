package com.mintdigital.hemlock.widgets.roomList{
    import com.mintdigital.hemlock.HemlockEnvironment;
    import com.mintdigital.hemlock.Logger;
    import com.mintdigital.hemlock.controls.HemlockButton;
    import com.mintdigital.hemlock.controls.HemlockScrollBar;
    import com.mintdigital.hemlock.display.HemlockLabel;
    import com.mintdigital.hemlock.display.HemlockSprite;
    import com.mintdigital.hemlock.utils.HashUtils;
    import com.mintdigital.hemlock.utils.setAttributes;
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

        internal function addListItem(jidString:String, itemName:String):HemlockSprite{
            Logger.debug('RoomListWidget::addListItem()');

            const HEIGHT:uint = 50;
            var roomTitle:String = itemName.replace(/\s*\((\w+\,\s)?(\d+)\)$/, '');
            var numParticipants:uint = parseInt(itemName.match(/\s*\((\w+\,\s)?(\d+)\)$/)[2]);
                // Assumes itemName is in format "roomTitle (11)" or "roomTitle (private, 11)"

            // views.list.show();
            // views.listScrollBar.show();
            widget.showScreen(RoomListWidget.SCREEN_LIST);
            views.empty.visible = false;
                        
            // Prepare coordinates
            var coords:Object = {};
            coords.listItem = {
                x:      0,
                y:      HEIGHT * (HashUtils.length(widget.rooms) - 1),
                width:  views.list.width,
                height: HEIGHT
            };
            coords.joinButton = {
                x:      0,
                width:  80,
                height: 30
            };
            coords.joinButton.x = (coords.listItem.width - coords.joinButton.width);
            coords.titleText = {
                x:      0,
                y:      0,
                width:  coords.listItem.width - coords.joinButton.width,
                height: HEIGHT * 0.4
            };
            coords.participantsText = {
                x:      0,
                y:      coords.titleText.y + coords.titleText.height,
                width:  coords.titleText.width,
                height: coords.listItem.height - coords.titleText.height
            };
            
            // Create view
            var listItem:HemlockSprite = new HemlockSprite(HashUtils.merge({
                name:   jidString
            }, coords.listItem));

            // Create "join" button
            var joinButton:HemlockButton = new HemlockButton('join', jidString, HashUtils.merge({
                label:  options.strings.joinRoomButton
            }, coords.joinButton));

            // Create room title text
            var titleText:TextField = new TextField();
            setAttributes(titleText, coords.titleText);
            with(titleText){
                name        = 'titleText';
                embedFonts  = true;
                selectable  = false;
                text        = roomTitle;
            }
            var titleFormat:TextFormat = new TextFormat();
            with(titleFormat){
                color   = options.roomTitleColor;
                font    = skin.FONT_PRIMARY;
                size    = 18;
            }
            titleText.setTextFormat(titleText.defaultTextFormat = titleFormat);

            // Create "# people" text
            var participantsText:TextField = new TextField();
            setAttributes(participantsText, coords.participantsText);
            with(participantsText){
                name        = 'participantsText';
                embedFonts  = true;
                selectable  = false;
                text        = numParticipants + ' '
                                + options.strings[numParticipants == 1 ? 'participant' : 'participants'];
            }
            var participantsFormat:TextFormat = new TextFormat();
            with(participantsFormat){
                color   = options.roomMetaColor;
                font    = skin.FONT_PRIMARY;
                size    = 14;
            }
            participantsText.setTextFormat(participantsText.defaultTextFormat = participantsFormat);

            listItem.addChildren(
                titleText,
                participantsText,
                joinButton
            );

            views.list.addChild(listItem);
            // listItem.setSize(sizes.listItem.width, sizes.listItem.height);

            views.list.dispatchEvent(new Event(Event.CHANGE)); // Notify scrollbar
            return listItem;
        }
        
        internal function removeListItem(jidString:String):void{
            Logger.debug('RoomListWidgetViews::removeListItem() : jidString = ' + jidString);
            
            var listItem:HemlockSprite = views.list.getChildByName(jidString) as HemlockSprite;
            if(!listItem){ return; }
            
            // Remove item
            views.list.removeChild(listItem);
            
            // Update positions of other items
            var numItems:uint = views.list.numChildren;
            if(numItems > 0){
                const HEIGHT:Number = views.list.getChildAt(0).height;
                for(var i:uint = 0; i < numItems; i++){
                    listItem = views.list.getChildAt(i) as HemlockSprite;
                    /*
                    listItem.move({
                        yFrom:      listItem.y,
                        yTo:        HEIGHT * i,
                        duration:   0.25
                    });
                    */
                    listItem.y = HEIGHT * i;
                }
            }else{
                views.empty.visible = true;
            }
        }
        
        internal function updateListItem(jidString:String, itemName:String):void{
            Logger.debug('RoomListWidgetViews::updateListItem() : jidString = ' + jidString);
            
            var listItem:HemlockSprite = views.list.getChildByName(jidString) as HemlockSprite;
            if(!listItem){ return; }

            var roomTitle:String = itemName.replace(/\s*\((\w+\,\s)?(\d+)\)$/, ''),
                numParticipants:uint = parseInt(itemName.match(/\s*\((\w+\,\s)?(\d+)\)$/)[2]);
                // Assumes itemName is in format "roomTitle (11)" or "roomTitle (private, 11)"
            
            // Update room title
            var titleText:TextField = listItem.getChildByName('titleText') as TextField;
            if(titleText){ titleText.text = roomTitle; }
            
            // Update # room participants
            var participantsText:TextField = listItem.getChildByName('participantsText') as TextField;
            if(participantsText){
                participantsText.text = numParticipants + ' '
                    + options.strings[numParticipants == 1 ? 'participant' : 'participants'];
            }

            // Disable/enable "join" button
            if(widget.options.maxParticipants > 0){
                var joinButton:HemlockButton = listItem.getChildByName('join') as HemlockButton;
                if(numParticipants < widget.options.maxParticipants){
                    joinButton.enable();
                }else{
                    joinButton.disable({ label: 'Full' });
                        // TODO: Update button handler to also check # participants
                        // - Backup against race condition where "Join" is clicked
                        //   before button is disabled.
                        // - Widget needs its own model storing room JIDs, titles,
                        //   and number of participants.
                        // TODO: Disable buttons by default, until they're
                        //       specifically enabled in this function?
                }
            }
        }
        
    }
}
