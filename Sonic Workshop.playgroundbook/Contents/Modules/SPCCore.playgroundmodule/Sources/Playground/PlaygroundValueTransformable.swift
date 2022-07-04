//
//  PlaygroundValueTransformable.swift
//  
//  Copyright © 2020 Apple Inc. All rights reserved.
//


import Foundation
import UIKit
import SpriteKit
import PlaygroundSupport


public protocol PlaygroundValueTransformable {
    
    var playgroundValue: PlaygroundValue? { get }
    static func from(_ playgroundValue: PlaygroundValue) -> PlaygroundValueTransformable?
    
}


extension String: PlaygroundValueTransformable {
    
    public var playgroundValue: PlaygroundValue? {
        
        return .string(self)
    }
    
    
    public static func from(_ playgroundValue: PlaygroundValue) -> PlaygroundValueTransformable? {
        guard case .string(let string) = playgroundValue else { return nil }

        return string
    }
    
}



extension Bool: PlaygroundValueTransformable {
    
    public var playgroundValue: PlaygroundValue? {
        
        return .boolean(self)
    }

    
    public static func from(_ playgroundValue: PlaygroundValue) -> PlaygroundValueTransformable? {
        guard case .boolean(let boolean) = playgroundValue else { return nil }
        
        return boolean
    }
    
}



extension Int: PlaygroundValueTransformable {
    
    public var playgroundValue: PlaygroundValue? {
        
        return .integer(self)
    }
    
    
    public static func from(_ playgroundValue: PlaygroundValue) -> PlaygroundValueTransformable? {
        guard case .integer(let integer) = playgroundValue else { return nil }
        
        return integer
    }
    
}



extension CGFloat: PlaygroundValueTransformable {
    
    public var playgroundValue: PlaygroundValue? {
        
        return .floatingPoint(Double(self))
    }
    
    
    public static func from(_ playgroundValue: PlaygroundValue) -> PlaygroundValueTransformable? {
        guard case .floatingPoint(let doubleValue) = playgroundValue else { return nil }
        
        return CGFloat(doubleValue)
    }
    
}

extension Double: PlaygroundValueTransformable {
    
    public var playgroundValue: PlaygroundValue? {
        return .floatingPoint(self)
    }
    
    
    public static func from(_ playgroundValue: PlaygroundValue) -> PlaygroundValueTransformable? {
        guard case .floatingPoint(let doubleValue) = playgroundValue else { return nil }
        return doubleValue
    }
    
}

extension UIBezierPath: PlaygroundValueTransformable {
    
    public var playgroundValue: PlaygroundValue? {
        guard let data = try? NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: true) else { return nil }
        return .data(data)
    }
    
    public static func from(_ playgroundValue: PlaygroundValue) -> PlaygroundValueTransformable? {
        guard case .data(let data) = playgroundValue else { return nil }
        return try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIBezierPath.self, from: data)
    }
}

extension CGPoint: PlaygroundValueTransformable {
    
    public var playgroundValue: PlaygroundValue? {
        return .array([.floatingPoint(Double(x)), .floatingPoint(Double(y))])
    }
    
    public static func from(_ playgroundValue: PlaygroundValue) -> PlaygroundValueTransformable? {
        guard
            case .array(let components) = playgroundValue,
            components.count == 2,
            case .floatingPoint(let x) = components[0],
            case .floatingPoint(let y) = components[1]
            
            else { return nil }
        
        return CGPoint(x: x, y: y)
    }
    
}

extension CGSize: PlaygroundValueTransformable {
    
    public var playgroundValue: PlaygroundValue? {
        return .array([.floatingPoint(Double(width)), .floatingPoint(Double(height))])
    }
    
    public static func from(_ playgroundValue: PlaygroundValue) -> PlaygroundValueTransformable? {
        guard
            case .array(let components) = playgroundValue,
            components.count == 2,
            case .floatingPoint(let width) = components[0],
            case .floatingPoint(let height) = components[1]
            
            else { return nil }
        
        return CGSize(width: width, height: height)
    }
    
}

extension CGVector: PlaygroundValueTransformable {
    
    public var playgroundValue: PlaygroundValue? {
        return .array([.floatingPoint(Double(dx)), .floatingPoint(Double(dy))])
    }
    
    public static func from(_ playgroundValue: PlaygroundValue) -> PlaygroundValueTransformable? {
        guard
            case .array(let components) = playgroundValue,
            components.count == 2,
            case .floatingPoint(let dx) = components[0],
            case .floatingPoint(let dy) = components[1]
            
            else { return nil }
        
        return CGVector(dx: dx, dy: dy)
    }
}

extension CGAffineTransform: PlaygroundValueTransformable {
    
