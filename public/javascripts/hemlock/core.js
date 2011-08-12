/*!
 *  Hemlock
 *  http://hemlock-kills.com
 *  http://github.com/mintdigital/hemlock
 *
 *  Copyright 2011, Mint Digital Limited
 *  MIT License
 *
 *  With inspiration from:
 *  - http://jquery.com/
 *  - http://code.stanziq.com/strophe/
 */

/*
Usage
=====

var app = new MyApp();
app.connectionAdapter = new Hemlock.ConnectionAdapters.HemlockPixel({
  username: 'ron',
  password: 'secret',
  room:     'room123',
  host:     'localhost',
  mucHost:  'conference.localhost'
});

// Embed the swf
Hemlock.Bridge.create({
  flashvars:  {},
  params:     {},
  attributes: {id: 'hemlock-pixel'}
});

// Delegating helper methods to connection adapter (optional):
app.connect         = app.connectionAdapter.connect;
app.disconnect      = app.connectionAdapter.disconnect;
app.sendData        = app.connectionAdapter.sendData;
app.sendElement     = app.connectionAdapter.sendElement;
app.receiveData     = app.connectionAdapter.receiveData;
app.receiveElement  = app.connectionAdapter.receiveElement;

// Connecting:
app.connect({
  onUpdate: function(statusCode, description){
    Hemlock.debug('Status: ' + description + ' (code: ' + statusCode + ')');
    app.addConnectionHandlers(); // Defined below
  }
});

// Sending data:
app.sendData('gameMove', {
  locFrom:  [10, 10],
  locTo:    [20, 20]
});
app.sendData('gameSecretMove', {
  locFrom:  [10, 10],
  locTo:    [20, 20]
}, 'bot@server/resource);
app.sendElement(elem); // `elem`: A `Strophe.Builder` instance

// Receiving data:
app.addConnectionHandlers = function(){
  app.receiveData('gameMove', function(elem, data){
    var from = elem.getAttribute('from');
    Hemlock.debug(from + ' moved from ' +
      data.locFrom + ' to ' + data.locTo);
  });
  app.receiveData('gameEnd', function(elem, data){
    app.disconnect();
  });
  app.receiveElement({
    name: 'presence',
    callback: function(elem, data){
      var from = elem.getAttribute('from'),
          type = elem.getAttribute('type');
      switch(type){
        case 'error':
        case 'unavailable':
          Hemlock.debug(from + ' disconnected');
          break;
        default:
          Hemlock.debug(from + ' joined the room');
          break;
      }
    }
  });
};



Internals
=========

Hemlock is a full stack that uses three different socket connection methods,
depending on the browser's capabilities:
- If WebSocket JS API is available:
  - Hemlock.ConnectionAdapters.WebSocket
- Else if Flash is available:
  - Hemlock.ConnectionAdapters.HemlockPixel
- Else:
  - Hemlock.ConnectionAdapters.Strophe + Strophe (BOSH)

Hemlock is the stack. HemlockPixel is the ActionScript component.

Regardless of socket connection method, use Strophe for building XML elements,
working with JIDs, and other core functions.

Parts of the stack:
- App JS: Business logic
- Connection adapter: JS objects, XML strings/elements
  - Uses one of the Hemlock.ConnectionAdapters.* classes.
  - Exposes a desirable API. All adapters should have the same API, regardless
    of the connection class it uses.
- Connection: XML strings
  - Uses Hemlock.Connection or Strophe.Connection.
  - Parses incoming XML into JS objects.
  - Manages handlers on incoming data.
  - Turns outgoing JS objects into XML.
- If using the HemlockPixel connection adapter:
  - Hemlock.Bridge JS (singleton): Raw data
    - Blindly passes raw data between JS and AS.
    - Aside from setting up HemlockPixel.swf, should be as skinny as possible.
  - HemlockPixel AS
- Socket
- Ejabberd
*/

/*jslint  browser:  true,
          eqeqeq:   true,
          immed:    false,
          newcap:   true,
          nomen:    false,
          onevar:   true,
          plusplus: false,
          undef:    true,
          white:    false */
/*global  window, Hemlock, Strophe, $msg, $pres, swfobject */

