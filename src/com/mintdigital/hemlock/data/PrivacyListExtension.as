package com.mintdigital.hemlock.data{
    import org.jivesoftware.xiff.data.Extension;
    import org.jivesoftware.xiff.data.ExtensionClassRegistry;
    import org.jivesoftware.xiff.data.IExtension;
    import org.jivesoftware.xiff.data.ISerializable;
    
    import flash.xml.XMLNode;
    import flash.xml.XMLNodeType;
    
    // Implements XEP-0016 for privacy lists.
    public class PrivacyListExtension extends Extension implements IExtension, ISerializable{
        public static const NS:String       = 'jabber:iq:privacy';
        public static const ELEMENT:String  = 'query';
        
        public function PrivacyListExtension(xmlNode:XMLNode = null){
            super(xmlNode);
        }
        
        public static function enable():void{
            ExtensionClassRegistry.register(PrivacyListExtension);
        }
        
        public function serialize(parentNode:XMLNode):Boolean{
            if(parentNode != getNode().parentNode){
                parentNode.appendChild(getNode().cloneNode(true));
            }
            return true;
        }
        
        public function deserialize(xmlNode:XMLNode):Boolean{
            setNode(xmlNode);
            return true;
        }
        
        public function setActiveListName(name:String):void{
            var node:XMLNode = new XMLNode(XMLNodeType.ELEMENT_NODE, 'active');
            node.attributes.name = name;
            getNode().appendChild(node);
        }
        
        public function createList(name:String):void{
            var node:XMLNode = new XMLNode(XMLNodeType.ELEMENT_NODE, 'list');
            node.attributes.name = name;
            getNode().appendChild(node);
        }
        
        public function addListItem(options:Object):void{
            var item:XMLNode = new XMLNode(XMLNodeType.ELEMENT_NODE, 'item');
            
            item.attributes.action  = options.action;   // string
            item.attributes.order   = options.order;    // uint
            
            if(options.stanzaName){
                var itemStanza:XMLNode = new XMLNode(XMLNodeType.ELEMENT_NODE, options.stanzaName);
                item.appendChild(itemStanza);
            }
            
            listNode.appendChild(item);
        }
        
        
        
        //--------------------------------------
        //  Properties
        //--------------------------------------
        
        public function getElementName():String     { return ELEMENT; }
        public function getNS():String              { return NS; }
        
        public function get listNode():XMLNode{
            // TODO: Expand; not always first child
            return getNode().firstChild;
        }
        
    }
}
