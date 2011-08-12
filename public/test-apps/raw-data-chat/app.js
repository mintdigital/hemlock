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
/*global  window, Strophe, $msg, $pres, swfobject */

// Drives hemlock-test-apps/raw-data-group-chat.html.
// See entry point at the bottom of this file.

(function(w){

// Speed up common refs and allow name-munging
var Hemlock = w.Hemlock,
    $       = w.jQuery;

if(typeof Hemlock === 'undefined' && w.console && w.console.log){
  w.console.log('Error loading Hemlock (hemlock/test-apps/raw-data-chat/app.js)');
  return;
}

Hemlock.setDebugMode(true);

function HemlockTestApp(config){
  this.config = config;
  this.lastConnectionStatus = null;
  this.lastIncomingPresence = null;
}
HemlockTestApp.lastASLogString = null;
HemlockTestApp.lastASLogStringCount = 0;

HemlockTestApp.getInstance = function(config){ // singleton
  if(!HemlockTestApp.instance){
    HemlockTestApp.instance = new HemlockTestApp(config);
  }
  return HemlockTestApp.instance;
};



/*** Class functions ***/

HemlockTestApp.checkHemlockModules = function(){
  var numErrors = 0,
      logJS = function(string){
        // Backup function in case `Hemlock.debug` is unavailable.
        if(w.console && w.console.log){w.console.log(string);}
      },
      assert = function(condition, errorString){
        if(!condition){
          logJS('Error: ' + errorString);
          numErrors++;
        }
        return !!condition;
      };

  assert(Hemlock.getDebugMode,  "Hemlock.getDebugMode couldn't be found");
  assert(Hemlock.setDebugMode,  "Hemlock.setDebugMode couldn't be found");
  assert(Hemlock.debug,         "Hemlock.debug couldn't be found");
  if(assert(Hemlock.ConnectionAdapters,
      "Hemlock.ConnectionAdapters couldn't be found")){
    assert(Hemlock.ConnectionAdapters.HemlockPixel,
      "Hemlock.ConnectionAdapters.HemlockPixel couldn't be found");
    assert(Hemlock.ConnectionAdapters.Strophe,
      "Hemlock.ConnectionAdapters.Strophe couldn't be found");
  }
  assert(!Hemlock.Connection,
    'Hemlock.Connection should be private, not public');
  assert(Hemlock.Bridge,    "Hemlock.Bridge couldn't be found");
  assert(!Hemlock.Handler,  "Hemlock.Handler should be private, not public");

  return numErrors;
};

HemlockTestApp.logAS = function(string){
  // This is a public class function so that Hemlock AS can have access.

  // Enable to mirror ActionScript output to the JS console:
  // console.log('[HemlockPixel.swf] ' + string);

  string = string.replace(/</g, '&lt;').replace(/>/g, '&gt;');
  var $output = $('#actionscript-output');
  if(string === HemlockTestApp.lastASLogString){
    $output.children(':last-child').html([
      string, ' <span class="count">(',
      (++HemlockTestApp.lastASLogStringCount), 'x)</span>'
    ].join(''));
  }else{
    $output.append('<p>' + string + '</p>');
    HemlockTestApp.lastASLogString = string;
    HemlockTestApp.lastASLogStringCount = 1;
  }
  $output[0].scrollTop = $output[0].scrollHeight; // Scroll to bottom
};



/*** Instance functions ***/

(function(){
  var pro = HemlockTestApp.prototype;

  /*** Helpers > Connections ***/

  pro.connect = function(args){
    this.connectionAdapter.connect(args);
  };
  pro.disconnect = function(args){
    this.connectionAdapter.disconnect(args);
  };

  /*** Helpers > Sending ***/

  pro.sendElement = function(elem){
    Hemlock.debug('Sending element...');
    this.connectionAdapter.sendElement(elem);
  };
  pro.sendMessage = function(text, to){
    Hemlock.debug('Sending a normal message' +
      (to ? ' to ' + to : '') + '...'); // to to to!
    this.connectionAdapter.sendMessage(text, to);
  };
  pro.sendData = function(type, data, to){
    Hemlock.debug('Sending "' + type + '" data' +
      (to ? ' to ' + to : '') + '...'); // to to to!
    this.connectionAdapter.sendData(type, data, to);
  };

  /*** Helpers > Receiving ***/

  pro.receiveElement = function(args){
    this.connectionAdapter.receiveElement(args);
  };
  pro.stopReceivingElement = function(args){
    this.connectionAdapter.stopReceivingElement(args);
  };
  pro.receiveMessage = function(handler){
    this.connectionAdapter.receiveMessage(handler);
  };
  pro.stopReceivingMessages = function(){
    this.connectionAdapter.stopReceivingMessages();
  };
  pro.receiveData = function(dataType, handler){
    this.connectionAdapter.receiveData(dataType, handler);
  };
  pro.stopReceivingData = function(dataType){
    this.connectionAdapter.stopReceivingData(dataType);
  };
  pro.stopReceivingAll = function(){
    this.connectionAdapter.stopReceivingAll();
  };



  /*** Handlers ***/

  pro.onConnectionUpdate = function(status, description){
    // `status`:      Status code.
    // `description`: Human-readable string.

    var _this = this,
        ss    = Strophe.Status;

    Hemlock.debug(description);
    this.$statusText.html(description);

    switch(status){
      case ss.CONNECTED:
        this.$statusText.html('Connected ' +
          '(<span class="control" id="disconnect">Disconnect</span>)');
        this.showSendForm();
        break;

      case ss.DISCONNECTED:
        if(this.lastConnectionStatus !== ss.DISCONNECTING){
          (function(){
            var reason,
                lastPresence      = _this.lastIncomingPresence,
                lastPresenceFrom  = Hemlock.elemAttr(lastPresence, 'from'),
                lastPresenceType  = Hemlock.elemAttr(lastPresence, 'type');

            if(lastPresence.tagName.toLowerCase() === 'presence' &&
                Strophe.getResourceFromJid(lastPresenceFrom) ===
                  _this.config.username &&
                lastPresenceType === 'unavailable'
              ){
              reason = 'Kicked';
            }else{
              // The connection was unexpectedly lost for some other reason,
              // e.g., network loss, XMPP server unavailable.
              reason = 'Connection lost';
            }

            Hemlock.debug('Disconnect reason: ' + reason);
            _this.$statusText.html('Disconnected (' + reason + ')');
          }());
        }

        // Reset views
        this.$connectionAdapterText.html('');
        this.hideSendForm();
        this.hideActionScriptOutput();
        this.showConnAdapterForm();
        this.showSigninForm();
        break;

      case ss.ERROR:
        Hemlock.debug('Connection failed. (' + description + ')');
        break;
    }

    this.lastConnectionStatus = status;
  };

  pro.onPresence = function(elem){
    // Hemlock.debug('Received <presence/>:');
    // Hemlock.debug(elem);
    this.lastIncomingPresence = elem;

    var from = elem.getAttribute('from'),
        type = Hemlock.elemAttr(elem, 'type');
    if(Strophe.getResourceFromJid(from) === this.config.username){
      // Incoming <presence/> from the current user:
      switch(type){
        case 'error':
        case 'unavailable':
          this.$statusText.html('Disconnected');
          this.onConnectionUpdate(Strophe.Status.DISCONNECTED,
            'Disconnected');
          break;
        default:
          this.$statusText.html('Connected and present ' +
            '(<span class="control" id="disconnect">Disconnect</span>)');
          this.showSendForm();
      }
    }
  };

  pro.onMessage = function(elem, text){
    var from = elem.getAttribute('from');
    Hemlock.debug(from + ' sent text: ' + text);
  };

  pro.onDataMove = function(elem, data){
    var from = elem.getAttribute('from');
    Hemlock.debug(from + ' moved from ' + data.locFrom + ' to ' + data.locTo);
  };



  /*** Views ***/

  pro.$statusText             = $('#status');
  pro.$connectionAdapterText  = $('#connection-adapter');

  pro.showConnAdapterForm = function(){ this.toggleConnAdapterForm(true); };
  pro.hideConnAdapterForm = function(){ this.toggleConnAdapterForm(false); };
  pro.toggleConnAdapterForm = function(isVisible){
    $('form.connection-adapter').toggle(isVisible);
  };

  pro.showSigninForm = function(){ this.toggleSigninForm(true); };
  pro.hideSigninForm = function(){ this.toggleSigninForm(false); };
  pro.toggleSigninForm = function(isVisible){
    $('form.signin').toggle(isVisible);
  };

  pro.showSendForm = function(){ this.toggleSendForm(true); };
  pro.hideSendForm = function(){ this.toggleSendForm(false); };
  pro.toggleSendForm = function(isVisible){
    $('form.send').css('visibility', isVisible ? 'visible' : 'hidden');
  };

  pro.showActionScriptOutput = function(){ this.toggleActionScriptOutput(true); };
  pro.hideActionScriptOutput = function(){ this.toggleActionScriptOutput(false); };
  pro.toggleActionScriptOutput = function(isVisible){
    $('#actionscript-output').toggle(isVisible);
  };

}());



/*** Main ***/

HemlockTestApp.init = function(config){
  if(HemlockTestApp.checkHemlockModules() > 0){ return; }

  $('#status').show();

  var app       = HemlockTestApp.getInstance(config),
      appIsNew  = !!app.connectionAdapter,
                  // `false` if the app was previously connected, then
                  // disconnected, and is now reconnecting
      hca       = Hemlock.ConnectionAdapters,
      newAdapterText = 'Connecting as ' + config.username + ' via ';

  app.hideConnAdapterForm();
  app.hideSigninForm();

  switch(config.connectionAdapter){
    // case hca.WebSocket.key:
    //   // Not yet supported.
    //   app.$connectionAdapterText.html(newAdapterText + 'WebSocket.');
    //   break;

    case hca.HemlockPixel.key:
      app.$connectionAdapterText.html(newAdapterText + 'HemlockPixel.');
      app.showActionScriptOutput();
      $('#hemlock-pixel').show();
      if(!appIsNew){
        app.connectionAdapter = new hca.HemlockPixel(app.config);
      }
      break;

    case hca.Strophe.key:
      app.$connectionAdapterText.html(newAdapterText + 'Strophe (BOSH).');
      app.connectionAdapter = new hca.Strophe(Hemlock.merge(config, {
        httpHost: '/xmpp-httpbind'
          // For this to work, you must:
          //
          // 1. Enable this hook in ejabberd.cfg:
          //
          //      {5280, ejabberd_http, [
          //        {request_handlers, [
          //          {["xmpp-httpbind"], mod_http_bind}
          //        ]},
          //        web_admin
          //      ]}
          //
          // 2. Configure your web server to forward all /xmpp-httpbind
          //    requests from the main web port (e.g., 3000) to 5280:
          //
          //      # For nginx:
          //      server {
          //        listen 3000;
          //        ...
          //        location ~ ^/xmpp-httpbind$ {
          //          proxy_pass http://localhost:5280;
          //        }
          //      }
      }));
      break;

    default:
      throw 'Invalid connection adapter.';
  }

  // Handle incoming messages
  app.receiveMessage(function(elem, text){
    app.onMessage(elem, text);
    // app.stopReceivingMessages();
  });
  app.receiveData('move', function(elem, data){
    app.onDataMove(elem, data);
    // app.stopReceivingData('move');
  });

  // Handle arbitrary incoming XML
  app.receiveElement({
    name:     'presence',
    callback: function(elem){ app.onPresence(elem); return true; }
  });

  // Start connecting
  app.connect({
    onUpdate: function(status, description){
      app.onConnectionUpdate(status, description);
    }
  });

  if(!appIsNew){
    // Enable test controls
    $(function(){
      var $textForm = $('form.send.text'),
          $moveForm = $('form.send.move');

      $textForm.submit(function(ev){
        var text = $textForm.find('input[name="send-text"]').val();

        // Send text to other user
        app.sendMessage(text, app.config.otherJID);

        ev.preventDefault();
      });

      $moveForm.submit(function(ev){
        var locFrom = $moveForm.find('input[name="send-move[loc-from]"]').val(),
            locTo   = $moveForm.find('input[name="send-move[loc-to]"]').val();

        // Send data to other user
        app.sendData('move', {
          locFrom: locFrom,
          locTo:   locTo
        }, app.config.otherJID);

        ev.preventDefault();
      });
    });

    // Enable disconnect control
    $('#disconnect').live('click', function(ev){
      app.stopReceivingAll();
      app.disconnect({reason: 'User disconnected'});
    });
  }
};



// The following is the entry point that runs when the username and password
// are submitted. In a real app, this likely goes into a dynamic file (e.g.,
// index.html.erb, config.js.erb) so that the back-end supplies the username,
// password, and other configurations.

$(function(){
  var $connAdapterMenu = $('select[name="connection-adapter[name]"]'),
      hca = Hemlock.ConnectionAdapters;

  // Detect browser features
  $connAdapterMenu.val(hca.best());

  // Enable signin form
  $('form.signin').submit(function(ev){
    ev.preventDefault();

    var connAdapter = $connAdapterMenu.val(),
        appConfig = {
          username: $('input[name="signin[username]"]').val(),
          password: $('input[name="signin[password]"]').val(),
          otherJID: $('input[name="signin[other-jid]"]').val(),
          host:     $('input[name="signin[host]"]').val(),
          connectionAdapter:  connAdapter
        },
        initApp = function(){
          HemlockTestApp.init(appConfig);
        };

    switch(connAdapter){
      // case hca.WebSocket.key:
      //   // Not yet supported.
      //   break;

      case hca.HemlockPixel.key:
        (function(){
          var flashvars   = {
                username:     appConfig.username,
                password:     appConfig.password,
                host:         appConfig.host,
                policyPort:   8040,
                logFunction:  'HemlockTestApp.logAS'
              },
              params      = {},
              attributes  = {id: 'hemlock-pixel'};
          attributes.name = attributes.id;
          Hemlock.Bridge.create({
            flashvars:        flashvars,
            params:           params,
            attributes:       attributes,
            minFlashVersion:  '9.0.28',
            onSuccess:        initApp
          });
        }());
        break;

      case hca.Strophe.key:
        initApp();
        break;

      default:
        throw 'Invalid connection adapter.';
    }
  });
});

w.HemlockTestApp = HemlockTestApp;

}(window));
