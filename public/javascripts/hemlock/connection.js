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

/*jslint  browser:  true,
          continue: true,
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

// Speed up common refs and allow name-munging
var Hemlock = w.Hemlock, // Saves refs to all private modules
    Strophe = w.Strophe,
    is, pro;

if(!Hemlock && w.console && w.console.error){
  return w.console.error('Error loading Hemlock (hemlock/connection.js)');
}

is = Hemlock.is;



Hemlock.Connection = function(args){
  // `Hemlock.Connection` is private; use
  // `Hemlock.ConnectionAdapters.HemlockPixel`.

  // Inspired by:
  // http://code.stanziq.com/strophe/strophejs/doc/1.0.1/files/core-js.html#Strophe.Connection

  // `args`:
  //
  //    {
  //      jid:      <string>,
  //      password: <string>
  //    }

  var _this         = this;
  args              = Hemlock.merge({}, args);
  this.jid          = args.jid;
  this.password     = args.password;
  this.handlers     = [];     // Array of Hemlock.Handler instances
  this.botUsername  = args.botUsername;
  this.isActive     = false;  // Set to `true` to enable sending XML

  w.jQuery(Hemlock.Bridge).bind('incoming.hemlock', function(ev, xmlString){
    // Hemlock.debug('[Hemlock.Connection] Receiving XML: ' + xmlString);

    if(!_this.isActive){
      Hemlock.debug('Hemlock.Connection: Inactive; ignoring received data.');
      return;
    }

    var elems     = Hemlock.xmlStringToElements(xmlString),
        numElems  = elems.length,
        elem, data, handler,
        i, j, jMax;

    if(numElems === 0){ return; }

    for(i = 0; i < numElems; i++){
      elem = elems[i];
      if(!elem.tagName){ continue; }

      for(j = 0, jMax = _this.handlers.length; j < jMax; j++){
        handler = _this.handlers[j];
        if(handler.matchesElement(elem, _this.botUsername)){
          handler.callback.call(_this, elem);
        }
      }
    }
  });
};

pro = Hemlock.Connection.prototype;

pro.connect = function(args){
  // `args`:
  //
  //    {
  //      jid:          <string>,
  //      onUpdate:     <function>,
  //      timeoutDelay: <integer> // seconds
  //    }
  //
  // See also `Hemlock.ConnectionAdapters.HemlockPixel.prototype.connect`.

  var _this = this,
      _originalOnUpdate;
  this.isActive = true; // Enable sending/receiving initialization stanzas

  args = Hemlock.merge({}, args);
  _originalOnUpdate = args.onUpdate;
  args.onUpdate = function(status, description){
    // Hijack the bridge's `onConnectionUpdate` callback and add some
    // connection-specific behavior.

    var ss = Strophe.Status;

    switch(status){
      case ss.ERROR:
      case ss.CONNFAIL:
      case ss.AUTHFAIL:
      case ss.DISCONNECTED:
      case ss.DISCONNECTING:
        _this.isActive = false; // Disable sending any XML
        break;
    }

    if(_originalOnUpdate){
      _originalOnUpdate(status, description);
    }
  };

  Hemlock.Bridge.connect(args);
};

pro.disconnect = function(args){
  // `args`: { reason: <string> }
  //
  // See also `Hemlock.ConnectionAdapters.HemlockPixel.prototype.disconnect`.

  args = Hemlock.merge({}, args);
  Hemlock.debug('Disconnect reason: ' + args.reason);

  this.isActive = false;
  Hemlock.Bridge.disconnect(args);
  w.jQuery(Hemlock.Bridge).unbind('incoming.hemlock');
};

pro.send = function(elem){
  // `elem`: <message/>

  if(!this.isActive){
    Hemlock.debug('Hemlock.Connection: Inactive; not sending element.');
    return;
  }

  var xmlString = Strophe.serialize(elem);
  // Hemlock.debug('[Hemlock.Connection] Sending XML: ' + xmlString);
  Hemlock.Bridge.sendString(xmlString);
};

pro.flush = function(elem){
  // FIXME: Implement; immediately send any pending outgoing elements
  Hemlock.debug('Hemlock.Connection.prototype.flush: Not yet implemented');
};

pro.addHandler = function(args){
  // `args`: Same as Hemlock.Handler constructor
  this.handlers.push(new Hemlock.Handler(args));
};

pro.deleteHandler = function(handler){
  // `handler`: A Hemlock.Handler instance

  var i = this.handlers.indexOf(handler);
  if(i >= 0){
    this.handlers.splice(i, 1);
  }
};

pro.deleteAllHandlers = function(){
  this.handlers = [];
};

}(window));
