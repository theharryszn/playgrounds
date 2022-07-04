//
//  ToneOutput.swift
//  
//  Copyright © 2020 Apple Inc. All rights reserved.
//

import AVFoundation
import Accelerate
import CoreAudio
import SPCIPC

@objc public protocol AURenderCallbackDelegate {
    func performRender(_ ioActionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
                       timeStamp: UnsafePointer<AudioTimeStamp>,
                       busNumber: UInt32,
                       numberFrames: UInt32,
                       ioData: UnsafeMutablePointer<AudioBufferList>) -> OSStatus
}

private let AudioController_RenderCallback: AURenderCallback = {(inRefCon, ioActionFlags, timeStamp, busNumber, numberFrames, ioData) -> OSStatus in
    let delegate = unsafeBitCast(inRefCon, to: AURenderCallbackDelegate.self)
    
    let result = delegate.performRender(ioActionFlags,
                                        timeStamp: timeStamp,
                                        busNumber: busNumber,
                                        numberFrames: numberFrames,
                                        ioData: ioData!)
    return result
}

/// The sound being produced.
///
/// - localizationKey: ToneOutput
public class ToneOutput : AURenderCallbackDelegate {
    let sampleRate = 44100.0
    var audioComponent:  AudioComponentInstance?
    let toneMutex = UnsafeMutablePointer<pthread_mutex_t>.allocate(capacity: 1)
    var playTones = [Tone]()
    var playThetas = [Double]()
    var muteTones = audioController.isSoundEffectsAudioEnabled
    
    /// An initializer for ToneOutput.
    ///
    /// - localizationKey: ToneOutput()
    public init() {
        var status = noErr
        
        pthread_mutex_init(toneMutex, nil)
        
        AudioUserCodeProxy.registerToRecieveDecodedMessage(as: self)
        
        // Set up the audio session.
        let sessionInstance = AVAudioSession.sharedInstance()
    
        do {
            if sessionInstance.category != .playAndRecord {
                try sessionInstance.setCategory(.ambient, mode: .default) // Any tones we play should play over the top of existing Music
            }
            try sessionInstance.setPreferredIOBufferDuration(0.005)
            try sessionInstance.setPreferredSampleRate(self.sampleRate)
            
            try sessionInstance.setActive(true)
        } catch {
            print("ToneOutput, Exception configuring the audio session instance.")
        }
    
        // Find an audio component.
        var componentDescription = AudioComponentDescription()
    
        componentDescription.componentType = kAudioUnitType_Output
        componentDescription.componentSubType = kAudioUnitSubType_RemoteIO
        componentDescription.componentManufacturer = kAudioUnitManufacturer_Apple
        componentDescription.componentFlags = 0
        componentDescription.componentFlagsMask = 0
    
        let component = AudioComponentFindNext(nil, &componentDescription)
        guard component != nil else {
            print("ToneOutput, AudioComponentFindNext() failed with a nil component.")
            return
        }
    
        if let component = component {
            // Set up the audio unit.
            status = AudioComponentInstanceNew(component, &self.audioComponent)
            guard status == noErr else {
                print("ToneOutput, AudioComponentInstanceNew() failed, status = \(status)")
                return
            }
            
            if let audioComponent = self.audioComponent {
                let uInt32Size = UInt32(MemoryLayout<UInt32>.size)
                var one:UInt32 = 1
                
                // Support output only (speakers).
                status = AudioUnitSetProperty(audioComponent, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Output, 0, &one, uInt32Size)
                guard status == noErr else {
                    print("ToneOutput, AudioUnitSetProperty(kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Output) failed, status = \(status)")
                    return
                }
                
                var ioFormat = AudioStreamBasicDescription()
                
                ioFormat.mSampleRate = self.sampleRate
                ioFormat.mFormatID = kAudioFormatLinearPCM
                ioFormat.mFormatFlags = kAudioFormatFlagsNativeFloatPacked | kAudioFormatFlagIsNonInterleaved
                ioFormat.mChannelsPerFrame = 1
                ioFormat.mBitsPerChannel = 32
                ioFormat.mBytesPerPacket = 4
                ioFormat.mFramesPerPacket = 1
                ioFormat.mBytesPerFrame = 4
                
                let audioStreamSize = UInt32(MemoryLayout<AudioStreamBasicDescription>.stride)
                
                status = AudioUnitSetProperty(audioComponent, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 1, &ioFormat, audioStreamSize)
                guard status == noErr else {
                    print("ToneOutput, AudioUnitSetProperty(kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output) failed, status = \(status)")
                    return
                }
                
                var maxFramesPerSlice = 4096
                status = AudioUnitSetProperty(audioComponent, kAudioUnitProperty_MaximumFramesPerSlice, kAudioUnitScope_Global, 0, &maxFramesPerSlice, uInt32Size)
                guard status == noErr else {
                    print("ToneOutput, AudioUnitSetProperty(kAudioUnitProperty_MaximumFramesPerSlice, kAudioUnitScope_Global) failed, status = \(status)")
                    return
                }
                
                var renderCallback = AURenderCallbackStruct(inputProc: AudioController_RenderCallback, inputProcRefCon: Unmanaged.passUnretained(self).toOpaque())
                
                status = AudioUnitSetProperty(audioComponent, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Input, 0, &renderCallback, UInt32(MemoryLayout<AURenderCallbackStruct>.size))
                guard status == noErr else {
                    print("ToneOutput, AudioUnitSetProperty(kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Input) failed, status = \(status)")
                    return
                }
                
                status = AudioUnitInitialize(audioComponent)
                guard status == noErr else {
                    print("ToneOutput, AudioUnitInitialize() failed, status = \(status)")
                    return
                }
                
                self.start()
            }
        }
    }
    
