package com.mintdigital.hemlock.widgets.menu {
    import com.mintdigital.hemlock.Logger;
    import com.mintdigital.hemlock.HemlockEnvironment;
    import com.mintdigital.hemlock.controls.HemlockButton;
    import com.mintdigital.hemlock.controls.HemlockTextInput;
    import com.mintdigital.hemlock.display.HemlockSprite;
    import com.mintdigital.hemlock.HemlockEnvironment;
    import com.mintdigital.hemlock.widgets.HemlockWidget;

    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.events.TextEvent;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;
    
    public class MenuWidget extends HemlockWidget {
        include 'events.as';
        include 'views.as';
        protected var _room:String = 'menu';
        
        public function MenuWidget(parentSprite:HemlockSprite, options:Object = null) {
            super(parentSprite, options);
        }
    }
}