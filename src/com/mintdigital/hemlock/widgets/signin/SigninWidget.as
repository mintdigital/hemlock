package com.mintdigital.hemlock.widgets.signin{
    import com.mintdigital.hemlock.Logger;
    import com.mintdigital.hemlock.data.Message;
    import com.mintdigital.hemlock.HemlockEnvironment;
    import com.mintdigital.hemlock.widgets.HemlockWidget;
    import com.mintdigital.hemlock.display.HemlockSprite;    
    import com.mintdigital.hemlock.utils.HashUtils;
    
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.text.TextField;
    // import flash.text.StaticText;
    import flash.text.TextFieldType;  // For making editable TextFields
    import flash.text.TextFormat;     // For styling non-HTML TextFields
    import flash.text.StyleSheet;     // For styling HTML TextFields
    
    // Imports for dispatching arbitrary events repeatedly:
    import flash.utils.setInterval;
    import flash.utils.setTimeout;
    
    public class SigninWidget extends HemlockWidget {
        
        public function SigninWidget(parentSprite:HemlockSprite, options:Object = null){
            super(parentSprite, HashUtils.merge({
                delegates: {
                    views: new SigninWidgetViews(this),
                    events: new SigninWidgetEvents(this) 
                }
            }, options));
        }
        
        public function resetForm():void{
            views.password.value = '';
            views.signInButton.enable();
            views.registerButton.enable();
        }

    }
}
