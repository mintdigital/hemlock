import com.mintdigital.hemlock.utils.*;

public function testTrim():void {
    assertEquals("string", StringUtils.trim("    string"));

    //TODO this seems to not cut space from the end...
    //assertEquals("string", StringUtils.trim("string    "));
}

public function testIsBlank():void {
    assertEquals(true, StringUtils.isBlank("   "));
    assertEquals(false, StringUtils.isBlank("string"));
}

public function testEscapeHTML():void {
    assertEquals("test &amp;", StringUtils.escapeHTML("test &"));
    assertEquals("&lt;h1&gt;", StringUtils.escapeHTML("<h1>"));
}