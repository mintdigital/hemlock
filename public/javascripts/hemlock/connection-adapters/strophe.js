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
    'Error loading Hemlock (hemlock/connection-adapters/strophe.js)');
}

is = Hemlock.is;

// Strophe.log = function(level, msg){
//   var minLevel = Strophe.LogLevel[Hemlock.getDebugMode() ? 'DEBUG' : 'WARN'];
//   if(level >= minLevel){
//     Hemlock.debug(msg);
//   }
// };

Hemlock.ConnectionAdapters.Strophe = function(args){
  // See Hemlock.ConnectionAdapters.HemlockPixel docs.

  args          = Hemlock.merge({}, args);
  this.username = args.username;
  this.password = args.password;
  this.room     = args.room;
  this.host     = args.host;
  this.mucHost  = args.mucHost;   // Multi-user chat host
  this.httpHost = args.httpHost;  // Strophe/BOSH only
  this.jidResource = args.resource || 'strophe';

  if(this.room){ // Group chat
    this.bareJID  = this.room + '@' + this.mucHost;     // room@mucHost
    this.jid      = this.bareJID + '/' + this.username; // room@mucHost/nick
  }else{
    this.bareJID  = this.username + '@' + this.host;    // room@host
    this.jid      = this.bareJID  + '/' + this.jidResource;
                                                        // room@host/adapter
  }

  this.botUsername = args.botUsername;

  this.connection = new Strophe.Connection(this.httpHost);
  this._handlers  = []; // Private collection of Strophe.Handler references
};

Hemlock.ConnectionAdapters.Strophe.key = 'Strophe';
pro = Hemlock.ConnectionAdapters.Strophe.prototype;



/*** Strophe > Connections ***/

pro.connect = function(args){
  // See Hemlock.ConnectionAdapters.HemlockPixel docs.
  args = Hemlock.merge({jid: this.jid}, args);

  this.connection.connect(
    args.jid      || this.jid,
    args.password || this.password,
    function(statusCode, errorCondition){
      var ss = Strophe.Status,
          onUpdate = args.onUpdate,
          desc;
      switch(statusCode){
        case ss.ERROR:
          desc = 'Unknown error';
            // TODO: Update `desc` based on `errorCondition` string
          break;
        case ss.CONNECTING:     desc = 'Connecting...'; break;
        case ss.CONNFAIL:
          desc = 'Connection failed';
            // TODO: Update `desc` based on `errorCondition` string
          break;
        case ss.AUTHENTICATING: desc = 'Authenticating...'; break;
        case ss.AUTHFAIL:       desc = 'Authentication failed'; break;
        case ss.CONNECTED:      desc = 'Connected'; break;
        case ss.DISCONNECTED:   desc = 'Disconnected'; break;
        case ss.DISCONNECTING:  desc = 'Disconnecting...'; break;
        case ss.ATTACHED:       desc = 'Attached'; break;
      }
      onUpdate.call(null, statusCode, desc);
    }
    // TODO: Support `wait` argument (timeout delay)
    // TODO: Support `hold` argument (# connections to hold; usually 1)
  );
};

pro.disconnect = function(args){
  // See Hemlock.ConnectionAdapters.HemlockPixel docs.
  args = Hemlock.merge({}, args);
  this.connection.disconnect(args.reason);
};



/*** Strophe > Rooms ***/

pro.joinRoom = function(){
  // See Hemlock.ConnectionAdapters.HemlockPixel docs.
  var elem = $pres({ to: this.jid }).
    c('x', { xmlns: Strophe.NS.MUC }).
    c('history', { maxchars: 0 });
      // `<history maxchars="0"/>` requests no history:
      // http://xmpp.org/extensions/xep-0045.html#example-37
  this.connection.send(elem);
};

pro.leaveRoom = function(){
  // See Hemlock.ConnectionAdapters.HemlockPixel docs.
  var elem = $pres({ to: this.jid, type: 'unavailable' }).
    c('status', 'Leaving');
  this.connection.send(elem);
};



/*** Strophe > Sending ***/

pro.sendElement = function(elem){
  // See Hemlock.ConnectionAdapters.HemlockPixel docs.
  this.connection.send(elem);
};

pro.sendMessage = function(text, to){
  // See Hemlock.ConnectionAdapters.HemlockPixel docs.

  var elem =  $msg({
                to:     to || this.bareJID,
                type:   to ? 'chat' : 'groupchat',
                xmlns:  Strophe.NS.CLIENT
              }).c('body', text);

  this.sendElement(elem);
};

