//
//  Loop.swift
//  
//  Copyright © 2020 Apple Inc. All rights reserved.
//


import Foundation
import AVFoundation


/// A loop is a repeating sound that can be toggled on and off.
///
/// Example usage:
/// ```
/// let loop = Loop(sound: .labBeats2)
/// loop.toggle()
/// ```
/// - localizationKey: Loop
public class Loop {
    
    var timer: Timer = Timer()
    var playing: Bool = false
    
    /// The length of the loop sound, in seconds.
    ///
    /// - localizationKey: Loop.length
    public var length: Double
    
    /// The repeating sound played by the loop.
    ///
    /// - localizationKey: Loop.sound
    public var sound: Sound
    
    /// The handler to be run each time the loop starts playing the associated sound.
    ///
    /// - localizationKey: Loop.loopFireHandler
    public var loopFireHandler: (()->Void)?

    
    /// Creates a loop with the given sound.
    ///
    /// - Parameter sound: The sound played by the loop.
    /// - Parameter loopFireHandler: The function that gets called each time the loop starts playing the associated sound.
    ///
    /// - localizationKey: Loop(sound:loopFireHandler:)
    public init(sound: Sound, loopFireHandler: (()->Void)? = nil) {
        self.sound = sound
        self.length = 0
        self.loopFireHandler = loopFireHandler
        
        if let soundUrl = sound.url {
            do {
                let audioPlayer = try AVAudioPlayer(contentsOf: soundUrl)
                self.length = audioPlayer.duration
            } catch {}
        }
    }

    /// Toggles the loop to start or stop playing.
    ///
    /// - localizationKey: Loop.toggle()
    public func toggle() {
        if playing {
            playing = false
            timer.invalidate()
        } else {
            playing = true
            
            let timerBlock: ((Timer) -> Void) = { timer in
                self.loopFireHandler?()
                
                playSound(self.sound, volume: 100)
            }
            
            timer = Timer.scheduledTimer(withTimeInterval: length, repeats: true, block: timerBlock)
            
            timerBlock(timer) // call immediately
        }
    }
}
