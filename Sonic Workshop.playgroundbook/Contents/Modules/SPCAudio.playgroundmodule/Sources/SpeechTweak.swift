//
//  SpeechTweak.swift
//  
//  Copyright © 2020 Apple Inc. All rights reserved.
//


import AVFoundation
import SPCCore

/// An enumeration of different tweaks that can be applied to an instrument, including: pitch, speed, and volume.
///
/// - localizationKey: SpeechTweakType
public enum SpeechTweakType {
    case pitch, speed, volume
    
    // The range that the particular tweak modifier can be between.
    fileprivate var tweakRange: ClosedRange<Float> {
        switch self {
        case .pitch:
            return 0.5 ... 2.0
        case .speed:
            return 0.1 ... 2.0
        case .volume:
            return 0.0 ... 1.0
        }
    }
}

/// This class provides effects to tweak how the speech sounds.
///
/// - localizationKey: SpeechTweak
public struct SpeechTweak {
    
    var type: SpeechTweakType
    
    private var valueRange: ClosedRange<Int>
    
    /// Create a speech tweak whose effect varies by the values (from 0 to 100). Applies a different value within the range, depending on where you touch on the keyboard.
    ///
    /// - Parameter type: The type of speech tweak.
    /// - Parameter startValue: The starting value of the effect.
    /// - Parameter endValue: The ending value of the effect.
    ///
    /// - localizationKey: SpeechTweak(type:startValue:endValue:)
    public init(type: SpeechTweakType, effectFrom startValue: Int, to endValue: Int) {
        self.type = type
        
        let firstValue = startValue.clamped(to: Constants.userValueRange)
        let secondValue = endValue.clamped(to: Constants.userValueRange)
        if firstValue < secondValue {
            self.valueRange = firstValue...secondValue
        } else {
            self.valueRange = secondValue...firstValue
        }
    }
    
    // When passed in a normalized value between 0 to 1, places it within the user’s specified valueRange and then converts that to the actual value for the underlying speech tweak.
    func tweakValue(fromNormalizedValue normalizedValue: CGFloat) -> Float {
        let valueRangeCount = CGFloat(valueRange.count)
        let normalizedValueInDefinedRange = ((normalizedValue * valueRangeCount) + CGFloat(valueRange.lowerBound)) / CGFloat(Constants.userValueRange.count)
        
        return SpeechTweak.tweak(normalizedValue: normalizedValueInDefinedRange, forType: type)
    }
    
    static func tweak(normalizedValue: CGFloat, forType type: SpeechTweakType) -> Float {
        let tweakRange = type.tweakRange
        return (Float(normalizedValue) * (tweakRange.upperBound - tweakRange.lowerBound)) + tweakRange.lowerBound
    }
}
