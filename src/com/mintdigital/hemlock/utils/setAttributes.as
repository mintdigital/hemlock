package com.mintdigital.hemlock.utils{
    import com.mintdigital.hemlock.Logger;

    public function setAttributes(object:Object, attributes:Object):void{
        // Deprecated; use setProperties() instead for consistency in terminology.
        Logger.debug('DEPRECATED: setAttributes(); use setProperties() instead.');
        setProperties(object, attributes);
    }
    
}
