package com.mintdigital.hemlock.widgets.signin{
    import com.mintdigital.hemlock.Logger;
    import com.mintdigital.hemlock.widgets.IDelegateEvents;
    import com.mintdigital.hemlock.widgets.HemlockWidget;
    import com.mintdigital.hemlock.widgets.HemlockWidgetDelegate;
    import com.mintdigital.hemlock.events.AppEvent;
    import com.mintdigital.hemlock.display.HemlockSprite;    

    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.ui.Keyboard;         // For handling "enter" keypresses
    
    public class SigninWidgetEvents extends HemlockWidgetDelegate implements IDelegateEvents{
        
        public function SigninWidgetEvents(widget:HemlockWidget){
            super(widget);
        }
        
        public function registerListeners():void{
            Logger.debug("SigninWidget::registerListeners()");
            widget.registerListener(views.username,        KeyboardEvent.KEY_DOWN,      onKeyboardEvent);
            widget.registerListener(views.password,        KeyboardEvent.KEY_DOWN,      onKeyboardEvent);
            widget.registerListener(views.signInButton,    MouseEvent.CLICK,            onSignIn);
            widget.registerListener(views.registerButton,  MouseEvent.CLICK,            onRegister);

            widget.registerListener(widget.dispatcher, AppEvent.SESSION_CREATE_SUCCESS, onSessionCreateSuccess);
            widget.registerListener(widget.dispatcher, AppEvent.SESSION_CREATE_FAILURE, onSessionCreateFailure);
        }

        //--------------------------------------
        //  Handlers
        //--------------------------------------

        private function onSignIn(event:MouseEvent):void {
            views.signInButton.disable({ label: 'Signing in...' });
            container.signIn(views.username.value, views.password.value);
        }

        private function onRegister(event:MouseEvent):void {
            views.registerButton.disable({ label: 'Registering...' });
            container.signUp(views.username.value, views.password.value);
        }

        private function onKeyboardEvent(event:KeyboardEvent):void{
            if(event.keyCode == Keyboard.ENTER){
                views.signInButton.disable({ label: 'Signing in...' });
                container.signIn(views.username.value, views.password.value);
            }
        }

        public function onSessionCreateSuccess(ev:AppEvent):void {
            views.signInButton.enable();
            views.username.value = '';
            views.password.value = '';
        }
        
        public function onSessionCreateFailure(ev:AppEvent):void {
            widget.resetForm();
            container.createErrorPopup('This username and password don\u2019t match.', {
                // parent: widget,
                width:  views.username.width,
                height: 70,
                // x:      views.signInButton.x,
                // y:      views.signInButton.y + views.signInButton.height + 10
                x:      widget.options.x + views.signInButton.x,
                y:      widget.options.y + views.signInButton.y + views.signInButton.height + 10
            });
        }

    }
}