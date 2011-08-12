package com.mintdigital.hemlock.data{
    import com.mintdigital.hemlock.data.JID;

    import org.jivesoftware.xiff.data.Presence;

    import flash.xml.XMLNode;

    public class Presence extends org.jivesoftware.xiff.data.Presence{

        // http://www.ietf.org/rfc/rfc3921.txt

        // Types
        public static const UNAVAILABLE_TYPE:String     = 'unavailable';
        public static const PROBE_TYPE:String           = 'probe';
        public static const SUBSCRIBE_TYPE:String       = 'subscribe';
        public static const UNSUBSCRIBE_TYPE:String     = 'unsubscribe';
        public static const SUBSCRIBED_TYPE:String      = 'subscribed';
        public static const UNSUBSCRIBED_TYPE:String    = 'unsubscribed';
        public static const ERROR_TYPE:String           = 'error';
        public static const VISIBLE_TYPE:String         = 'visible';    // See XEP-0018
        public static const INVISIBLE_TYPE:String       = 'invisible';  // See XEP-0018

        // Roles
        public static const MODERATOR_ROLE:String       = 'moderator';
        public static const PARTICIPANT_ROLE:String     = 'participant';
        public static const VISITOR_ROLE:String         = 'visitor';

        // "Show" status
        public static const SHOW_AWAY:String            = 'away';   // temporarily away
        public static const SHOW_CHAT:String            = 'chat';   // actively interested in chatting
        public static const SHOW_DND:String             = 'dnd';    // "Do Not Disturb"
        public static const SHOW_XA:String              = 'xa';     // "eXtended Away"

        protected var hemlockItemNode:XMLNode;
        protected var hemlockStatusNode:XMLNode;



        public function Presence(recipient:JID=null, sender:JID=null, presenceType:String=null, showVal:String=null, statusVal:String=null, priorityVal:Number=0){
            super(recipient, sender, presenceType, showVal, statusVal, priorityVal);
        }

        /**
         * Deserializes an XML object and populates the Presence instance with its data.
         *
         * @param xmlNode The XML to deserialize
         * @return An indication as to whether deserialization was sucessful
         * @availability Flash Player 7
         */
        override public function deserialize( xmlNode:XMLNode ):Boolean{
            var isDeserialized:Boolean = super.deserialize(xmlNode);
            
            if(isDeserialized){
                var children:Array = xmlNode.childNodes;
                for each(var child:XMLNode in children){
                    switch(child.nodeName){
                        // case 'show':
                        //     show = child.firstChild.nodeValue;
                        //     break;
                        // case 'status':
                        //     break;
                        // case 'priority':
                        //     priority = Number(child.firstChild.nodeValue);
                        //     break;
                        case 'x':
                            var xChildren:Array = child.childNodes;
                            for each(var xChild:XMLNode in xChildren){
                                switch(xChild.nodeName){
                                    case 'status':
                                        hemlockStatusNode = xChild;
                                        break;
                                    case 'item':
                                        hemlockItemNode = xChild;
                                        break;
                                }
                            }
                            break;
                    }
                }
            }
            return isDeserialized;
        }
        
        
        
        //--------------------------------------
        //  Properties
        //--------------------------------------
        
        override public function get status():String{
            return hemlockStatusNode
                ? hemlockStatusNode.attributes.code
                : null;
        }
        
        override public function set status(value:String):void{
            hemlockStatusNode = replaceTextNode(getNode(), hemlockStatusNode, 'status', value);
        }
        
        public function get item():XMLNode{ return hemlockItemNode; }

        public function get affiliation():String{
            return hemlockItemNode
                ? hemlockItemNode.attributes.affiliation
                : null;
        }
        
        public function get realJID():JID{
            return new JID(hemlockItemNode
                ? hemlockItemNode.attributes.jid
                : '');
        }
        
        public function get role():String{
            return hemlockItemNode
                ? hemlockItemNode.attributes.role
                : null;
        }
        
    }
}
