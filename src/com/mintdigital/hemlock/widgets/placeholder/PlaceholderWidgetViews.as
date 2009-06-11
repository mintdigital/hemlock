package com.mintdigital.hemlock.widgets.placeholder{
    import com.mintdigital.hemlock.HemlockEnvironment;
    import com.mintdigital.hemlock.widgets.IDelegateViews;
    import com.mintdigital.hemlock.widgets.HemlockWidget;
    import com.mintdigital.hemlock.widgets.HemlockWidgetDelegate;
    import com.mintdigital.hemlock.utils.HashUtils;
    
    import flash.display.Shape;
    
    public class PlaceholderWidgetViews extends HemlockWidgetDelegate implements IDelegateViews{
        public function PlaceholderWidgetViews(widget:HemlockWidget){
            super(widget);
        }
        
        public function createViews():void{

            // Create background
            views.placeholder = new Shape();
            with(views.placeholder){
                x = 0;
                y = 0;
            }
            with(views.placeholder.graphics){
                beginFill(options.backgroundColor);
                drawRoundRect(0, 0, options.width, options.height, 20);
                endFill();
            }
            widget.addChild(views.placeholder);
            with(views.placeholder){
                width = options.width;
                height = options.height;
            }

            // Create logo
            views.logo = new options.logoClass();
            views.logo.x = options.logoX;
            views.logo.y = options.logoY;
            widget.addChild(views.logo);

            // Wrap up
            widget.updateSize();
        }

        public function setSize(width:Number, height:Number):void{
            views.placeholder.width = width;
            views.placeholder.height = height;

            if(options.logoXIsCentered){
                // Keep logo centered
                views.logo.x = (width - options.logoWidth) * 0.5;
            }else{
                // Reposition logo according to original options.logoX
                views.logo.x = options.logoX / options.width  * width;
            }

            if(options.logoYIsCentered){
                views.logo.y = (height - options.logoHeight) * 0.5;
            }else{
                views.logo.y = options.logoY / options.height * height;
            }
        }
    }
}