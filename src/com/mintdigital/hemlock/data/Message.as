package com.mintdigital.hemlock.data
{
    import flash.xml.XMLNode;

    import com.mintdigital.hemlock.data.JID;
    import com.mintdigital.hemlock.Logger;

    import org.jivesoftware.xiff.data.Message;

    public class Message extends org.jivesoftware.xiff.data.Message
    {
        public static var CHAT_TYPE:String = org.jivesoftware.xiff.data.Message.CHAT_TYPE;
        public static var GROUPCHAT_TYPE:String = org.jivesoftware.xiff.data.Message.GROUPCHAT_TYPE;

        // Payload types
        public static const DEFAULT_PAYLOAD_TYPE:String = 'message';
        // Custom payloadType values should not start with this
        public static const PAYLOAD_TYPE_DELIMITER:String = '__';
        // Should not occur in custom payloadType values
        private var _payloadType:String;

        public function Message( options:Object = null )
        {
            /*
            Accepted options:
            - recipient:JID
            - sender:JID
            - id:String
            - body:String           (Message body in plain-text format)
            - htmlBody:String       (Message body in HTML)
            - type:String           (NORMAL_TYPE | CHAT_TYPE | GROUPCHAT_TYPE | HEADLINE_TYPE)
            - subject:String
            - payloadType:String    (For namespacing custom payloads, e.g.,
                                     button clicked, click coordinates. Used as
                                     message's ID prefix.)
            */

            Logger.debug( 'Message::Message()' );

            if ( !options ) {
                options = {};
            }

            // Select message ID. Custom payload types should NOT begin with the value of DEFAULT_PAYLOAD_TYPE.
            var newPayloadType:String = options.payloadType || DEFAULT_PAYLOAD_TYPE;
            var newID:String = exists( options.id ) ? options.id : generateID( newPayloadType + PAYLOAD_TYPE_DELIMITER );

            // Convert XIFF JIDs to Hemlock JIDs
            if ( options.recipient ) {
                options.recipient = new JID( options.recipient.toString() );
            }

            if ( options.sender ) {
                options.sender = new JID( options.sender.toString() );
            }

            // Call super() before setting attributes to avoid compiler errors
            super( options.recipient, newID, options.body, options.htmlBody, options.type, options.subject );

            // for some reason, xiff Message does take nor set the sender
            from = options.sender;

            _payloadType = newPayloadType;
        }

        public function toDataMessage():DataMessage
        {
            // Preserve attributes in options so that the DataMessage can be
            // typecast back to a Message if needed
            var options:Object = {};
            if(to)      { options.recipient = to; }
            if(from)    { options.sender = from; }
            if(id)      { options.id = id; }
            if(htmlBody){ options.htmlBody = htmlBody; }
            if(type)    { options.type = type; }
            if(subject) { options.subject = subject; }
            
            // Return copy
            Logger.debug('Message::toDataMessage() : body = ' + body);
            return new DataMessage(payloadType, DataMessage.deserializePayload(body), options);
        }

        public function get payloadType():String
        {
            // payloadType is read-only after Message is constructed because
            // changing it would change the message's ID: payloadType is used
            // as the ID's prefix.
            
            return _payloadType;
        }
        
    }
}
