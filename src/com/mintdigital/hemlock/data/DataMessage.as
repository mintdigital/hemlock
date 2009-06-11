package com.mintdigital.hemlock.data{
    import com.adobe.serialization.json.JSON;
    import com.mintdigital.hemlock.Logger;

    public class DataMessage extends Message{
        /*
        DataMessage subclass:
        - Allows for more easily constructing message stanzas that contain
          data payloads instead of plain text (for chatrooms).
        - Provides a generalized pair of functions for serializing/
          deserializing payloads, which allows for seamlessly changing the
          serialization method later.
        */
        
        private var _payloadType:String;
        private var _payload:String; // serialized object
        
        public function DataMessage(newPayloadType:String, newPayload:*, options:Object = null){
            // newPayloadType: From a HemlockEvent's constants, e.g., AppEvent.GAME_BEGIN
            // newPayload: Object to be serialized to JSON
            
            Logger.debug('DataMessage::DataMessage()');
            
            if(!options){ options = {}; }
            _payloadType = options.payloadType = newPayloadType;
            Logger.debug('DataMessage::DataMessage() : newPayloadType = ' + newPayloadType);
            _payload = options.body = serializePayload(newPayload);
            Logger.debug('DataMessage::DataMessage() : _payload = ' + _payload);
            super(options);
        }
        
        public static function serializePayload(payload:*):String{
            // Convert object to JSON string for transferring via XMPP
            
            Logger.debug('DataMessage::serializePayload()');
            return JSON.encode(payload);
        }
        
        public static function deserializePayload(serializedPayload:String):*{
            // Convert JSON string to object for processing in ActionScript
            
            Logger.debug('DataMessage::deserializePayload() : serializedPayload = ' + serializedPayload);
            return serializedPayload ? JSON.decode(serializedPayload) : null;
        }
        


        //--------------------------------------
        //  Properties
        //--------------------------------------
        
        public function get payload():*{
            Logger.debug('DataMessage::get payload()');
            return deserializePayload(_payload);
        }
        
        public function set payload(value:*):void{
            Logger.debug('DataMessage::set payload()');
            body = _payload = serializePayload(value);
        }
    }
}