    deinit {
        stop()
        
        pthread_mutex_destroy(toneMutex)
        toneMutex.deallocate()
    }
    
    /// A function to play a tone.
    ///
    /// - Parameter tone: The note or sound being produced.
    ///
    /// - localizationKey: ToneOutput.play(tone:)
    public func play(tone: Tone) {
        play(tones:[tone])
    }
    
    /// A function to play more than one tone.
    ///
    /// - Parameter tones: The notes or sounds being produced.
    ///
    /// - localizationKey: ToneOutput.play(tones:)
    public func play(tones: [Tone]) {
        pthread_mutex_lock(toneMutex)
        
        playTones = tones
    
        if playThetas.count != playTones.count {
            // Only change the derivation of the waveforms if the frequencies change.
            playThetas = Array(repeating:0.0, count:tones.count)
        }
        
        pthread_mutex_unlock(toneMutex)
    }
    
    /// A function to stop the tones being played.
    ///
    /// - localizationKey: ToneOutput.stopTones()
    public func stopTones() {
        pthread_mutex_lock(toneMutex)
        
        playTones = []
        playThetas = []
        
        pthread_mutex_unlock(toneMutex)
    }
    
    /// A function to start playing the tones.
    ///
    /// - localizationKey: ToneOutput.start()
    public func start() {
        let component = audioComponent!,
        status = AudioOutputUnitStart(component)
        guard status == noErr else {
            print("ToneOutput, AudioOutputUnitStart() failed, status = \(status)")
            return
        }
    }
    
    /// A function to stop the ToneOutput.
    ///
    /// - localizationKey: ToneOutput.stop()
    public func stop() {
        let component = audioComponent!,
        status = AudioOutputUnitStop(component)
        guard status == noErr else {
            print("ToneOutput, AudioOutputUnitStop() failed, status = \(status)")
            return
        }
    }
    
    public func performRender(_ ioActionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
                       timeStamp: UnsafePointer<AudioTimeStamp>,
                       busNumber: UInt32,
                       numberFrames: UInt32,
                       ioData: UnsafeMutablePointer<AudioBufferList>) -> OSStatus
    {
        let ioPtr = UnsafeMutableAudioBufferListPointer(ioData)
        let channel = Int(busNumber)
        let buffer = ioPtr[channel].mData!.assumingMemoryBound(to: Float.self)
        
        pthread_mutex_lock(toneMutex)
        
        let frequencyCount = playTones.count
        
        // Wipe play buffer for addative frequencies.
        for i in 0 ..< ioPtr.count {
            memset( ioPtr[i].mData!, 0, Int(ioPtr[i].mDataByteSize))
        }
        
        for i in 0 ..< frequencyCount {
            let tone = playTones[i]
            let theta_increment = 2.0 * Double.pi * tone.pitch / sampleRate
            
            // Generate the samples.
            for frame in 0 ..< numberFrames {
                let volume = muteTones ? tone.volume/Double(frequencyCount) : 0.0
                buffer[Int(frame)] = buffer[Int(frame)] + Float(sin(playThetas[i]) * volume) // frequencies are addative
                
                playThetas[i] = playThetas[i] + theta_increment
                
                if playThetas[i] > 2.0 * Double.pi {
                    playThetas[i] = playThetas[i] - 2.0 * Double.pi
                }
            }
        }
        
        pthread_mutex_unlock(toneMutex)
        
        return noErr
    }
}

extension ToneOutput: AudioUserCodeProxyProtocol {
    public func audioControllerSettingsDidChange() {
        muteTones = audioController.isSoundEffectsAudioEnabled
    }
}

/// Tone is a struct that holds the pitch and volume.
///
/// - localizationKey: Tone
public struct Tone: Codable {
    public var pitch: Double
    public var volume: Double
    
    /// Tone is a struct that holds the pitch and volume.
    ///
    /// - Parameter pitch: A tone’s highness or lowness.
    /// - Parameter volume: A tone’s loudness or softness.
    ///
    /// - localizationKey: Tone(pitch:volume:)
    public init(pitch: Double, volume: Double) {
        self.pitch = pitch
        self.volume = volume
    }
}
