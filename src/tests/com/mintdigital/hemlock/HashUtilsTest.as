import com.mintdigital.hemlock.utils.*;

private var testObject:Object;
private var testObject2:Object;
private var testObject3:Object;

public override function setUp():void {
    testObject  = { foo: "bar"};
    testObject2 = { foo: "bar", x: "y"};
    testObject3 = {};
}

public function testToString():void {
    assertEquals('[Hash : foo = bar]', HashUtils.toString(testObject));

    //This doesn't return in a set order
    //assertEquals('[Hash : x = y | foo = bar]', HashUtils.toString(testObject2));
}

public function testMerge():void {
    assertEquals(testObject, HashUtils.merge(testObject))
    
    var testObject3:Object = { foo: "baz"};
    
    assertEquals("baz", HashUtils.merge(testObject, testObject3)['foo']);
    assertEquals(testObject, testObject);
}

public function testKeys():void {
    assertEquals("foo", HashUtils.keys(testObject)[0]);
    assertEquals(testObject, testObject);
}

public function testValues():void {
    assertEquals("bar", HashUtils.values(testObject)[0]);
    assertEquals(testObject, testObject);
}

public function testLength():void{
    assertEquals(1, HashUtils.length(testObject));
    assertEquals(2, HashUtils.length(testObject2));
    assertEquals(0, HashUtils.length(testObject3));
    
    assertEquals(testObject, testObject);
    assertEquals(testObject2, testObject2);
    assertEquals(testObject3, testObject3);
}
