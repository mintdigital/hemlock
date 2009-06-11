package com.mintdigital.hemlock.widgets.chatroom{
    import com.mintdigital.hemlock.HemlockEnvironment;
    import com.mintdigital.hemlock.Logger;
    import com.mintdigital.hemlock.widgets.IDelegateViews;
    import com.mintdigital.hemlock.widgets.HemlockWidget;
    import com.mintdigital.hemlock.widgets.HemlockWidgetDelegate;
    import com.mintdigital.hemlock.controls.HemlockButton;
    import com.mintdigital.hemlock.controls.HemlockScrollBar;
    import com.mintdigital.hemlock.controls.HemlockTextInput;
    
    import flash.text.StyleSheet;
    import flash.text.TextField;
    import flash.text.AntiAliasType;
    import flash.text.TextFieldType;  // For making editable TextFields
    import flash.text.TextFormat;
    
    public class ChatroomWidgetViews extends HemlockWidgetDelegate implements IDelegateViews{
        
        public function ChatroomWidgetViews(widget:HemlockWidget){
            super(widget);
        }
        
        public function createViews():void{
            Logger.debug('ChatroomWidget::createViews()');

            // Prepare dimensions and positions for all views
            var dimensions:Object   = getAllDimensions(options.width, options.height);
            var positions:Object    = getAllPositions(dimensions);
            
            // Create main background
            views.bg = new options.bg();
            
            // Create room (contains all chat messages)
            views.room = new TextField();
            views.room.antiAliasType    = AntiAliasType.ADVANCED;
            views.room.embedFonts       = true;
            views.room.multiline        = true;
            views.room.wordWrap         = true;

            // Create room styles
            var roomStyle:StyleSheet;
            if(options.roomStyleSheet){
                roomStyle = options.roomStyleSheet;
            }else{
                roomStyle = new StyleSheet();
                roomStyle.setStyle('p', {
                    fontFamily: skin.FONT_PRIMARY,
                    fontSize:   14
                });
                roomStyle.setStyle('.timestamp', {
                    color:      '#999999',
                    fontSize:   10
                });
                roomStyle.setStyle('.presence', {
                    color:      '#999999',
                    fontSize:   14,
                    fontStyle:  'italic'
                });
                roomStyle.setStyle('.status', { // generic
                    color:      '#999999',
                    fontSize:   14,
                    fontStyle:  'italic'
                });
            }
            views.room.styleSheet = roomStyle;

            // Initialize room content
            views.room.htmlText = '';

            // for(var i:uint = 0; i < 100; i++){
            //     widget.insertTextIntoRoom('This is some test content. (' + i + ')', new Date());
            // }

            // Create room scrollbar
            views.roomScrollBar = new HemlockScrollBar(views.room);

            if(options.showRoster){
                // Create roster background
                views.bgRoster = new skin.BGChatroomRoster();

                // Create roster
                // TODO: Make roster taller/shorter according to content
                views.roster = new TextField();
                views.roster.antiAliasType = AntiAliasType.ADVANCED;
                views.roster.embedFonts = true;
                views.roster.wordWrap   = true;

                // Create roster styles
                var rosterFormat:TextFormat = new TextFormat();
                rosterFormat.font = skin.FONT_PRIMARY;
                rosterFormat.size = 11;
                views.roster.defaultTextFormat = rosterFormat;
            }

            // Create message input
            views.messageInput = new HemlockTextInput('messageInput', '', {
                x:              positions.messageInput.x,
                y:              positions.messageInput.y,
                width:          dimensions.messageInput.width,
                height:         dimensions.messageInput.height,
                defaultText:    options.strings.messageInput,
                fontSize:       options.messageInputFontSize,
                maxChars:       200
            });

            views.messageButton = new HemlockButton('messageButton', '', {
                x:          positions.messageButton.x,
                y:          positions.messageButton.y,
                width:      dimensions.messageButton.width,
                height:     dimensions.messageButton.height,
                bg:         options.messageButtonBG,
                bgHover:    options.messageButtonBGHover,
                bgActive:   options.messageButtonBGActive,
                label:      options.strings.messageButton
            });

            // Set all view dimensions and positions
            setSize(options.width, options.height);
            
            // Initialize views
            widget.addChildren(
                views.bg,
                views.room,
                views.roomScrollBar
            );
            if(views.bgRoster)  { widget.addChild(views.bgRoster); }
            if(views.roster)    { widget.addChild(views.roster); }
            widget.addChildren(
                views.messageInput,
                views.messageButton
            );
        }

        private function getAllDimensions(newWidth:uint, newHeight:uint):Object{
            // Returns an object hash that stores dimensions for all views.

            var dimensions:Object = {};
            var contentWidth:Number = newWidth - options.paddingW - options.paddingE;

            dimensions.room = {
                width:  contentWidth - HemlockScrollBar.defaultOptions.thickness
            };
            dimensions.roster = {
                // width:  dimensions.room.width + options.paddingW + 5,
                width:  contentWidth + options.paddingW + 5,
                height: 33
            };
            if(!options.showRoster){ dimensions.roster.height = 0; }

            dimensions.messageButton = {
                width:  options.messageButtonWidth
            };
            dimensions.messageInput = {
                // width:  dimensions.room.width - dimensions.messageButton.width - 10,
                width:  contentWidth - dimensions.messageButton.width - 10,
                height: HemlockTextInput.defaultOptions.height
            };
            dimensions.messageButton.height =
                options.messageButtonHeight || dimensions.messageInput.height;

            dimensions.room.height =
                newHeight - 10
                - dimensions.roster.height - 10
                - dimensions.messageInput.height
                - options.paddingN - options.paddingS;
            dimensions.roomScrollBar = {
                width:  HemlockScrollBar.defaultOptions.thickness,
                height: dimensions.room.height
            };

            return dimensions;
        }

        private function getAllPositions(dimensions:Object):Object{
            // Returns an object hash that stores positions for all views.
            // `dimensions` is an object hash as returned by getAllDimensions().

            var positions:Object = {};
            positions.room = {
                x:  options.paddingW,
                y:  options.paddingN
            };
            positions.roomScrollBar = {
                x:  positions.room.x + dimensions.room.width + 5,
                y:  positions.room.y
            };
            positions.roster = {
                x:  positions.room.x - options.paddingW + 5,
                y:  positions.room.y + dimensions.room.height + 10
            };
            positions.messageInput = {
                x:  positions.room.x,
                y:  positions.roster.y + dimensions.roster.height + 10
            };
            positions.messageButton = {
                x:  positions.messageInput.x + dimensions.messageInput.width + 10,
                y:  positions.messageInput.y
                    + ((dimensions.messageInput.height - dimensions.messageButton.height) * 0.5)
            };
            return positions;
        }

        public function setSize(newWidth:Number, newHeight:Number):void{
            var dimensions:Object   = getAllDimensions(newWidth, newHeight);
            var positions:Object    = getAllPositions(dimensions);

            // Set total dimensions
            views.bg.width  = newWidth;
            views.bg.height = newHeight;

            // Set room dimensions and position
            views.room.x        = positions.room.x;
            views.room.y        = positions.room.y;
            views.room.width    = dimensions.room.width;
            views.room.height   = dimensions.room.height;
            views.roomScrollBar.x       = positions.roomScrollBar.x;
            views.roomScrollBar.y       = positions.roomScrollBar.y;
            views.roomScrollBar.setSize(dimensions.roomScrollBar.width, dimensions.roomScrollBar.height);

            // Set roster dimensions and position
            if(views.bgRoster){
                views.bgRoster.x        = positions.roster.x;
                views.bgRoster.y        = positions.roster.y;
                views.bgRoster.width    = dimensions.roster.width;
                views.bgRoster.height   = dimensions.roster.height;
            }
            if(views.roster){
                views.roster.x          = views.bgRoster.x + 10;
                views.roster.y          = views.bgRoster.y + 10;
                views.roster.width      = dimensions.roster.width - 20;
                views.roster.height     = dimensions.roster.height - 20;
            }

            // Set message input dimensions and position
            views.messageInput.x        = positions.messageInput.x;
            views.messageInput.y        = positions.messageInput.y;
            views.messageInput.width    = dimensions.messageInput.width;
            views.messageInput.height   = dimensions.messageInput.height;
            views.messageButton.x       = positions.messageButton.x;
            views.messageButton.y       = positions.messageButton.y;
            views.messageButton.width   = dimensions.messageButton.width;
            views.messageButton.height  = dimensions.messageButton.height;
        }
    }
}
