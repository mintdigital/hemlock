import com.mintdigital.hemlock.models.GameCard;
import com.mintdigital.hemlock.models.GameCardDeck;

private var deck:GameCardDeck;

override public function setUp():void{
    deck = new GameCardDeck();
    // deck.populate();
    // deck.shuffle();
}

public function testShouldPutTopCard():void{
    var cards:Array = [
        new GameCard('card1', 'value1'),
        new GameCard('card2', 'value2'),
        new GameCard('card3', 'value3')
    ];
    deck.putTopCard(cards[0]);
    deck.putTopCard(cards[1]);
    deck.putTopCard(cards[2]);
    
    assertEquals(deck.cards.toString(), cards.reverse().toString());
}

public function testShouldPutTopCards():void{
    var cards:Array = [
        new GameCard('card1', 'value1'),
        new GameCard('card2', 'value2'),
        new GameCard('card3', 'value3')
    ];
    deck.putTopCards(cards);
    
    assertEquals(deck.cards.toString(), cards.toString());
}

public function testShouldPutBottomCards():void{
    var cards:Array = [
        new GameCard('card1', 'value1'),
        new GameCard('card2', 'value2')
    ];
    deck.putTopCards(cards);
    var card3:GameCard = new GameCard('card3', 'value3');
    deck.putBottomCards([card3]);
    
    assertEquals([cards[0], cards[1], card3].toString(), deck.cards.toString());
}

public function testShouldGetTopCard():void{
    var cards:Array = [
        new GameCard('card1', 'value1'),
        new GameCard('card2', 'value2'),
        new GameCard('card3', 'value3')
    ];
    deck.putTopCards(cards);
    var topCard:GameCard = deck.getTopCard();
    
    assertEquals(2, deck.numCards);
    assertEquals(cards[0], topCard);
    assertEquals([cards[1], cards[2]].toString(), deck.cards.toString());
}

public function testShouldGetTopCards():void{
    var cards:Array = [
        new GameCard('card1', 'value1'),
        new GameCard('card2', 'value2'),
        new GameCard('card3', 'value3')
    ];
    deck.putTopCards(cards);
    var topCards:Array /* of GameCards */ = deck.getTopCards(2);
    
    assertEquals(1, deck.numCards);
    assertEquals([cards[0], cards[1]].toString(), topCards.toString());
    assertEquals([cards[2]].toString(), deck.cards.toString());
}

// TODO: Add more complete tests