pro.sendData = function(type, data, to){
  // See Hemlock.ConnectionAdapters.HemlockPixel docs.

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



/*** Strophe > Receiving ***/

pro.receiveElement = function(args) {
  // See Hemlock.ConnectionAdapters.HemlockPixel docs.

  // Strophe only uses strict equalities for checking whether an element
  // matches a handler. Hemlock adds support for adding comparator functions
  // to handlers:
  //
  // 1. If the comparator from `args` is a function, it is *not* attached to
  //    the handler conditions as usual, but is instead stored in the
  //    handler's options.
  // 2. When an element arrives, Strophe uses strict equality to filter for
  //    handlers that should run. Since comparator functions were attached to
  //    handlers only via options, the handlers pass this set of filters.
  // 3. When each handler's callback runs, any comparator functions in its
  //    options are evaluated. As a result, step 2 is a equality pass, and
  //    step 3 is a comparator function pass.

  var adapter  = this,
      handler, // Strophe.Handler instance
      handlerOptions = {};

  function getHandlerCallback(){
    return function(elem){
      if(!elem.tagName){ return false; }

      var handler = this,
          hemlockOptions = handler.options && handler.options.hemlock,
          name = elem.tagName.toLowerCase(),
          type = Hemlock.elemAttr(elem, 'type'),
          id   = Hemlock.elemAttr(elem, 'id'  ),
          from = Hemlock.elemAttr(elem, 'from'),
          idParts, dataType;

      if(type){ type = type.toLowerCase(); }
      if(id  ){ id   = id  .toLowerCase(); }
      if(from){ from = from.toLowerCase(); }

      function isFromBot(){
        var botUsername = adapter.botUsername;
        return  !botUsername ||
                botUsername === Strophe.getResourceFromJid(from);
      }

      function handlerAttrMatchesElemAttr(handlerAttr, elemAttr){
        return (
          !handlerAttr ||                 // Handler has no condition

          handlerAttr === elemAttr ||     // Handler's condition matches elem

          (is.Function(handlerAttr) &&    // Handler's condition is a function,
            handlerAttr(elem, elemAttr))  // and it accepts the element
        );
      }



      if(id && name === 'message' && (type === 'groupchat' || isFromBot())){
        idParts = id.split(Hemlock.MESSAGE_ID_DATA_TYPE_SEPARATOR);
        if(is.present(idParts[0])){
          dataType = idParts[0].toLowerCase();
        }
      }

      if(hemlockOptions){
        if( handlerAttrMatchesElemAttr(hemlockOptions.name    , name    ) &&
            handlerAttrMatchesElemAttr(hemlockOptions.type    , type    ) &&
            handlerAttrMatchesElemAttr(hemlockOptions.id      , id      ) &&
            handlerAttrMatchesElemAttr(hemlockOptions.from    , from    ) &&
            handlerAttrMatchesElemAttr(hemlockOptions.dataType, dataType)
          ){
          args.callback(elem);
        }
      }

      return true; // To discard handler after one use, `return false`.
    };
  }

  // Attach data to handler that Strophe doesn't support natively
  handlerOptions.hemlock = {
    dataType: args.dataType && args.dataType.toLowerCase ?
                args.dataType.toLowerCase() : null
  };
  (function(){

    var attrs = ['name', 'type', 'id', 'from', 'dataType'],
        i = attrs.length,
        attr;

    while(i--){
      attr = attrs[i];

      // Transfer functions from `args` to `handlerOptions.hemlock`. Strophe
      // doesn't support comparator functions, so save them for later and
      // run them manually when the handler runs.
      if(is.Function(args[attr])){
        handlerOptions.hemlock[attr] = args[attr];
        args[attr] = null;
      }
    }
  }());

  handler = this.connection.addHandler(
    getHandlerCallback(),
    null, // namespace
    args.name,
    (args.type || null),
    (args.id   || null),
    (args.from || null),
    handlerOptions
  );

  this._handlers.push(handler);
};

pro.stopReceivingElement = function(args){
  // See Hemlock.ConnectionAdapters.HemlockPixel docs.

  var _this = this;
  Hemlock.objectValuesToLowerCase(
    args, ['name', 'type', 'id', 'from', 'dataType']);

  function matchesArgs(handler, args){
    var name     = args.name,
        type     = args.type,
        id       = args.id,
        from     = args.from,
        dataType = args.dataType,
        handOpts = handler.options.hemlock;

    return (
      // No args || Args condition        || Args condition matches
      // cond:   || matches handler attr: || handler options:
      (!name     || name === handler.name || name     === handOpts.name) &&
      (!type     || type === handler.type || type     === handOpts.type) &&
      (!id       || id   === handler.id   || id       === handOpts.id  ) &&
      (!from     || from === handler.from || from     === handOpts.from) &&
      (!dataType ||                          dataType === handOpts.dataType)
    );
  }

  // Delete matching handlers
  (function(){
    var adapter  = _this,
        handlers = adapter._handlers,
        handler, handlerIndex, i, iMax;

    for(i = 0, iMax = handlers.length; i < iMax; i++){
      handler = handlers[i];
      if(matchesArgs(handler, args)){
        adapter.connection.deleteHandler(handler);
        handlerIndex = handlers.indexOf(handler);
        if(handlerIndex >= 0){
          handlers.splice(handlerIndex, 1);
        }
        i--; iMax--;
      }
    }
  }());
};

pro.receiveMessage = function(callback){
  // See Hemlock.ConnectionAdapters.HemlockPixel docs.

  this.receiveElement({
    callback: function(elem){
      var text = w.jQuery(elem).children('body').text();
      callback(elem, text);
      return true; // Keep this handler bound for reuse
    },
    name: 'message',
    id:   Hemlock.elemIsNormalMessage
  });
};

pro.stopReceivingMessages = function(){
  // See Hemlock.ConnectionAdapters.HemlockPixel docs.

  this.stopReceivingElement({
    name: 'message',
    id:   Hemlock.elemIsNormalMessage
  });
};

pro.receiveData = function(dataType, callback){
  // See Hemlock.ConnectionAdapters.HemlockPixel docs.

  this.receiveElement({
    callback: function(elem) {
      var rawData = w.jQuery(elem).text(),
          data    = JSON.parse(rawData.replace(/\|/g,'"'));
      callback(elem, data);
      return true;
    },
    name:     'message',
    dataType: dataType
  });
};

pro.stopReceivingData = function(dataType){
  // See Hemlock.ConnectionAdapters.HemlockPixel docs.

  this.stopReceivingElement({
    name:     'message',
    dataType: dataType
  });
};

pro.stopReceivingAll = function(){
  // Removes handlers for all incoming elements, including data payloads.
  var numHandlers = this._handlers.length,
      i = numHandlers;
  while(i--){ this.connection.deleteHandler(this._handlers[i]); }
};

// pro.handlers = {};

}(window));
