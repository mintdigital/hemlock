package com.mintdigital.hemlock.utils{
    import flash.display.DisplayObject;
    import flash.geom.ColorTransform;
    
    public class ColorUtils{
        
        private static var solidColorTransforms:Object = {};

        public static function uintToRGB(color:uint):Array /* of uints */{
            // Converts the given uint (e.g., 0x336699) to an array of uints
            // (e.g., [0x33, 0x66, 0x99]).
            // Source: http://vinodonflex.wordpress.com/2008/01/15/color-picker-uint-to-rgb/#comment-70

            var r:uint = (color >> 16) & 0xFF,
                g:uint = (color >> 8) & 0xFF,
                b:uint = color & 0xFF;
            return [r, g, b];
        }
        
        public static function setColor(displayObject:DisplayObject, color:uint):void{
            if(!solidColorTransforms[color]){
                var colorTransform:ColorTransform = new ColorTransform();
                colorTransform.color = color;
                solidColorTransforms[color] = colorTransform;
            }
            displayObject.transform.colorTransform = solidColorTransforms[color];
        }
        
    }
}
