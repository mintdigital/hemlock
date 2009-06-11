package com.mintdigital.hemlock.skins.hemlockSoft{
    public class HemlockSoftSkin{
    
        include '../base/_baseSkin.as';



        //--------------------------------------
        //  Global
        //--------------------------------------

        [Embed(source="assets.swf", symbol="logoHemlock")]
        public static const Logo:Class;
        public static const LOGO_WIDTH:uint     = 280;
        public static const LOGO_HEIGHT:uint    = 53;

        [Embed(source="assets.swf", symbol="bgMain")]
        public static const BGBlock:Class;



        //--------------------------------------
        //  Fonts
        //--------------------------------------

        [Embed(source="fonts/Verdana.ttf", fontName="Verdana", mimeType="application/x-font-truetype")]
        public static const FontVerdana:Class;
        public static const FONT_VERDANA:String         = 'Verdana';

        [Embed(source="fonts/Verdana Bold.ttf", fontName="Verdana Bold", fontWeight="bold", mimeType="application/x-font-truetype")]
        public static const FontVerdanaBold:Class;
        public static const FONT_VERDANA_BOLD:String    = 'Verdana Bold';

        public static const FONT_PRIMARY:String         = FONT_VERDANA;
        public static const FONT_PRIMARY_BOLD:String    = FONT_VERDANA_BOLD;



        //--------------------------------------
        //  Controls
        //--------------------------------------

        [Embed(source="assets.swf", symbol="buttonBasic")]
            public static const ButtonBasic:Class;
        [Embed(source="assets.swf", symbol="buttonBasicHover")]
            public static const ButtonBasicHover:Class;
        [Embed(source="assets.swf", symbol="buttonBasicActive")]
            public static const ButtonBasicActive:Class;
        public static const BUTTON_COLOR:uint           = 0xFFFFFF;
        public static const BUTTON_HOVER_COLOR:uint     = 0xFFFFFF;
        public static const BUTTON_ACTIVE_COLOR:uint    = 0xFFFFFF;

        [Embed(source="assets.swf", symbol="textInputBG")]
        public static const BGTextInput:Class;
        public static const TEXT_INPUT_PADDING_N:uint   = 5;
        public static const TEXT_INPUT_PADDING_E:uint   = 9;
        public static const TEXT_INPUT_PADDING_S:uint   = 5;
        public static const TEXT_INPUT_PADDING_W:uint   = 9;
        public static const TEXT_INPUT_HEIGHT:uint      = 30;
        public static const TEXT_INPUT_COLOR:uint       = 0x555555;

        public static const LABEL_COLOR:uint            = 0x333333;



        //--------------------------------------
        //  Errors
        //--------------------------------------

        [Embed(source="assets.swf", symbol="errorBg")]
        public static const ErrorBG:Class;
        public static const ERROR_MIN_HEIGHT:uint   = 28;

        [Embed(source="assets.swf", symbol="errorIcon")]
        public static const ErrorIcon:Class;
        public static const ERROR_ICON_WIDTH:uint   = 24;
        public static const ERROR_ICON_HEIGHT:uint  = 24;



        //--------------------------------------
        //  ChatroomWidget
        //--------------------------------------

        [Embed(source="assets.swf", symbol="bgRoster")]
        public static const BGChatroomRoster:Class;

    }
}
