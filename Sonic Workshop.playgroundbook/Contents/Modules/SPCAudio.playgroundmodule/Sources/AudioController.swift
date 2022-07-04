//
//  AudioController.swift
//  
//  Copyright © 2020 Apple Inc. All rights reserved.
//
import Foundation
import AVFoundation
import PlaygroundSupport
import SPCLiveView
import SPCCore

public var audioController = AudioController()

@objc
public class AudioController: NSObject {
    
    public var backgroundAudioMusic: Music? = nil
    
    public var isBackgroundAudioLoopPlaying: Bool {
        guard let audioPlayer = backgroundAudioPlayer else { return false }
        return audioPlayer.isPlaying
    }
    
    var activeAudioPlayers = Set<AVAudioPlayer>()
    
    private var backgroundAudioPlayer: AVAudioPlayer?
    
    public var isBackgroundAudioEnabled: Bool {
        get {
            return PersistentStore.isBackgroundAudioEnabled
        }
        set {
            PersistentStore.isBackgroundAudioEnabled = newValue
            
            if !newValue {
                stopAllPlayers()
            } else {
                // Resume (actually restart) background audio if it had been playing.
                if let backgroundMusic = backgroundAudioMusic {
                    playBackgroundAudioLoop(backgroundMusic)
                }
            }
            
            AudioUserCodeProxy().audioControllerSettingsDidChange()
        }
    }
    
    public var isSoundEffectsAudioEnabled: Bool {
        get {
            return PersistentStore.isSoundEffectsEnabled
        }
        set {
            PersistentStore.isSoundEffectsEnabled = newValue
            
            AudioUserCodeProxy().audioControllerSettingsDidChange()
        }
    }

    public var isAllAudioEnabled: Bool {
        get {
            return PersistentStore.isAllAudioEnabled
        }
    }

    public func playSound(_ url: URL, volume: Int = 80) {
        guard !AudioSession.current.isPlaybackBlocked else { return }

        do {
            let audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.volume = Float(max(min(volume, 100), 0)) / 100.0
            audioController.register(audioPlayer)
            audioPlayer.play()
        } catch {
            PBLog("Could not load sound from url: \(url.absoluteString)")
        }
    }
    
    public func register(_ player: AVAudioPlayer) {
        activeAudioPlayers.insert(player)
        player.delegate = self
    }
    
    public func stopAllPlayers() {
        activeAudioPlayers.forEach { $0.stop() }
        activeAudioPlayers.removeAll()
    }
    
    public func duckAllPlayers(fadeDuration: TimeInterval = 2.0) {
        activeAudioPlayers.forEach { $0.setVolume(0.0, fadeDuration: fadeDuration) }
        
        Timer.scheduledTimer(withTimeInterval: fadeDuration, repeats: false) { _ in
            self.stopAllPlayers()
        }
    }
    
    public func stopAllPlayersExceptBackgroundAudio() {
        activeAudioPlayers.filter{ $0 != backgroundAudioPlayer }.forEach {
            $0.stop()
            activeAudioPlayers.remove($0)
        }
    }
    
    public func playBackgroundAudioLoop(_ sound: Music, volume: Int = 80) {
        guard let url = sound.url else { return }
        
        if let _ = backgroundAudioPlayer {
            stopBackgroundAudioLoop()
        }
        
        backgroundAudioMusic = sound
        
        if isBackgroundAudioEnabled {
            do {
                let audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer.volume = Float(max(min(volume, 100), 0)) / 100.0
                register(audioPlayer)
                audioPlayer.numberOfLoops = -1
                audioPlayer.play()
                backgroundAudioPlayer = audioPlayer
            } catch {}
        }
    }
    
    public func pauseBackgroundAudioLoop() {
        guard let audioPlayer = backgroundAudioPlayer else { return }
        audioPlayer.pause()
    }
    
    public func resumeBackgroundAudioLoop() {
        guard let audioPlayer = backgroundAudioPlayer else { return }
        audioPlayer.play()
    }
    
    func stopBackgroundAudioLoop() {
        guard let audioPlayer = backgroundAudioPlayer else { return }
        audioPlayer.stop()
        backgroundAudioMusic = nil
        activeAudioPlayers.remove(audioPlayer)
        backgroundAudioPlayer = nil
    }
    
    public func adjustBackgroundAudioLoop(volume: Int) {
        backgroundAudioPlayer?.volume = Float(max(min(volume, 100), 0)) / 100.0
    }
}

extension AudioController: AVAudioPlayerDelegate {
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        activeAudioPlayers.remove(player)
    }
}

extension AudioController: LiveViewLifeCycleProtocol {
    public func liveViewMessageConnectionClosed() {
        duckAllPlayers()
    }
}
