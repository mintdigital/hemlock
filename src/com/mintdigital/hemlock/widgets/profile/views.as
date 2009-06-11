// For com.mintdigital.hemlock.widgets.profile.ProfileWidget

private function labelStyle():StyleSheet {
    var labelStyle:StyleSheet = new StyleSheet();
    labelStyle.setStyle('p',{
        fontFamily: 'Verdana,sans-serif',
        color: '#000000'
    });
    return labelStyle;
}

private function linkStyle():StyleSheet {
    var linkStyle:StyleSheet = new StyleSheet();
    linkStyle.setStyle('p',{
        fontFamily: 'Verdana,sans-serif',
        color: '#000000'
    });
    return linkStyle;
}

private function label(text:String):TextField {
    var label:TextField = new TextField();
    label.height = 16;
    label.styleSheet = labelStyle();
    label.htmlText = text;
    return label;
}

private function link(text:String):TextField {
    var link:TextField = new TextField();
    link.height = 20;
    link.width = 57;
    link.styleSheet = linkStyle();
    link.htmlText = text;
    return link;
}

/*1. var fileRefList:FileReferenceList = new FileReferenceList();  
2. fileRefList.addEventListener(Event.SELECT, selectHandler);  
3. fileRefList.browse();*/

public override function createViews():void{
    Logger.debug('SigninWidget() Creating views...');
    
    views.avatarLabel = label('<p>Select an image to upload:</p>');
    
    views.avatar = new TextField();
    views.avatar.type = TextFieldType.INPUT;
    views.avatar.y = views.avatarLabel.height + 10;
    views.avatar.width = 300;
    views.avatar.height = 20;
    views.avatar.background = true;
    views.avatar.backgroundColor = 0xF9F9F9;
    views.avatar.border = true;
    views.avatar.borderColor = 0x000000;
    
    views.avatar.defaultTextFormat = messageInputFormat();
    
    views.submitLink = link("<p>Submit</p>");
    views.submitLink.y = views.avatar.y + views.avatar.height + 10;

    addChild(views.avatarLabel);
    addChild(views.avatar);
    addChild(views.submitLink);
    
    updateSize();
}

private function messageInputFormat():TextFormat {
    var messageInputFormat:TextFormat = new TextFormat();
    messageInputFormat.font = 'Verdana';
    return messageInputFormat;
}
