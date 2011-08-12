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
    is, pro;

if( (!Hemlock || !Hemlock.ConnectionAdapters) &&
    w.console && w.console.error){
  return w.console.error(
    'Error loading Hemlock (hemlock/connection-adapters/hemlock-pixel.js)');
}

is = Hemlock.is;



Hemlock.ConnectionAdapters.HemlockPixel = function(args){
  // `args`:
  //
  //    {
  //      username: <string>,
  //      password: <string>,
  //      room:     <string>,
  //      host:     <string>,
  //      mucHost:  <string>, // Multi-user chat host
  //    }

  args          = Hemlock.merge({}, args);
  this.username = args.username;
  this.password = args.password;
  this.room     = args.room;
  this.host     = args.host;
  this.mucHost  = args.mucHost; // Multi-user chat host
  this.jidResource = args.resource || 'hemlockPixel';
  this.botUsername = args.botUsername;

  if(this.room){ // Group chat
    this.bareJID  = this.room + '@' + this.mucHost;       // room@mucHost
    this.jid      = this.bareJID + '/' + this.username;   // room@mucHost/nick
  }else{
    this.bareJID  = this.username + '@' + this.host;      // nick@host
    this.jid      = this.bareJID  + '/' + this.jidResource;
                                                          // nick@host/adapter
  }

  this.connection = new Hemlock.Connection({
    jid:          this.jid,
    bareJID:      this.bareJID,
    password:     this.password,
    botUsername:  this.botUsername
  });
};

Hemlock.ConnectionAdapters.HemlockPixel.key = 'HemlockPixel';
pro = Hemlock.ConnectionAdapters.HemlockPixel.prototype;



/*** HemlockPixel > Connections ***/

pro.connect = function(args){
  // `args`:
  //
  //    {
  //      onUpdate:     <function>  // Arguments:
  //                                // - statusCode:  <int>
  //                                // - description: <string>
  //      timeoutDelay: <integer>   // Seconds until giving up
  //    }
  //
  // During the connection process, the `onUpdate` callback is run multiple
  // times whenever the status changes, e.g., "Connecting", "Connected",
  // "Disconnected". Its argument `statusCode` should be one of the constants
  // in `Strophe.Status`.

  args = Hemlock.merge({jid: this.jid}, args);
  this.connection.connect(args);
};

pro.disconnect = function(args){
  // `args`:
  //
  //    {
  //      reason: <string> // Human-readable reason for disconnecting
  //    }

  this.leaveRoom();
  this.connection.disconnect(args);
};



/*** HemlockPixel > Rooms ***/

pro.joinRoom = function(){
  // Requests to join the room specified by the configured JID.
  var elem =  $pres({ to: this.jid }).
                c('x', { xmlns: Strophe.NS.MUC }).
                c('history', { maxchars: 0 });
                  // `<history maxchars="0"/>` requests no history:
                  // http://xmpp.org/extensions/xep-0045.html#example-37

  this.connection.send(elem);
};

pro.leaveRoom = function(){
  // Requests to leave the room specified by the configured JID.
  var elem =  $pres({ to: this.jid, type: 'unavailable' }).
                c('status', 'Leaving');
  this.connection.send(elem);
};



/*** HemlockPixel > Sending ***/

pro.sendElement = function(elem){
  // Usage:
  //
  //    var elem = new Strophe.Builder(
  //      'presence', {...}).nodeTree; // XMLElement
  //    connectionAdapter.sendElement(elem);
  //
  // See also `sendMessage` and `sendData`.

  this.connection.send(elem);
};

pro.sendMessage = function(text, to){
  // Sends a normal text <message/>. `to` is the JID of the recipient; if not
  // supplied, the message is sent to a group chat room.
  //
  // To send a serializable data payload, use `sendData`.
  // To send a custom stanza, use `sendElement`.

  var elem =  $msg({
                to:     to || this.bareJID,
                type:   to ? 'chat' : 'groupchat',
                xmlns:  Strophe.NS.CLIENT
              }).c('body', text);

  this.sendElement(elem);
};

