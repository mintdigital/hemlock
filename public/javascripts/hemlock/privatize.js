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

// Run this after setting up all Hemlock modules in separate files; it
// whitelists anything that should be public. Each module should still have
// its own private references to all Hemlock modules and properties.

/*jslint  browser:  true,
          eqeqeq:   true,
          immed:    false,
          newcap:   true,
          nomen:    false,
          onevar:   true,
          plusplus: false,
          undef:    true,
          white:    false */
/*global  window, Hemlock */

(function(w){
  var H = w.Hemlock,
      c = w.console;

  if(!H && c && c.error){
    return c.error('Error loading Hemlock (hemlock/privatize.js)');
  }

  // Whitelist public objects. These must be references (e.g., to functions,
  // plain objects), not copies (e.g., of strings, booleans).
  w.Hemlock = {
    getDebugMode:       H.getDebugMode,
    setDebugMode:       H.setDebugMode,
    debug:              H.debug,
    error:              H.error,
    elemAttr:           H.elemAttr,
    merge:              H.merge,
    getUniqueID:        H.getUniqueID,
    ConnectionAdapters: H.ConnectionAdapters,
    Support:            H.Support,
    Bridge:             H.Bridge
  };
}(window));
