//
//  SonicResources.swift
//
//  Copyright © 2016-2019 Apple Inc. All rights reserved.
//

import SPCAudio

/// An enumeration of all the different sounds that can be played.
///
/// - localizationKey: SonicSound
public enum SonicSound: Sound {

    case ahh,
    alien,
    alienGoodbye,
    alienHello,
    alienSirens,
    announcement,
    attack,
    backUp,
    beat,
    beat2,
    bells,
    birds,
    birds1,
    bloops,
    boops,
    boops2,
    beat3,
    brokenGlass,
    canYouHearMe,
    caveBeats,
    chime,
    chord,
    chord2,
    clap,
    clomp,
    comeHere,
    comingTo,
    cowBell,
    creepy,
    creepy2,
    dinnerBell,
    drill,
    droplet2,
    droplet3,
    drums,
    drums2,
    dumDeDum,
    email,
    err,
    eerie,
    eerie1,
    etherial,
    etherial2,
    explosion,
    explosion2,
    flute,
    flute2,
    foundIt,
    galacticChime,
    galacticHorns,
    galacticSonar,
    galacticTelephone,
    gentle,
    getReady,
    glassClink,
    gong,
    gotIt,
    handDrums,
    harp,
    hearMeNow,
    highLow,
    highPitch,
    hits,
    hits2,
    horns,
    horns2,
    horns4,
    jungle,
    labBeats,
    labBeats2,
    layer,
    lightChord,
    lightsUp,
    looking,
    looking3,
    low,
    mission,
    nanana,
    notes,
    notes2,
    offAndAway,
    oneTwoThree,
    piano,
    piano2,
    ping,
    ping2,
    ping3,
    playWithMe,
    pluck,
    powerUp,
    printer,
    ringing,
    shakeItUp,
    shaker,
    sharps,
    shimmer,
    shimmer2,
    shipwreck,
    signals,
    silverware,
    sirens,
    slime,
    sonar2,
    sonar3,
    sonar4,
    sonar5,
    sonarHit,
    sonicSounds,
    sonicSounds2,
    sonicSounds3,
    spaceCarnival,
    spaceGuitar,
    spaceHorns,
    spaceInvaders,
    spaceTrance,
    steelDrums,
    steelDrums2,
    stickDrop,
    symbols,
    symbols2,
    symbols3,
    tapTap,
    taps,
    teslaCoil,
    thinking,
    thinking2,
    thud,
    thud2,
    thudSonar,
    tide,
    tide2,
    tink,
    tinkTink,
    tuneIn,
    twinkles,
    underwaterThud,
    vibrations2,
    vocals,
    waaaa,
    warble,
    weeOoo,
    weirdDinnerBell,
    weirdHits,
    weirdYoga,
    whaleSounds,
    windDown,
    windUp,
    windUp2,
    ratchet,
    yoga,
    yoga2,
    yoga3,
    zip
}

/// Plays the given sound. Optionally, specify a volume from `0` (silent) to `100` (loudest), with `80` being the default.
///
/// - Parameter sonicSound: The sound to be played.
/// - Parameter volume: The volume at which the sound is to be played (ranging from `0` to `100`).
///
/// - localizationKey: playSound(sonicSound:volume:)
public func playSound(_ sonicSound: SonicSound, volume: Int = 80) {
    playSound(sonicSound.rawValue, volume: volume)
}

extension Loop {
    /// Creates a Loop with the specified sound and `loopFireHandler`.
    ///
    /// - Parameter sound: The sound played by the Loop.
    /// - Parameter loopFireHandler: The function that gets called each time the loop starts playing the associated sound.
    ///
    /// - localizationKey: Loop(sonicSound:loopFireHandler:)
    public convenience init(sound: SonicSound, loopFireHandler: (()->Void)? = nil) {
        self.init(sound: sound.rawValue, loopFireHandler: loopFireHandler)
    }
}

/// An enumeration of the different types of Music you can play.
///
/// - localizationKey: SonicMusic
public enum SonicMusic: Music {

    case cave,
    turtle,
    underwater,
    lab
}

/// Plays the given music. Optionally, specify a volume from `0` (silent) to `100` (loudest), with `75` being the default.
///
/// - Parameter sonicMusic: The music to be played.
/// - Parameter volume: The volume at which the music is to be played (ranging from `0` to `100`).
///
/// - localizationKey: playMusic(sonicMusic:volume:)
public func playMusic(_ sonicMusic: SonicMusic, volume: Int = 75) {
    playMusic(sonicMusic.rawValue, volume: volume)
}
