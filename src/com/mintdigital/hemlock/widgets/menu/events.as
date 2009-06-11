override public function registerListeners():void{
    // Registers listeners that are automatically started by
    // widget.startListeners() and stopped by widget.stopListeners().

    registerListener(views.logout, MouseEvent.CLICK, onLogoutEvent);
}

private function onLogoutEvent(e:MouseEvent):void {
    Logger.debug("MenuWidget::onLogoutEvent()");
    container.logout();
}
