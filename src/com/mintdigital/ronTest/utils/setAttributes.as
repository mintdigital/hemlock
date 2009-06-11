// TODO: Backport to hemlock-core

package com.mintdigital.ronTest.utils{
    public function setAttributes(object:Object, attributes:Object):void{
        // `attributes` is an options hash. Takes every attribute in the hash
        // and assigns its value to the `object`'s same attribute.
        
        for(var attributeName:String in attributes){
            object[attributeName] = attributes[attributeName];
        }
    }
}
