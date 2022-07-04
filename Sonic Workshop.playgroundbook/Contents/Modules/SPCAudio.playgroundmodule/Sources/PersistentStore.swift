//
//  PersistentStore.swift
//  
//  Copyright © 2020 Apple Inc. All rights reserved.
//

import PlaygroundSupport
import Foundation
import SPCCore

/// The name of the current page being presented.
/// Must be manually set in the pages auxiliary sources.
public var pageIdentifier = ""

enum PersistentStore {
    enum Key {
        static let backgroundAudio = "BackgroundAudioKey"
        static let soundEffectsAudio = "SoundEffectsAudioKey"
    }
    
    static let store = PlaygroundKeyValueStore.current
    
    // MARK: Properties
    
    static var isBackgroundAudioEnabled: Bool {
        get {
            let enabled = store.boolean(forKey: Key.backgroundAudio)
            return enabled ?? true
        }
        set {
            store[Key.backgroundAudio] = .boolean(newValue)
        }
    }
    
    static var isSoundEffectsEnabled: Bool {
        get {
            let enabled = store.boolean(forKey: Key.soundEffectsAudio)
            return enabled ?? true
        }
        set {
            store[Key.soundEffectsAudio] = .boolean(newValue)
        }
    }
    
    // MARK: Derived Properties
    
    static var isAllAudioEnabled: Bool {
        return PersistentStore.isSoundEffectsEnabled && PersistentStore.isBackgroundAudioEnabled
    }
}
