// Here, set up any assets for use across all skins. `include` this file in
// all custom skins for this app.

// NOTE: This is an inclusion file, not a superclass, because ActionScript 3
// doesn't allow subclasses to inherit static properties/methods.

import flash.media.SoundChannel;
import flash.media.SoundTransform;



//--------------------------------------
//  Sounds
//--------------------------------------

[Embed(source="assets.swf", symbol="soundChatMessage")] public static const SoundChatMessage:Class;
[Embed(source="assets.swf", symbol="soundSignIn")]      public static const SoundSignIn:Class;
[Embed(source="assets.swf", symbol="soundSignOut")]     public static const SoundSignOut:Class;
[Embed(source="assets.swf", symbol="soundStartGame")]   public static const SoundStartGame:Class;
[Embed(source="assets.swf", symbol="soundWin")]         public static const SoundWin:Class;

private static var primarySoundTransform:SoundTransform = new SoundTransform();

public static function playSound(soundClassName:String):void{
    var soundClass:Class;
    switch(soundClassName){
        case 'chatMessage': soundClass = SoundChatMessage;  break;
        case 'startGame':   soundClass = SoundStartGame;    break;
        case 'signIn':      soundClass = SoundSignIn;       break;
        case 'signOut':     soundClass = SoundSignOut;      break;
        case 'win':         soundClass = SoundWin;          break;
    }

    if(soundClass){
        var channel:SoundChannel = (new soundClass).play();
        channel.soundTransform = primarySoundTransform;
    }
}

public static function setSoundVolume(volume:Number):void{
    // `volume` ranges from 0.0 (mute) to 1.0 (full volume), inclusive.
    
    primarySoundTransform.volume = volume;
}
