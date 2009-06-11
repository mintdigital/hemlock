package com.mintdigital.hemlock.data.muc
{
  import flash.xml.XMLNode;

  import org.jivesoftware.xiff.data.muc.MUCUserExtension;

  public class MUCUserExtension extends org.jivesoftware.xiff.data.muc.MUCUserExtension
  {
    public static var NS:String = org.jivesoftware.xiff.data.muc.MUCUserExtension.NS;
    public static var ELEMENT:String = "query";

    public function MUCUserExtension( parent:XMLNode=null )
    {
      super( parent );
    }

    override public function getElementName():String
    {
      return ( com.mintdigital.hemlock.data.muc.MUCUserExtension.ELEMENT );
    }
  }
}
