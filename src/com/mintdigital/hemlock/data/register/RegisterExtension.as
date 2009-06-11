package com.mintdigital.hemlock.data.register
{
  import flash.xml.XMLNode;

  import org.jivesoftware.xiff.data.register.RegisterExtension;

  import com.mintdigital.ErrorCode;

  public class RegisterExtension extends org.jivesoftware.xiff.data.register.RegisterExtension
  {
    private var _errors:Array = [];

    override public function get instructions():String 
    { 
      try {
        return ( super.instructions );
      }
      catch ( error:TypeError ) {
        if ( error.errorID == ErrorCode.NULL_OBJECT_REFERENCE ) {
          return ( null );
        }
        else {
          throw ( error );
        }
      }
      return ( null ); // will never reach here, but actionscript compiler demands it to compile for some reason
    }

    override public function getField( name:String ):String
    {
      try {
        return ( super.getField( name ) );
      }
      catch ( error:TypeError ) {
        if ( error.errorID == ErrorCode.NULL_OBJECT_REFERENCE ) {
          return ( null );
        }
        else {
          throw ( error );
        }
      }
      return ( null ); // will never reach here, but actionscript compiler demands it to compile for some reason
    }

    public function get status():String
    {
      if ( instructions ) {
        return ( "registering" );
      }
      else if ( errors.length > 0 ) {
        return ( "errors" );
      }
      else {
        return ( "complete" );
      }
    }

    public function get doc():XMLNode
    {
      return ( getNode().parentNode );
    }

    public function get errors():Array
    {
      if ( _errors.length == 0 ) {
        for( var i:int = 0; i<doc.childNodes.length; i++ ) {
          if ( doc.childNodes[i].nodeName.toLowerCase() == 'error' ) {
            _errors.push( doc.childNodes[i] );
          }
        }
      }
      return ( _errors );
    }
  }
}
