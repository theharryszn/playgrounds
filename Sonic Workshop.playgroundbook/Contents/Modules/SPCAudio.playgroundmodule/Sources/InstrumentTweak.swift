//
//  InstrumentTweak.swift
//  
//  Copyright © 2020 Apple Inc. All rights reserved.
//

import AVFoundation
import SPCCore

/** 
 An enum of different type of tweak that can be applied to an instrument.
 Tweaks that can be applied include pitchBend, pressure, and velocity.
 */
enum InstrumentTweakType {
    case pitchBend, pressure, velocity
    
    // The max value that the particular tweak modifier can be.
    var tweakRange: ClosedRange<Int> {
        switch self {
        case .pitchBend:
            return 0...16383
        case .pressure:
            return 0...127
        case .velocity:
            return 0...127
        }
    }
}

/// A struct that provides effects to tweak how the instrument sounds.
struct InstrumentTweak {

    var type: InstrumentTweakType
    
    private var valueRange: ClosedRange<Int>
    
    /// Creates an instrument tweak whose effect varies within the range startValue to endValue. Depending on where you touch the keyboard, a different value in the range will be applied.
    init(type: InstrumentTweakType, effectFrom startValue: Int, to endValue: Int) {
        self.type = type
        let firstValue = startValue.clamped(to: Constants.userValueRange)
        let secondValue = endValue.clamped(to: Constants.userValueRange)
        if firstValue < secondValue {
            self.valueRange = firstValue...secondValue
        } else {
            self.valueRange = secondValue...firstValue
        }
    }
    
    // When passed in a normalized value between 0 to 1, places it within the tweak’s value range, and then converts that to the actual value for the underlying instrument tweak.
    func tweakValue(fromNormalizedValue normalizedValue: CGFloat) -> Int {
        let valueRangeCount = CGFloat(valueRange.count)
        let possibleRangeCount = CGFloat(Constants.userValueRange.count)
        let normalizedValueInDefinedRange = ((normalizedValue * valueRangeCount) + CGFloat(valueRange.lowerBound)) / possibleRangeCount
        
        return InstrumentTweak.tweak(normalizedValue: normalizedValueInDefinedRange, forType: type)
    }
    
    static func tweak(normalizedValue: CGFloat, forType type: InstrumentTweakType) -> Int {
        let tweakRange = type.tweakRange
        return Int(normalizedValue * CGFloat(tweakRange.upperBound - tweakRange.lowerBound)) + tweakRange.lowerBound
    }
}
