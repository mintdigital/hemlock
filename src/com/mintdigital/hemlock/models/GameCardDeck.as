package com.mintdigital.hemlock.models{
    import com.mintdigital.hemlock.data.JID;
    import com.mintdigital.hemlock.utils.HashUtils;
    import com.mintdigital.hemlock.Logger;
    
    public class GameCardDeck{
        protected var _cards:Array /* of GameCards */ = [];
        protected var _numCards:uint;
        
        // NOTE: Beware sending _cards to a room unencrypted, or else the
        // packets containing the card order can be sniffed, and someone can
        // cheat.
        
        // TODO: Add encryption functions to GameCard/GameCardDeck
        
        public function GameCardDeck(options:Object = null){
            options = HashUtils.merge({
                populate: false
            }, options);
            
            if(options.populate){ populate(); }
        }
        
        public function toString(options:Object = null):String{
            options = HashUtils.merge({
                showValues: true
            }, options);
            
            var string:String = '[GameCardDeck : ';
            var cardStrings:Array /* of Strings */ = [];
            for each(var card:GameCard in _cards){
                cardStrings.push(card.toString(options));
            }
            string += cardStrings.join(' | ') + ']';
            return string;
        }
        
        public function populate():void{
            // TODO: Set up as a default card pack instead; see TopTrumps
            
            // Populate _cards with 52 standard cards. Override this to create
            // subclasses with custom decks.
            
            var suits:Object = {
                s:  'Spades',
                h:  'Hearts',
                c:  'Clubs',
                d:  'Diamonds'
            };
            var ranks:Object = {
                A:  'Ace',
                2:  'Two',
                3:  'Three',
                4:  'Four',
                5:  'Five',
                6:  'Six',
                7:  'Seven',
                8:  'Eight',
                9:  'Nine',
                10: 'Ten',
                J:  'Jack',
                Q:  'Queen',
                K:  'King'
            };
            
            for(var suitKey:String in suits){
                for(var rankKey:String in ranks){
                    var name:String = rankKey + suitKey;
                    var value:String = ranks[rankKey] + ' of ' + suits[suitKey];
                    putTopCard(new GameCard(name, value));
                }
            }
            
            _numCards = _cards.length;
        }
        
        public function shuffle():void{
            // Shuffles _cards in place.
            
            if(numCards < 2){ return; }
            
            // TODO: Optimize
            for(var i:uint = 0; i < numCards; i++){
                var i2:uint = Math.floor(Math.random() * (_cards.length - 1));
                var tmpCard:GameCard = _cards[i];
                _cards[i] = _cards[i2];
                _cards[i2] = tmpCard;
            }
        }
        
        public function getTopCard():GameCard{
            var card:GameCard = _cards.shift();
            _numCards = Math.max(0, _cards.length);
            return card;
        }
        
        public function getTopCards(numCards:uint):Array /* of GameCards */{
            var cards:Array /* of GameCards */ = _cards.splice(0, numCards);
            _numCards -= cards.length;
            return cards;
        }
        
        // TODO: Implement getBottomCards(numCards:uint)
        
        public function putTopCard(card:GameCard):void{
            _cards.unshift(card);
            _numCards++;
        }
        
        public function putTopCards(cards:Array /* of GameCards */):void{
            _cards = cards.concat(_cards);
            _numCards += cards.length;
        }
        
        // TODO: Implement putBottomCard(card:GameCard)
        
        public function putBottomCards(cards:Array /* of GameCards */):void{
            _cards = _cards.concat(cards);
            _numCards += cards.length;
        }
        
        public function deal(numCardsToDeal:uint):Array{
            var hand:Array = [];
            for(var i:uint = 0; i < numCardsToDeal; i++){
                hand.push(getTopCard());
            }
            return hand;
        }
        
        public function setOwner(owner:JID):void{
            for each(var card:GameCard in _cards){
                card.owner = owner;
            }
        }
        
        
        
        //--------------------------------------
        //  Internal helpers
        //--------------------------------------
        
        // ...
        
        
        //--------------------------------------
        //  Properties
        //--------------------------------------
        
        public function get cards():Array /* of GameCards */{
            return _cards;
        }
        
        public function get numCards():uint{ return _numCards; }
        
    }
}
