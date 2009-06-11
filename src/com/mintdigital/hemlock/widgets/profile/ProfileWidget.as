package com.mintdigital.hemlock.widgets.profile{
    import com.mintdigital.hemlock.Logger;
    import com.mintdigital.hemlock.containers.HemlockContainer;
    import com.mintdigital.hemlock.widgets.HemlockWidget;
    
    import mx.utils.Base64Encoder; // Is this being used?
    
    import flash.events.MouseEvent;
    import flash.events.Event;
    import flash.text.TextField;
    import flash.text.TextFieldType;  // For making editable TextFields
    import flash.text.TextFormat;     // For styling non-HTML TextFields
    import flash.text.StyleSheet;     // For styling HTML TextFields
    import flash.ui.Keyboard;         // For handling "enter" keypresses
    import flash.net.FileReference;
    import flash.net.URLRequest;
    
    public class ProfileWidget extends HemlockWidget{
        include 'events.as';
        include 'views.as';
        
        private var eventTypes:Object;
        private var _fileReference:FileReference = new FileReference();
        private var _encoder:Base64Encoder = new Base64Encoder();
        
        public function ProfileWidget(container:HemlockContainer, options:Object = null){
            super(container, options);            
        }
        
    }
}
