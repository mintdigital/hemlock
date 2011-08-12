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

if(!Hemlock && w.console && w.console.error){
  return w.console.error('Error loading Hemlock (hemlock/handler.js)');
}

is = Hemlock.is;



Hemlock.Handler = function(args){
  // `Hemlock.Handler` is private. Inspired by Strophe.

  // `args`:
  //
  //    {
  //      callback: <function>, // Arguments:
  //                            // - `elem` (XMLElement)
  //                            // - `data` (object)
  //      name:     <string>,   // XMPP stanza tag name
  //      type:     <string>,   // XMPP stanza `type` attribute
  //      id:       <string>,   // XMPP stanza `id` attribute
  //      from:     <string>,   // XMPP stanza `from` attribute
  //      dataType: <string>    // Custom string, e.g., 'gameMove'
  //    }
  //
  // If the arguments `name`, `type`, `id`, `from`, and `dataType` all match
  // a given element, then the element is said to match this handler. These
  // are strict equality comparisons. For more complex comparisons, each can
  // instead be defined as a boolean function, but be wary of performance
  // implications.

  var setAttr = 'setAttribute';

  this.callback = function (data) {
    args.callback(data);
    return true; // To discard handler after one use, `return false`.
  };

  this[setAttr]('name',     args.name    );
  this[setAttr]('type',     args.type    );
  this[setAttr]('id',       args.id      );
  this[setAttr]('from',     args.from    );
  this[setAttr]('dataType', args.dataType);
};

pro = Hemlock.Handler.prototype;



/*** Instance methods ***/

pro.setAttribute = function(attributeName, value){
  // XML is lowercased deeper in the stack, so store strings as
  // lowercase for faster case-insensitive comparison.

  this[attributeName] =
    value && is.String(value) ? value.toLowerCase() : value;
};

pro.matchesElement = function(elem, botUsername){
  if(!elem.tagName){ return false; }

  var name  = elem.tagName.toLowerCase(),
      type  = Hemlock.elemAttr(elem, 'type'),
      id    = Hemlock.elemAttr(elem, 'id'  ),
      from  = Hemlock.elemAttr(elem, 'from'),
      idParts, dataType;

  function isFromBot(){
    return !botUsername || botUsername === Strophe.getResourceFromJid(from);
  }

  function handlerAttrMatchesElemAttr(handlerAttr, elemAttr){
    return (
      !handlerAttr ||                 // Handler has no condition

      handlerAttr === elemAttr ||     // Handler's condition matches element

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

  return  handlerAttrMatchesElemAttr(this.name,     name    ) &&
          handlerAttrMatchesElemAttr(this.type,     type    ) &&
          handlerAttrMatchesElemAttr(this.id,       id      ) &&
          handlerAttrMatchesElemAttr(this.from,     from    ) &&
          handlerAttrMatchesElemAttr(this.dataType, dataType);
};

pro.matchesArgs = function(args){
  Hemlock.objectValuesToLowerCase(
    args, 'name0type0id0from0dataType'.split(0));

  var name     = args.name,
      type     = args.type,
      id       = args.id,
      from     = args.from,
      dataType = args.dataType;

  //      No args cond:   || Args condition matches handler:
  return  (!args.name     || args.name      === this.name    ) &&
          (!args.type     || args.type      === this.type    ) &&
          (!args.id       || args.id        === this.id      ) &&
          (!args.from     || args.from      === this.from    ) &&
          (!args.dataType || args.dataType  === this.dataType);
};

}(window));
