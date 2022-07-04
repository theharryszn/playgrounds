//
//  AnchorPoint.swift
//  
//  Copyright © 2020 Apple Inc. All rights reserved.
//

import UIKit
import PlaygroundSupport
import SPCCore
import SPCIPC

/// An enumeration of the points within a graphic to which its position can be anchored.
///
/// - localizationKey: AnchorPoint
public enum AnchorPoint: Int {
    case center
    case left
    case top
    case right
    case bottom
}

extension AnchorPoint: PlaygroundValueTransformable {
    
    public var playgroundValue: PlaygroundValue? {
        return .integer(self.rawValue)
    }
    
    public static func from(_ playgroundValue: PlaygroundValue) -> PlaygroundValueTransformable? {
        guard case .integer(let integer) = playgroundValue else { return nil }
        return AnchorPoint(rawValue: integer)
    }
}
