//
//  AssessmentInfo.swift
//  
//  Copyright © 2020 Apple Inc. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit
import PlaygroundSupport
import SPCCore

public enum AssessmentTrigger {
    case start(context: AssessmentInfo.Context)
    case stop
    case evaluate
    
    public var name: String {
        switch self {
        case .start(context: _):
            return "start"
        case .stop:
            return "stop"
        case .evaluate:
            return "evaluate"
        }
    }
}


extension AssessmentTrigger: RawRepresentable {
    public typealias RawValue = [Int]

    public init?(rawValue: RawValue) {
        guard rawValue.count > 0 else { return nil }
        
        switch rawValue[0] {
        case 0:
            guard
                rawValue.count > 1,
                let context = AssessmentInfo.Context(rawValue: rawValue[1])
                else { return nil }
            self = .start(context: context)
            
        case 1:
            self = .stop
            
        case 2:
            self = .evaluate
            
        default:
            return nil
        }
    }
    
    
    public var rawValue: RawValue {
        var value = [Int]()
        switch self {
        case .start(let context):
            value.append(0)
            value.append(context.rawValue)
            
        case .stop:
            value.append(1)
            
        case .evaluate:
            value.append(2)
        }

        return value
    }

}

extension AssessmentTrigger: PlaygroundValueTransformable {
    
    public var playgroundValue: PlaygroundValue? {
        var array = [PlaygroundValue]()
        array.append(.integer(rawValue[0]))
        if(rawValue.count > 1) {
            array.append(.integer(rawValue[1]))
        }
        
        return .array(array)
    }
    
    public static func from(_ playgroundValue: PlaygroundValue) -> PlaygroundValueTransformable? {
        guard
            case .array(let array) = playgroundValue,
            array.count > 0,
            case .integer(let trigger) = array[0]
            else { return nil }
        
        var returnTrigger: AssessmentTrigger?
        
        switch trigger {
            
        case 0:
            guard
                array.count > 1,
                case .integer(let rawValue) = array[1],
                let context = AssessmentInfo.Context(rawValue: rawValue)
                else { return nil }
            returnTrigger = .start(context: context)
            
        case 1:
            returnTrigger = .stop
            
        case 2:
            
            returnTrigger = .evaluate
            
        default:
            returnTrigger = nil
        }
        
        return returnTrigger
    }
}

public enum AssessmentEvent {
    case defaultEvent
//    // Graphic
//    case setFontName(graphic: Graphic, name:String)
//    case setFontSize(graphic: Graphic, size:Double)
//    case setTextColor(graphic: Graphic, color: Color)
//    case createStringGraphic(graphic: Graphic, String)
//    case createImageGraphic(graphic: Graphic, Image)
//    case setHidden(graphic: Graphic, Bool)
//    case setAlpha(graphic: Graphic, alpha: Double)
//    case setRotation(graphic: Graphic, angle: Double)
//    case moveTo(graphic: Graphic, position: Point)
//    case moveBy(graphic: Graphic, x: Double, y: Double)
//    case applyImpulse(graphic: Graphic, x: Double, y: Double)
//    case applyForce(graphic: Graphic, x: Double, y: Double, duration: Double)
//    case setImage(graphic: Graphic, Image)
//    case remove(graphic: Graphic)
//    case orbit(graphic: Graphic, x: Double, y: Double, period: Double)
//    case spin(graphic: Graphic, period: Double)
//    case pulsate(graphic: Graphic, period: Double, count: Int)
//    case swirlAway(graphic: Graphic, after: Double)
//
//    // Audio
//    case speak(text: String)
//    case playSound(sound: Sound, volume: Double)
//    case playInstrument(instrumentKind: Instrument.Kind, note: Int, volume: Double)
//
//    // Scene
//    case setSceneBackgroundImage(Image?)
//    case setLightSensorImage(UIImage?)
//    case print(graphic: Graphic)
//    case placeAt(graphic: Graphic, position: Point)
}


public struct AssessmentInfo {
    
    public enum Context: Int {
        case tool
        case button
        case discrete
    }

    public let events: [AssessmentEvent]
    public let context: Context
    public let customInfo: [AnyHashable : Any]
    
    public subscript(key: AnyHashable) -> Any? {
         return customInfo[key]
    }

}


