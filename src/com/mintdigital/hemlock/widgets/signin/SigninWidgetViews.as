package com.mintdigital.hemlock.widgets.signin{
    import com.mintdigital.hemlock.widgets.IDelegateViews;
    import com.mintdigital.hemlock.widgets.HemlockWidget;
    import com.mintdigital.hemlock.widgets.HemlockWidgetDelegate;
    
    import com.mintdigital.hemlock.Logger;
    import com.mintdigital.hemlock.HemlockEnvironment;
    
    import com.mintdigital.hemlock.controls.HemlockButton;
    import com.mintdigital.hemlock.controls.HemlockPasswordInput;
    import com.mintdigital.hemlock.controls.HemlockTextInput;
    
    import com.mintdigital.hemlock.display.HemlockLabel;
    import com.mintdigital.hemlock.display.HemlockSprite;
    
    public class SigninWidgetViews extends HemlockWidgetDelegate implements IDelegateViews{
        
        public function SigninWidgetViews(widget:HemlockWidget){
            super(widget);
        }
        
        public function createViews():void{
            Logger.debug('SigninWidget::createViews()');

            // Create background
            views.background = new skin.BGBlock();
            views.background.width = options.width;
            views.background.height = options.height;

            // Create username input and label
            views.username = new HemlockTextInput('username', '', {
                width:  250
                // defaultText: '...'
            });
            views.usernameLabel = new HemlockLabel('Username', views.username, {
                x:  20,
                y:  20
            });
            views.username.setPosition(
                views.usernameLabel.x,
                views.usernameLabel.y + views.usernameLabel.height + 5
            );

            // Create password input and label
            views.password = new HemlockPasswordInput('password', '', {
                width:      views.username.width,
                height:     views.username.height
            });
            views.passwordLabel = new HemlockLabel('Password', views.password, {
                x:  views.usernameLabel.x,
                y:  views.username.y + views.username.height + 10
            });
            views.password.setPosition(
                views.passwordLabel.x,
                views.passwordLabel.y + views.passwordLabel.height + 5
            );

            // Create signin button
            views.signInButton = new HemlockButton('signin', null, {
               x:       views.usernameLabel.x,
               y:       views.password.y + views.password.height + 20,
               width:   (views.username.width / 2) - 10,
               label:   'Sign in'
            });

            // Create registration button
            views.registerButton = new HemlockButton('register', null, {
                x:      views.signInButton.x + views.signInButton.width + 20,
                y:      views.signInButton.y,
                width:  views.signInButton.width,
                label:  'Register'
            });

            // Add views to widget
            widget.addChild(views.background);
            widget.addChild(views.username);
            widget.addChild(views.usernameLabel);
            widget.addChild(views.password);
            widget.addChild(views.passwordLabel);
            widget.addChild(views.signInButton);
            widget.addChild(views.registerButton);

            widget.updateSize();
        }
    }
}
