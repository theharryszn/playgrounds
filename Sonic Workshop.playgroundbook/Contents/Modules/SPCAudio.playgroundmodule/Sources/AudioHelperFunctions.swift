//
//  AudioHelperFunctions.swift
//  
//  Copyright © 2020 Apple Inc. All rights reserved.
//

import Foundation
import SPCCore
import SPCIPC

let speech = Speech()

/// Speaks the given text.
///
/// - Parameter text: The text to be spoken.
/// - Parameter voice: The voice in which to speak the text. Leave out to use the default voice.
///
/// - localizationKey: speak(_:voice:)
public func speak(_ text: String, voice: SpeechVoice = SpeechVoice()) {
    speech.speak(text, voice: voice)
}

/// Stops any speech that’s currently being spoken.
///
/// - localizationKey: stopSpeaking()
public func stopSpeaking() {
    speech.stopSpeaking()
}

/// Plays the given sound. Optionally, specify a volume from `0` (silent) to `100` (loudest), with `80` being the default.
///
/// - Parameter sound: The sound to be played.
/// - Parameter volume: The volume at which the sound is to be played (ranging from `0` to `100`).
///
/// - localizationKey: playSound(_:volume:)
public func playSound(_ sound: Sound, volume: Int = 80) {
    if !AudioSession.current.isPlaybackBlocked && audioController.isSoundEffectsAudioEnabled {
        AudioProxy().playSound(sound, volume: volume)
    }
}

/// Plays the given music. Optionally, specify a volume from `0` (silent) to `100` (loudest), with `75` being the default.
///
/// - Parameter music: The music to be played.
/// - Parameter volume: The volume at which the music is to be played (ranging from `0` to `100`).
///
/// - localizationKey: playMusic(_:volume:)
public func playMusic(_ music: Music, volume: Int = 75) {
    AudioProxy().playMusic(music, volume: volume)
}

/// Plays a note with the given instrument. Optionally, specify a volume from `0` (silent) to `100` (loudest), with `75` being the default.
///
/// - Parameter instrumentKind: The kind of instrument with which to play the note.
/// - Parameter note: The note to be played (ranging from `0` to `23`).
/// - Parameter volume: The volume at which the note is played (ranging from `0` to `100`).
///
/// - Important: Each instrument has a different range of notes available:
///  * **electricGuitar**: `0...15`
///  * **bassGuitar**: `0...14`
///  * **warmBells, sevenSynth,  bassSynth, crystalSynth**: `0...19`
///  * **piano**: `0...23`
/// - localizationKey: playInstrument(_:note:volume:)
public func playInstrument(_ instrumentKind: Instrument.Kind, note: Double, volume: Double = 75) {
    if audioController.isSoundEffectsAudioEnabled {
        AudioProxy().playInstrument(instrumentKind, note: note, volume: Int(volume))
    }
}
