// For com.mintdigital.hemlock.widgets.countdown.CountdownWidget

override public function createViews():void{
    Logger.debug('CountdownWidget::createViews()');
    
    // Create countdown
    views.countdown = new Sprite();
    
    // Create countdown graphics
    var verticalMatrix:Matrix = new Matrix();
    verticalMatrix.createGradientBox(100, 100, 0.5 * Math.PI, 0, 0); // 90 degrees
        // TODO: Extract verticalMatrix to HemlockSprite
    with(views.countdown.graphics){
        beginGradientFill(GradientType.LINEAR, [0xFFFFFF, 0xE0E0E0], [1, 1], [0x00, 0xFF], verticalMatrix);
        lineStyle(5);
        lineGradientStyle(GradientType.LINEAR, [0xE0E0E0, 0xCCCCCC], [1, 1], [0x00, 0xFF], verticalMatrix);
        drawCircle(options.width/2, options.height/2, options.width/2);
        endFill();
    }
    
    // Create countdown text
    var countdownText:TextField = new TextField();
    var countdownTextFormat:TextFormat = new TextFormat();
    countdownTextFormat.align = TextFormatAlign.CENTER;
    countdownTextFormat.font = skin.FONT_ARIAL_ROUNDED;
    countdownTextFormat.letterSpacing = -2;
    countdownTextFormat.size = 36;
    countdownText.setTextFormat(countdownText.defaultTextFormat = countdownTextFormat);
    
    // Add countdown text
    var estimatedTextHeight:uint = (countdownTextFormat.size as uint) * 1.25;
        // Convert points to pixels. The scaling factor is a wild guess.
    countdownText.y = (options.height - estimatedTextHeight)/2;
    views.countdown.addChild(countdownText);
    with(countdownText){
        width = options.width;
        height = estimatedTextHeight;
        antiAliasType = AntiAliasType.ADVANCED;
        embedFonts = true;
    }
    
    // Add countdown
    addChild(views.countdown);
    with(views.countdown){
        width = options.width;
        height = options.height;
    }
}
