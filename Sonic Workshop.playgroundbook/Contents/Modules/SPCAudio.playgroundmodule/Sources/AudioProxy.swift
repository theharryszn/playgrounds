//
//  AudioProxy.swift
//  
//  Copyright © 2020 Apple Inc. All rights reserved.
//

import Foundation
import SPCCore
import SPCIPC

public protocol AudioProxyProtocol {
    func playSound(_ sound: Sound, volume: Int)
    func playMusic(_ music: Music, volume: Int)
    func playInstrument(_ instrument: Instrument.Kind, note: Double, volume: Int)
}

public protocol AudioUserCodeProxyProtocol {
    func audioControllerSettingsDidChange()
}

public class AudioProxy: AudioProxyProtocol, Messagable, LiveViewRegistering {
    static var receivers = [AudioProxyProtocol]()
    
    public static func registerToRecieveDecodedMessage(as object: AudioProxyProtocol) {
        receivers.append(object)
    }
    
    public static func liveViewRegistration() {
        Message.registerToReceiveData(as: self)
    }
    
    public init() {}
    
    public func playSound(_ sound: Sound, volume: Int) {
        Message.send(PlaySound(sound: sound, volume: volume), payload: type(of: PlaySound.self), proxy: type(of: self))
    }
    
    public func playMusic(_ music: Music, volume: Int) {
        Message.send(PlayMusic(music: music, volume: volume), payload: type(of: PlayMusic.self), proxy: type(of: self))
    }
    
    public func playInstrument(_ instrument: Instrument.Kind, note: Double, volume: Int) {
        Message.send(PlayInstrument(instrument: instrument, volume: volume, note: note), payload: type(of: PlayInstrument.self), proxy: type(of: self))
    }
    
    enum MessageType: String {
        case PlaySound
        case PlayMusic
        case PlayInstrument
    }
    
    public static func decode(data: Data, withId id: String) {
        if let type = MessageType(rawValue: id) {
            switch type {
            case .PlaySound:
                if let decoded = try? JSONDecoder().decode(PlaySound.self, from: data) {
                    receivers.forEach({$0.playSound(decoded.sound, volume: decoded.volume)})
                }
            case .PlayMusic:
                if let decoded = try? JSONDecoder().decode(PlayMusic.self, from: data) {
                    receivers.forEach({$0.playMusic(decoded.music, volume: decoded.volume)})
                }
            case .PlayInstrument:
                if let decoded = try? JSONDecoder().decode(PlayInstrument.self, from: data) {
                    receivers.forEach({$0.playInstrument(decoded.instrument, note: decoded.note, volume: decoded.volume)})
                }
            }
        }
    }
}

public class AudioUserCodeProxy: AudioUserCodeProxyProtocol, Messagable {
    static var receivers = [AudioUserCodeProxyProtocol]()
    
    static func registerToRecieveDecodedMessage(as object: AudioUserCodeProxyProtocol) {
        receivers.append(object)
        Message.registerToReceiveData(as: self)
    }
    
    public init() {}
    
    enum MessageType: String {
        case AudioControllerSettingsDidChange
    }
    
    public func audioControllerSettingsDidChange() {
        Message.send(AudioControllerSettingsDidChange(), payload: type(of: AudioControllerSettingsDidChange.self), proxy: type(of: self))
    }
    
    public static func decode(data: Data, withId id: String) {
        if let type = MessageType.init(rawValue: id) {
            switch type {
            case .AudioControllerSettingsDidChange:
                if let _ = try? JSONDecoder().decode(AudioControllerSettingsDidChange.self, from: data) {
                    receivers.forEach({$0.audioControllerSettingsDidChange()})
                }
            }
        }
    }
}

struct PlaySound: Sendable {
    var sound: Sound
    var volume: Int
}

struct PlayMusic: Sendable {
    var music: Music
    var volume: Int
}

struct PlayInstrument: Sendable {
    var instrument: Instrument.Kind
    var volume: Int
    var note: Double
}

struct AudioControllerSettingsDidChange: Sendable {}