pro.sendData = function(type, data, to){
  // Convenience function for sending <message/>s stanzas that contain
  // serializable data payloads. `to` is the JID of the recipient; if not
  // supplied, the message is sent to a group chat room. Usage:
  //
  //    // Send publicly to everyone in the room:
  //    connectionAdapter.sendData('gameMove', {
  //      locationFrom: [10, 10],
  //      locationTo:   [20, 20]
  //    });
  //
  //    // Send privately to a specific user in the room:
  //    connectionAdapter.sendData('gameSecretMove', {
  //      locationFrom: [10, 10],
  //      locationTo:   [20, 20]
  //    }, 'bot@server/resource');
  //
  // To send a normal message, use `sendMessage`.
  // To send a custom stanza, use `sendElement`.

  var elem,
      id = [type, Hemlock.MESSAGE_ID_DATA_TYPE_SEPARATOR,
            Hemlock.getUniqueID()].join('');

  // Create <message/> stanza
  elem = $msg({
    to:     to || this.bareJID,
    type:   to ? 'chat' : 'groupchat',
    id:     id,
    xmlns:  Strophe.NS.CLIENT
  }).c('body', JSON.stringify(data).replace(/\"/g,'|'));

  this.sendElement(elem);
};



/*** HemlockPixel > Receiving ***/

pro.receiveElement = function(args){
  // `args`: Same as Hemlock.Handler constructor
  this.connection.addHandler(args);
};

pro.stopReceivingElement = function(args){
  // `args`: Same as Hemlock.Handler constructor

  var handlers = this.connection.handlers,
      handler, i, iMax;

  for(i = 0, iMax = handlers.length; i < iMax; i++){
    handler = handlers[i];
    if(handler.matchesArgs(args)){
      this.connection.deleteHandler(handler);
      i--; iMax--;
    }
  }
};

pro.receiveMessage = function(callback){
  // Convenience function for handling received <message/> stanzas that
  // contain normal messages (not data payloads). Usage:
  //
  //    connectionAdapter.receiveMessage(function(elem, text){
  //      var from = elem.getAttribute('from');
  //      console.log(from + ' said: ' + text);
  //    });
  //
  // To add a handler for incoming data payloads, use `receiveData`.
  // To add a custom handler for incoming stanzas, use `receiveElement`.

  this.receiveElement({
    callback: function(elem){
      var text = w.jQuery(elem).children('body').text();
        // Other children include `<composing/>` and `<paused/>` for use in
        // "typing" indicators.

      callback(elem, text);
      return true; // Keep this handler bound for reuse
    },
    name: 'message',
    id:   Hemlock.elemIsNormalMessage
  });
};

pro.stopReceivingMessages = function(){
  // Unbinds the general handler for incoming <message/> stanzas that contain
  // only normal messages. Handlers for data payloads are unaffected.

  this.stopReceivingElement({
    name: 'message',
    id:   Hemlock.elemIsNormalMessage
  });
};

pro.receiveData = function(dataType, callback) {
  // Convenience function for handling received <message/> stanzas that
  // contain serializable data payloads. Usage:
  //
  //    connectionAdapter.receiveData('gameMove', function(elem, data){
  //      var from = elem.getAttribute('from');
  //      console.log(from + ' moved from ' +
  //        data.locationFrom + ' to ' + data.locationTo);
  //    });
  //
  // To add a handler for incoming normal messages, use `receiveMessage`.
  // To add a custom handler for incoming stanzas, use `receiveElement`.

  this.receiveElement({
    callback: function(elem){
      var rawData = w.jQuery(elem).children('body').text(),
          data    = JSON.parse(rawData.replace(/\|/g,'"'));
      callback(elem, data);
      return true; // Keep this handler bound for reuse
    },
    name:     'message',
    dataType: dataType
  });
};

pro.stopReceivingData = function(dataType){
  // Usage:
  //
  //    var dataTypes = ['gameStart', 'gameMove', 'gameEnd'],
  //        i = dataTypes.length;
  //    while(i--){
  //      connectionAdapter.stopReceivingData(dataTypes[i]);
  //    }

  this.stopReceivingElement({
    name:     'message',
    dataType: dataType
  });
};

pro.stopReceivingAll = function(){
  // Removes handlers for all incoming elements, including data payloads.
  this.connection.deleteAllHandlers();
};

}(window));
