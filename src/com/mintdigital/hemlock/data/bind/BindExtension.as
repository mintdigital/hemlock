package com.mintdigital.hemlock.data.bind
{
  import flash.xml.XMLNode;

  import org.jivesoftware.xiff.data.bind.BindExtension;

  public class BindExtension extends org.jivesoftware.xiff.data.bind.BindExtension
  {
    override public function deserialize(node:XMLNode):Boolean
    {
      var strippedDownNode:XMLNode = node.cloneNode( true );
      var children:Array = strippedDownNode.childNodes.slice(); // the children array is a ref, it seems, not a clone, so it is not safe to iterate over while removing nodes
      for( var i:String in children ) {
        switch( children[i].nodeName ) {
      case "resource":
            children[i].removeNode();
        break;
      default:
        break;
    }
      }
      var returnVal:Boolean = super.deserialize( strippedDownNode );
      setNode( node );
      return ( returnVal );
    }
  }
}