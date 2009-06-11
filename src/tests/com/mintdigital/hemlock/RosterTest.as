import com.mintdigital.hemlock.data.JID;

private var user:User;
private var user2:User;
private var roster:Roster;

public override function setUp(): void{
    user = new User(123);  
    user2 = new User(124);
    
    roster = new Roster;
}

public function testPush():void {  
    assertEquals(0, roster.length);
      
    roster.push(user);
    
    assertEquals(1, roster.length);
    assertEquals(user, roster[0]);
    
    roster.push(user2);
    
    assertEquals(2, roster.length);
    assertEquals(user2, roster[1]);
}

public function testRemove():void {
    roster.push(user);
    
    assertEquals(1, roster.length)
    assertEquals(user, roster[0]);
    
    roster.remove(user);
    assertEquals(null, roster[0]);
    assertEquals(0, roster.length);

    roster.push(user);
    roster.push(user2);
    
    roster.remove(user);
    
    assertEquals(1, roster.length);
    assertEquals(user2, roster[0]);
}

public function testContains():void {
    roster.push(user);
    
    assertEquals(true, roster.contains(user));
    assertEquals(false, roster.contains(user2));
}

public function testFind():void {
    roster.push(user);
    
    assertEquals(user, roster.find(new JID("123")));
    assertEquals(null, roster.find(new JID("124")));
}