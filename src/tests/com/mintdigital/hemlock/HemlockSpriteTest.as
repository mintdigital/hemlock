import com.mintdigital.hemlock.display.*;

private var sprite:HemlockSprite;

public override function setUp():void {
    sprite = new HemlockSprite();
}

public function testCreating():void {
    assertEquals(0, sprite.x);
    assertEquals(0, sprite.y);
    assertEquals(0, sprite.height);
    
    sprite = new HemlockSprite({x: 100, y: 100, visible: false});
    
    assertEquals(100, sprite.x);
    assertEquals(100, sprite.y);
    assertEquals(false, sprite.visible);
}

public function testSetPosition(): void{
    sprite.setPosition(200, 100);
    
    assertEquals(200, sprite.x);
    assertEquals(100, sprite.y);
}

public function testSetSize():void {
/*    sprite.setSize(50, 100);
    
    assertEquals(50, sprite.width);
    assertEquals(100, sprite.height);*/
}

public function testShow():void {
    var sprite2:HemlockSprite = new HemlockSprite({visible: false});
    sprite2.show();
    
    assertEquals(true, sprite.visible);
}

public function testHide():void {
    sprite.hide();
    
    assertEquals(false, sprite.visible);
    
}

public function testToggle():void {
    assertEquals(true, sprite.visible);
    sprite.toggle();
    assertEquals(false, sprite.visible);
    sprite.toggle();
    assertEquals(true, sprite.visible);
}