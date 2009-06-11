package com.mintdigital.hemlock.models{
    import com.mintdigital.hemlock.data.JID;
    import com.mintdigital.hemlock.models.User;

    public dynamic class Roster extends Array {
        
        public function Roster() {
            super();
        }
        
        public function toString():String{
            var string:String = '[Roster : ';
            var userStrings:Array /* of Strings */ = [];
            for each(var user:User in this){
                userStrings.push(user.toString());
            }
            string += userStrings.join(', ') + ']';
            return string;
        }
        
        public function find(jid:*):User {
            // `jid` is a JID or String.
            
            return this.filter(function(item:*, i:int, array:Array):Boolean {
                return item.jid.eq(jid);
            })[0];
        }
        
        AS3 override function push(...args):uint {
            return (super.push.apply(this, args.filter(function(item:*, index:int, array:Array):Boolean {
                return !this.contains(item);
            }, this)));
        }
        
        public function contains(user:*):Boolean {
            // `user` is a User or JID.
            
            return this.some(function(item:*, index:int, array:Array):Boolean {
                if(user is User){
                    return item.jid.eq(user.jid);
                }else if(user is JID){
                    return item.jid.eq(user);
                }
                return false;
            });
        }
        
        public function remove(user:User):User {
            var rosterUser:User = null;
            for(var i:int = 0; i < this.length; i++) {
                if(this[i].jid.eq(user.jid)){
                    rosterUser = this[i];
                    this.splice(i, 1);
                }
            }
            return rosterUser;
        }
        
        public function next(jid:*):User{
            // Finds `jid` in the roster, and returns the user immediately
            // following it. If `jid` is last in the roster, returns the first
            // user instead. For use in determining whose game turn is next.
            
            var nextUser:User;
            for(var i:uint = 0, max:uint = this.length; i < max; i++){
                if(jid.eq(this[i].jid)){
                    nextUser = this[i+1] || this[0];
                    break;
                }
            }
            return nextUser;
        }
        
    }
}