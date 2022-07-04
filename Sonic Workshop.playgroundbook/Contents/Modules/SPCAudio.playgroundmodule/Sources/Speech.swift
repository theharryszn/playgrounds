//
//  Speech.swift
//  
//  Copyright © 2020 Apple Inc. All rights reserved.
//

import AVFoundation
import SPCCore

/// An enumeration of the available Speech accents, including: American, Australian, British, Irish, and South African.
///
/// - localizationKey: SpeechAccent
public enum SpeechAccent {
    
    case `default`, american, australian, british, irish, southAfrican
    
    var language: String {
        switch self {
        case .american:
            return "en-US"
        case .australian:
            return "en-AU"
        case .british:
            return "en-GB"
        case .irish:
            return "en-IE"
        case .southAfrican:
            return "en-ZA"
        default:
            return ""
        }
    }
}

/// A struct that sets the speed, pitch, and accent of Speech.
///
/// - localizationKey: SpeechVoice
public struct SpeechVoice {
    
    /// The speed at which Speech is spoken.
    ///
    /// - localizationKey: SpeechVoice.speed
    public var speed: Int
    
    /// The pitch at which Speech is spoken.
    ///
    /// - localizationKey: SpeechVoice.pitch
    public var pitch: Int
    
    /// The accent in which Speech is spoken.
    ///
    /// - localizationKey: SpeechVoice.accent
    public var accent: SpeechAccent
    
    static var defaultSpeed: Int { return 20 }
    static var defaultPitch: Int { return 50 }
    
    /// Create a Speech voice with a default speed, pitch, and accent.
    ///
    /// - localizationKey: SpeechVoice()
    public init() {
        self.speed = SpeechVoice.defaultSpeed
        self.pitch = SpeechVoice.defaultPitch
        self.accent = .default
    }
    
    /// Create a Speech voice with a given accent.
    ///
    /// - Parameter accent: The accent to use for the voice.
    ///
    /// - localizationKey: SpeechVoice(accent:)
    public init(accent: SpeechAccent) {
        self.speed = SpeechVoice.defaultSpeed
        self.pitch = SpeechVoice.defaultPitch
        self.accent = accent
    }
}

/// A Speech object, used to synthesize speech from text.
///
/// - localizationKey: Speech
public class Speech {
    
    /// Create a Speech instance.
    ///
    /// - localizationKey: Speech()
    public init() {
        
    }
    
    // MARK: Properties
    private var _defaultVolume = ClampedInteger(clampedUserValueWithDefaultOf: 50)
    
    /// The default volume of Speech.
    ///
    /// - localizationKey: Speech.defaultVolume
    public var defaultVolume: Int {
        get { return _defaultVolume.clamped }
        set { _defaultVolume.clamped = newValue }
    }
    
    var normalizedVolume: CGFloat {
        return CGFloat(defaultVolume) / CGFloat(Constants.maxUserValue)
    }
    

    private var _defaultSpeed = ClampedInteger(clampedUserValueWithDefaultOf: 30)
    
    /// The default speed of Speech.
    ///
    /// - localizationKey: Speech.defaultSpeed
    public var defaultSpeed: Int {
        get { return _defaultSpeed.clamped }
        set { _defaultSpeed.clamped = newValue }
    }
    
    var normalizedSpeed: CGFloat {
        return CGFloat(defaultSpeed) / CGFloat(Constants.maxUserValue)
    }
    
    private var _defaultPitch = ClampedInteger(clampedUserValueWithDefaultOf: 33)
    
    /// The default pitch of Speech.
    ///
    /// - localizationKey: Speech.defaultPitch
    public var defaultPitch: Int {
        get { return _defaultPitch.clamped }
        set { _defaultPitch.clamped = newValue }
    }
    
    var normalizedPitch: CGFloat {
        return CGFloat(defaultPitch) / CGFloat(Constants.maxUserValue)
    }
    
    
    // MARK: Private Properties
    
    private var speechWords: [String] = []
    
    private var speechSynthesizer = AVSpeechSynthesizer()
    
    // MARK: Initializers
    
    /// Speaks the given text using an optional voice.
    ///
    /// - Parameter text: The text to speak.
    /// - Parameter voice: The voice in which to speak the text; omit to use the default voice.
    ///
    /// - localizationKey: Speech.speak(_:voice:)
    public func speak(_ text: String, voice: SpeechVoice = SpeechVoice()) {

        defaultSpeed = voice.speed
        defaultPitch = voice.pitch

        let volume = SpeechTweak.tweak(normalizedValue: normalizedVolume, forType: .volume)
        let rate = SpeechTweak.tweak(normalizedValue: normalizedSpeed, forType: .speed)
        let pitchMultiplier = SpeechTweak.tweak(normalizedValue: normalizedPitch, forType: .pitch)
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = rate
        utterance.volume = volume
        utterance.pitchMultiplier = pitchMultiplier
        
        var languageID: String? = nil
        if let langugageCode = Locale.current.languageCode, let regionCode = Locale.current.regionCode {
            languageID = langugageCode + "-" + regionCode
        }
        utterance.voice = AVSpeechSynthesisVoice(language: languageID)

        #if targetEnvironment(macCatalyst)
            // rdar://problem/56199767
            speechSynthesizer = AVSpeechSynthesizer()
        #endif
        speechSynthesizer.speak(utterance)
    }
    
    /// Stops any speech that’s currently being spoken.
    ///
    /// - localizationKey: Speech.stopSpeaking()
    public func stopSpeaking() {
        speechSynthesizer.stopSpeaking(at: .word)
    }
}
