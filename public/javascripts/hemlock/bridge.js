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
    is;

if(!Hemlock && w.console && w.console.error){
  return w.console.error('Error loading Hemlock (hemlock/bridge.js)');
}

is = Hemlock.is;



Hemlock.Bridge = {
  // Primary hook between Hemlock JS and Hemlock AS (a.k.a., HemlockPixel,
  // the .swf file). Interact with this only via `Hemlock.Connection` or
  // Hemlock AS. The only reason this object is public is to give access to
  // Hemlock AS; consider it private otherwise.

  actionScript: null, // Set in Hemlock.Bridge.create
  create: function(args){
    // `args`:
    //
    //    {
    //      flashvars:    <hash object>,
    //      params:       <hash object>,
    //      attributes:   <hash object>,
    //      onSuccess:    <function>,
    //      [ onFailure:  <function>, ]
    //      [ minFlashVersion:      <string>, ]
    //      [ hemlockPixelSwfURL:   <string>, ]
    //      [ expressInstallSwfURL: <string>  ]
    //    }

    var Bridge = Hemlock.Bridge;

    if(Bridge.actionScript){
      // The bridge already exists from a previous connection. Stop here
      // without trying to recreate the bridge.

      if(args.onSuccess){ args.onSuccess(); }
      return;
    }

    if(is.blank(args.minFlashVersion)){
      args.minFlashVersion = '9.0.28';
    }
    if(is.blank(args.hemlockPixelSwfURL)){
      args.hemlockPixelSwfURL = '/flash/hemlock-pixel.swf';
    }
    if(is.blank(args.expressInstallSwfURL)){
      args.expressInstallSwfURL = '/flash/expressInstall.swf';
    }
    args.flashvars = Hemlock.merge(
      {flashWidth: 1, flashHeight: 1}, args.flashvars);
    args.params = Hemlock.merge(
      {wmode: 'transparent', allowscriptaccess: 'always'}, args.params);

    // Begin embedded HemlockPixel
    Bridge.addHemlockPixelPlaceholder(args.attributes.id, {
      minFlashVersion: args.minFlashVersion
    });
    swfobject.embedSWF(
      args.hemlockPixelSwfURL,
      args.attributes.id,
      args.flashvars.flashWidth  + '',
      args.flashvars.flashHeight + '',
      args.minFlashVersion,
      args.expressInstallSwfURL,
      args.flashvars, args.params, args.attributes,
      function(ev){
        if(ev.success){
          Bridge.onHemlockPixelEmbed({
            id:           ev.id,
            actionScript: ev.ref,
            onSuccess:    args.onSuccess,
            onFailure:    args.onFailure
          });
        }else{
          Hemlock.error('Hemlock.Bridge.create: HemlockPixel embed failed');
        }
      }
    );
  },
  addHemlockPixelPlaceholder: function(id, opts){
    // Inserts a placeholder `<div>` near the top of the page; SWFObject
    // replaces it with HemlockPixel later.
    //
    // `opts`:
    //
    //    {
    //      minFlashVersion: <string>
    //    }

    var placeholder = document.createElement('div'),
        body = document.body,
        firstChild = body.firstElementChild || body.children[0];

    placeholder.id = id;
    placeholder.style.display = 'none';

    if(opts.minFlashVersion){
      placeholder.innerHTML =
        'Hemlock requires Flash ' + opts.minFlashVersion + ' or newer.';
    }

    body.insertBefore(placeholder, firstChild);
  },
  onHemlockPixelEmbed: function(args){
    // `args`:
    //
    //    {
    //      id:           <string>,
    //      actionScript: <HemlockPixel HTML element reference>
    //      onSuccess:    <function>,
    //      [ onFailure:  <function> ]
    //    }

    Hemlock.debug('Hemlock.Bridge.onHemlockPixelEmbed()');

    var Bridge = Hemlock.Bridge,
        hps; // HemlockPixel style

    // Store reference to HemlockPixel
    Bridge.actionScript = args.actionScript;

    // Position HemlockPixel in such a way that it doesn't affect the
    // rest of the layout. Some browsers on some systems require that this
    // is within the visible viewport (e.g., above the fold), so the
    // element is placed at the top. Otherwise, HemlockPixel may download
    // but not actually run.
    hps = Bridge.actionScript.style;
    hps.position = 'absolute';
    hps.left = hps.top = 0;

    // After HemlockPixel has run, it signals JS to continue by triggering
    // the JS event `load.hemlock` on `Hemlock.Bridge`.
    w.jQuery(Bridge).bind('load.hemlock', function(loadedEvent){
      var desc = 'Hemlock.Bridge: HemlockPixel load ',
          hp   = args.actionScript; // HemlockPixel

      // Check that the basic ActionScript callback
      // `Bridge.actionScript.connect` has been exposed. This check could be
      // done with any other callback that was prepared in HemlockPixel.
      if(hp && hp.connect){
        Hemlock.debug(desc + 'succeeded');

        // Normally, this `load.hemlock` handler should be unbound after its
        // first run. However, swfobject sometimes loads HemlockPixel twice;
        // this aborts the first instance's ActionScript, and starts over with
        // the second. The workaround is to leave this handler bound, which
        // lets the second HemlockPixel instance complete initialization.

        if(args.onSuccess){ args.onSuccess(); }
      }else{
        Hemlock.error(desc + 'failed');
        if(args.onFailure){ args.onFailure(); }
      }
    });
  },
  connect: function(args){
    // `args`:
    //
    //    {
    //      onUpdate:     <function>,
    //      timeoutDelay: <integer>
    //    }
    //
    // See also `Hemlock.ConnectionAdapters.HemlockPixel.prototype.connect`.

    var Bridge = Hemlock.Bridge;

    args = Hemlock.merge({}, args);
    if(args.onUpdate){
      Bridge.onConnectionUpdate = args.onUpdate;
    }

    // TODO: Give up after `args.timeoutDelay` seconds
    Bridge.actionScript.connect('window.Hemlock.Bridge.onConnectionUpdate');
  },
  disconnect: function(args){
    // `args`:
    //
    //    {
    //      reason: <string>
    //    }
    //
    // See also
    // `Hemlock.ConnectionAdapters.HemlockPixel.prototype.disconnect`.

    var Bridge = Hemlock.Bridge;

    args = Hemlock.merge({}, args);
    Bridge.actionScript.disconnect();
      // Uses same callback as `Hemlock.Bridge.connect`
  },
  sendString: function(string){
    // Send an arbitrary string to Hemlock AS.
    Hemlock.Bridge.actionScript.sendString(string);
  }
};

}(window));