(function(w){

var Hemlock, class2type = {};

function _debug(obj){
  var c = w.console;
  if(Hemlock.getDebugMode() && c && c.log){ c.log(obj); }
}
function _error(obj){
  var c = w.console;
  if(c && c.error){ c.error(obj); }
}

// Check for dependencies:
// TODO: Also check versions
function _depError(dep){
  _error('Hemlock JS requires ' + dep + '.');
}
if(!w.Strophe  ){ return _depError('Strophe 1.0+');   }
if(!w.jQuery   ){ return _depError('jQuery 1.3+');    }
if(!w.swfobject){ return _depError('swfobject 2.2+'); }
if(!w.JSON     ){ return _depError('window.JSON');    }



// Prepare `class2type` hash (inspired by jQuery 1.4.3):
(function(){
  var types = 'Boolean0Number0String0Function0Array0Date0RegExp0Object'.
                split(0),
      i = types.length, type;

  while(i--){
    type = types[i];
    class2type['[object ' + type + ']'] = type.toLowerCase();
  }
}());



w.Hemlock = Hemlock = {
  MESSAGE_ID_DATA_TYPE_SEPARATOR: '__',
  debugMode:    false, // Private; toggle with `setDebugMode` in your app
  getDebugMode: function(){ return Hemlock.debugMode; },
  setDebugMode: function(bool){ Hemlock.debugMode = !!bool; },
  debug:        _debug,
  error:        _error,
  is: {
    // Convenience methods for the most common checks; use
    // `Hemlock.type` for more.

    Undefined:  function(obj){ return typeof obj === 'undefined'; },
    blank:      function(obj){
                  var is = Hemlock.is;
                  return  obj === null || is.Undefined(obj) ||
                          !is.String(obj) || /^\s*$/.test(obj);
                },
    present:    function(obj){ return !Hemlock.is.blank(obj);           },
    String:     function(obj){ return Hemlock.type(obj) === 'string';   },
    RegExp:     function(obj){ return Hemlock.type(obj) === 'regexp';   },
    Function:   function(obj){ return Hemlock.type(obj) === 'function'; }
  },
  type: function(obj){
    // Usage:
    //
    //   Hemlock.type('foo') // => 'string'
    //   Hemlock.type(/bar/) // => 'regexp'
    //
    // Inspired by jQuery 1.4.3.

    return obj === null ? String(obj) :
      class2type[Object.prototype.toString.call(obj)] || 'object';
  },
  objectValuesToLowerCase: function(obj, keys){
    // Given a plain object (hash) `obj` and a string array `keys`, converts
    // the specified string values to lowercase in place.

    var i = keys.length, key;
    while(i--){
      key = keys[i];
      if(obj[key] && obj[key].toLowerCase){
        obj[key] = obj[key].toLowerCase();
      }
    }
  },
  elemAttr: function(elem, attr){
    var val = elem.getAttribute(attr);
    return (val ? val.toLowerCase() : null);
  },
  elemIsNormalMessage: function(elem, id){
    // Returns true if `elem` is a `<message/>` containing normal text.
    // Returns false if it's a `<message/>` containing a data payload, or if
    // it's not a `<message/>` at all.

    if(elem && !id){ id = elem.getAttribute('id'); }
    return id === null || typeof id === 'undefined' ||
           id.indexOf(Hemlock.MESSAGE_ID_DATA_TYPE_SEPARATOR) < 0;
  },
  xmlStringToElements: function(xmlString){
    // Returns an array of element objects:
    //
    //   xmlStringToElements('<x>1</x>')          // => [<x>1</x>]
    //   xmlStringToElements('<x>1</x><y>2</y>')  // => [<x>1</x>, <y>2</y>]
    //
    // Adapted from: http://www.w3schools.com/xml/xml_parser.asp

    var doc; // Document instance

    // Wrap `xmlString` with a temporary parent in case it
    // contains multiple siblings
    xmlString = '<xml>' + xmlString + '</xml>';

    // Convert XML string to Document
    if(w.DOMParser){
      (function(){
        var parser = new w.DOMParser();
        doc = parser.parseFromString(xmlString, 'text/xml');
      }());
    }else if(w.ActiveXObject){ // e.g., Internet Explorer
      doc = new w.ActiveXObject('Microsoft.XMLDOM');
      doc.async = 'false';
      doc.loadXML(xmlString);
    }
    if(!doc){
      _debug('This browser appears incapable of parsing XML.');
      return;
    }

    return doc.firstChild.childNodes;
  },
  merge: function(defaults, overwrites){
    // `defaults` and `overwrites` are hashes. Uses keys/values from
    // `overwrites` to overwrite keys/values in `defaults`.

    // TODO: Create standalone version
    return w.jQuery.extend(defaults, overwrites);
  },
  getUniqueID: (function(){
    var id = 0; // private
    return function(){ return ++id; };
  }()),
  ConnectionAdapters: {
    best: function(){
      /*if(Hemlock.Support.webSocket()){
        return Hemlock.ConnectionAdapters.WebSocket.key;
      }else*/ if(Hemlock.Support.flash()){
        return Hemlock.ConnectionAdapters.HemlockPixel.key;
      }else{
        return Hemlock.ConnectionAdapters.Strophe.key;
      }
    }
  },
  Support: {
    webSocket: function(){ return !!w.WebSocket; },
    flash: function(){
      return !swfobject || swfobject.getFlashPlayerVersion().major > 0;
    }
  }
};

}(window));
