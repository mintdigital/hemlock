package com.mintdigital.hemlock.utils{
    
    public function setProperties(object:Object, properties:Object):void{
        // `properties` is an options hash. Takes every property in the hash
        // and assigns its value to the `object`'s same property.
        
        for(var propertyName:String in properties){
            object[propertyName] = properties[propertyName];
        }
    }
    
}
