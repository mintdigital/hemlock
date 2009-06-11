package com.mintdigital.hemlock.data.disco
{
  import flash.xml.XMLNode;

  import org.jivesoftware.xiff.data.IExtension;
  import org.jivesoftware.xiff.data.disco.DiscoExtension;

  public class InfoDiscoExtension extends org.jivesoftware.xiff.data.disco.DiscoExtension implements IExtension
  {
    public static var NS:String = "http://jabber.org/protocol/disco#info";

    public function InfoDiscoExtension( xmlNode:XMLNode=null )
    {
      super( xmlNode );
    }

    public function getNS():String
    {
      return ( InfoDiscoExtension.NS );
    }

    public function getElementName():String
    {
      return ( org.jivesoftware.xiff.data.disco.DiscoExtension.ELEMENT );
    }
  }
}
