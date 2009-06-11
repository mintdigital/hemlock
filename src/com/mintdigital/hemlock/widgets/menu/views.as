public override function createViews():void{
    Logger.debug('MenuWidget::createViews()');
    
    // Prop open widget
    with(graphics){
        beginFill(0, 0);
        drawRect(0, 0, options.width, options.height);
        endFill();
    }
    
    // Create logout control
    views.logout = new HemlockSprite();
    var logoutBG:DisplayObject = new skin.ButtonSignOut();
    with(logoutBG){
        width   = 100;
        height  = skin.BUTTON_SIGN_OUT_HEIGHT;
    }
    var logoutText:TextField = new TextField();
    with(logoutText){
        width   = logoutBG.width;
        height  = 20;
        y       = (logoutBG.height - height) * 0.5;
        text    = 'Sign out';
    }
    var logoutTextFormat:TextFormat = new TextFormat();
    with(logoutTextFormat){
        align   = TextFormatAlign.CENTER;
        color   = skin.LABEL_COLOR;
        font    = skin.FONT_PRIMARY;
        size    = 14;
    }
    logoutText.setTextFormat(logoutText.defaultTextFormat = logoutTextFormat);
    var logoutOverlay:Sprite = new Sprite(); // buttonMode=true overlay
    with(logoutOverlay){
        with(graphics){ // Prop open
            beginFill(0, 0);
            drawRect(0, 0, logoutBG.width, logoutBG.height);
            endFill();
        }
        width       = logoutBG.width;
        height      = logoutBG.height;
        buttonMode  = true;
    }
    views.logout.addChild(logoutBG);
    views.logout.addChild(logoutText);
    views.logout.addChild(logoutOverlay);
    views.logout.width  = logoutBG.width;
    views.logout.height = logoutBG.height;
    views.logout.x      = options.width - views.logout.width;

    // Add views to widget
    addChild(views.logout);
    updateSize();
}
