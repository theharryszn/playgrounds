//
//  Touch.swift
//  
//  Copyright © 2020 Apple Inc. All rights reserved.
//

import UIKit
import SPCCore

/// Touch holds information about a touch, such as its position in the scene and any graphics it has touched.
///
/// - localizationKey: Touch
public struct Touch {
    
    /// The position of your Touch on the scene.
    ///
    /// - localizationKey: Touch.position
    public var position: Point
    
    /// The distance of your Touch from the previous graphic placed on the scene.
    ///
    /// - localizationKey: Touch.previousPlaceDistance
    public var previousPlaceDistance: Double
    
    /// A Boolean value to determine placement of the first touch.
    ///
    /// - localizationKey: Touch.firstTouch
    public var firstTouch: Bool
    
    /// A Boolean value to determine when touches enter a new graphic.
    ///
    /// - localizationKey: Touch.firstTouchInGraphic
    public var firstTouchInGraphic: Bool = false
    
    /// A Boolean value to determine when touches leave the current graphic.
    ///
    /// - localizationKey: Touch.lastTouchInGraphic
    public var lastTouchInGraphic: Bool = false
    
    /// A Boolean value to determine when the last touch occurs.
    ///
    /// - localizationKey: Touch.lastTouch
    public var lastTouch: Bool = false
    
    /// A Boolean value to determine whether the touch represents a double-touch.
    ///
    /// - localizationKey: Touch.doubleTouch
    public var doubleTouch: Bool = false
    
    public init(position: Point, previousPlaceDistance: Double, firstTouch: Bool) {
        self.position = position
        self.previousPlaceDistance = previousPlaceDistance
        self.firstTouch = firstTouch
    }
    
    init(position: Point, previousPlaceDistance: Double, firstTouch: Bool, touchedGraphic: Graphic?, capturedGraphicID: String) {
            self.position = position
            self.previousPlaceDistance = previousPlaceDistance
            self.firstTouch = firstTouch
            self.touchedGraphic = touchedGraphic
            self.capturedGraphicID = capturedGraphicID
    }
    
    /**
    A `Graphic` in the scene at the position of the touch event.
 
    A `touchedGraphic` can be compared for equality with other graphics:
     
    `if touch.touchedGraphic == otherGraphic { return }`
     
    - localizationKey: Touch.touchedGraphic
     */
    public var touchedGraphic: Graphic?
    
    public var capturedGraphicID: String = ""
    
    public static func ==(lhs: Touch, rhs: Touch) -> Bool {
        return lhs.position == rhs.position &&
                lhs.previousPlaceDistance == rhs.previousPlaceDistance
    }

}