    public var playgroundValue: PlaygroundValue? {
        return .array([
        .floatingPoint(Double(a)), .floatingPoint(Double(b)),
        .floatingPoint(Double(c)), .floatingPoint(Double(d)),
        .floatingPoint(Double(tx)), .floatingPoint(Double(ty))
        ])
    }
    
    public static func from(_ playgroundValue: PlaygroundValue) -> PlaygroundValueTransformable? {
        guard
            case .array(let components) = playgroundValue,
            components.count == 6,
            case .floatingPoint(let a) = components[0],
            case .floatingPoint(let b) = components[1],
            case .floatingPoint(let c) = components[2],
            case .floatingPoint(let d) = components[3],
            case .floatingPoint(let tx) = components[4],
            case .floatingPoint(let ty) = components[5]
            else { return nil }
        return CGAffineTransform(a: CGFloat(a), b: CGFloat(b), c: CGFloat(c), d: CGFloat(d), tx: CGFloat(tx), ty: CGFloat(ty))
    }
}

extension UIColor: PlaygroundValueTransformable {
    
    public var playgroundValue: PlaygroundValue? {
        
        return .array([.floatingPoint(Double(redComponent)),
                       .floatingPoint(Double(greenComponent)),
                       .floatingPoint(Double(blueComponent)),
                       .floatingPoint(Double(alpha))])
    }
    
    public static func from(_ playgroundValue: PlaygroundValue) -> PlaygroundValueTransformable? {
        guard
            case .array(let components) = playgroundValue,
            components.count == 4,
            case .floatingPoint(let red)   = components[0],
            case .floatingPoint(let green) = components[1],
            case .floatingPoint(let blue)  = components[2],
            case .floatingPoint(let alpha) = components[3] else { return nil }
        
        return UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: CGFloat(alpha))
    }
    
}

extension UIImage: PlaygroundValueTransformable {
    
    public var playgroundValue: PlaygroundValue? {
        guard let imageData = (self.pngData()) else { return nil }
        return .data(imageData)
    }
    
    public static func from(_ playgroundValue: PlaygroundValue) -> PlaygroundValueTransformable? {
        guard case .data(let imageData) = playgroundValue else { return nil }
        return UIImage(data: imageData)
    }
}

extension SKAction: PlaygroundValueTransformable {
    
    public var playgroundValue: PlaygroundValue? {
        guard let data = try? NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: true) else { return nil }
        return .data(data)
    }
    
    public static func from(_ playgroundValue: PlaygroundValue) -> PlaygroundValueTransformable? {
        guard case .data(let data) = playgroundValue else { return nil }
        return try? NSKeyedUnarchiver.unarchivedObject(ofClass: SKAction.self, from: data)
    }
}



// PlaygroundValue is used as the value in the dictionary when the underlying type is a collection type: Array, Dictionary.
extension PlaygroundValue: PlaygroundValueTransformable {
    
    public var playgroundValue: PlaygroundValue? {
     
        return self
    }
    
    
    public static func from(_ playgroundValue: PlaygroundValue) -> PlaygroundValueTransformable? {
        switch playgroundValue {
        case .array(let array):
            return PlaygroundValueArray(array: array)
            
        case .dictionary(let dictionary):
            return PlaygroundValueDictionary(dictionary: dictionary)
            
        default:
            return nil
        }
    }
}

public struct PlaygroundValueArray: PlaygroundValueTransformable {
    
    public var array: [PlaygroundValue]? = nil
    
    
    public init(array: [PlaygroundValue]) {
        self.array = array
    }
    
    
    public init?(playgroundValue: PlaygroundValue) {
        guard case .array(let playgroundValues) = playgroundValue else { return nil }
        array = playgroundValues
    }
    
    
    public static func from(_ playgroundValue: PlaygroundValue) -> PlaygroundValueTransformable? {
        guard case .array(let playgroundValues) = playgroundValue else { return nil }
        
        return PlaygroundValueArray(array: playgroundValues)
    }
    
    
    public var playgroundValue: PlaygroundValue? {
        guard let values = array else { return nil }
        return .array(values)
    }
    
}

public struct PlaygroundValueDictionary: PlaygroundValueTransformable {
    
    public var dictionary: [String : PlaygroundValue]? = nil
    
    
    public init(dictionary: [String : PlaygroundValue]) {
        self.dictionary = dictionary
    }
    
    
    public init?(playgroundValue: PlaygroundValue) {
        guard case .dictionary(let dictionary) = playgroundValue else { return nil }
        self.dictionary = dictionary
    }
    
    
    public static func from(_ playgroundValue: PlaygroundValue) -> PlaygroundValueTransformable? {
        guard case .dictionary(let dictionary) = playgroundValue else { return nil }
        
        return PlaygroundValueDictionary(dictionary: dictionary)
    }
    
    
    public var playgroundValue: PlaygroundValue? {
        guard let info = dictionary else { return nil }
        return .dictionary(info)
    }
    
}



