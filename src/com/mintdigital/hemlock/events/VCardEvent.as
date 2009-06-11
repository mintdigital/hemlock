package com.mintdigital.hemlock.events{
    import flash.events.*;

    import com.mintdigital.hemlock.vcard.VCard;
    
    public class VCardEvent extends HemlockEvent {
 
        public static const LOADED:String           = 'vcardLoaded';
        public static const AVATAR_LOADED:String    = 'vcardAvatarLoaded';
        public static const SAVED:String            = 'vCardSaved';
        public static const ERROR:String            = 'vcardError';

        public function VCardEvent( type:String, options:Object = null ) {
            super( type, options );
        }
    
        override public function clone():Event {
            return new VCardEvent( type, options );
        }
        
        override public function toString():String{
              return formatHemlockEventToString('VCardEvent');
        }
        
        
        
        //--------------------------------------
        //  Properties
        //--------------------------------------
        
        public function get vcard():VCard { return options.vcard; }
    
    }
}
