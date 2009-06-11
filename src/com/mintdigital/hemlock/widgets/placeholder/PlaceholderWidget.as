package com.mintdigital.hemlock.widgets.placeholder{
    import com.mintdigital.hemlock.display.HemlockSprite;
    import com.mintdigital.hemlock.HemlockEnvironment;
    import com.mintdigital.hemlock.utils.HashUtils;
    import com.mintdigital.hemlock.widgets.HemlockWidget;
    
    import flash.display.BlendMode;
    
    public class PlaceholderWidget extends HemlockWidget {
        
        public function PlaceholderWidget(parentSprite:HemlockSprite, options:Object = null){
            // Prepare default options
             _options = HashUtils.merge({
                 /*
                 You can override logoClass, logoWidth, and logoHeight either by
                 constructing this PlaceholderWidget with custom options, or by
                 creating a new skin.

                 In general, every new application should first have its own skin with
                 a default logo for that app. Then, future branded/specialized versions
                 of that app should override that default logo when constructing a
                 PlaceholderWidget.
                 */

                 logoClass:          skin['Logo'],
                 logoWidth:          skin['LOGO_WIDTH'],
                 logoHeight:         skin['LOGO_HEIGHT'],
                 backgroundColor:    0xECECEC
             }, options);
             _options.logoXIsCentered = !options.logoX;
             _options.logoYIsCentered = !options.logoY;
             _options = HashUtils.merge({
                 logoX:              (options.width  - options.logoWidth) * 0.5,
                 logoY:              (options.height - options.logoHeight) * 0.5
             }, _options);
             
            super(parentSprite, HashUtils.merge({
                delegates: {
                    views: new PlaceholderWidgetViews(this)
                }
            }, _options));
        }
                
    }
}
