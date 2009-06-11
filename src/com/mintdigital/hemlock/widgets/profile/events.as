// For com.mintdigital.hemlock.widgets.profile.ProfileWidget

override public function registerListeners():void{
    registerListener(views.avatar, MouseEvent.CLICK, onFileBrowse);
    registerListener(_fileReference, Event.SELECT, onSelect);
    registerListener(_fileReference, Event.OPEN, onOpen);
    registerListener(_fileReference, Event.COMPLETE, onComplete);
}



//--------------------------------------
//  Handlers
//--------------------------------------

private function onFileBrowse(e:MouseEvent):void {
    Logger.debug("ProfileWidget::onFileBrowse()");
    _fileReference.browse();
}

private function onSelect(e:Event):void {
    Logger.debug("ProfileWidget::onSelect");
    e.target.upload(new URLRequest("http://localhost:4567/upload"));
}

private function onOpen(e:Event):void {
    Logger.debug("ProfileWidget::onOpen");
}

private function onComplete(e:Event):void {
    Logger.debug("ProfileWidget::onComplete()");
}
