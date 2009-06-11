public function testCreating():void{
    var user:User = new User(123);
    
    assertEquals(null, user.nickname);
    assertEquals(null, user.status)
    assertEquals(123, user.jid);
    
    var user2:User = new User(123, "bob", "active");
    assertEquals("bob", user2.nickname);
    assertEquals(123, user2.jid);
    assertEquals("active", user2.status);
    
}

public function testNickname():void{
    var user:User = new User(123);
    
    assertEquals(null, user.nickname);
    
    user.nickname=("bob");
    assertEquals("bob", user.nickname);
}

public function testStatus():void{
    var user:User = new User(123);
    
    assertEquals(null, user.status);
    
    user.status=("active");
    assertEquals("active", user.status);
    
    user.status=("gone")
    assertEquals("gone", user.status)
}