package com.mintdigital.hemlock.utils{
    public class GraphicsUtils{
        
        import flash.display.Graphics;

        public static function fill(graphics:Graphics, coords:Object, color:uint = 0x000000, alpha:Number = 0):void{
            // For use in propping open Shapes/Sprites to certain dimensions, or
            // for filling a Shape/Sprite with a placeholder color, such as
            // 0xFF0000.

            // `coords` structure:
            // { width: <Number>, height: <Number> }

            // Example usage:
            // - GraphicsUtils.fill(views.contentWrapper, coords.contentWrapper);
            // - GraphicsUtils.fill(views.placeholder, coords.placeholder, 0xFF0000, 0.5);

            with(graphics){
                beginFill(color, alpha);
                drawRect(0, 0, coords.width, coords.height);
                endFill();
            }
        }
        
    }
}
