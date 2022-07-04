//
//  Point.swift
//  
//  Copyright © 2020 Apple Inc. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics
import PlaygroundSupport

/// `Point` is a struct for specifying a point with x and y coordinates.
///
/// - localizationKey: Point
public struct Point: Codable {
    
    /// The point whose x and y coordinates are both zero — the origin of the coordinate system.
    ///
    /// - localizationKey: Point.zero
    public static let zero = Point(x: 0, y: 0)
    
    /// The x coordinate of the point.
    ///
    /// - localizationKey: Point.x
    public var x: Double
    
    /// The y coordinate of the point.
    ///
    /// - localizationKey: Point.y
    public var y: Double
    
    /// Creates a point with x and y coordinates from `Double` values.
    ///
    /// - Parameter x: The position of the point along the x-axis.
    /// - Parameter y: The position of the point along the y-axis.
    ///
    /// - localizationKey: Point(x{Double}:y{Double}:)
    public init(x: Double = 0, y: Double = 0) {
        self.x = x
        self.y = y
    }
    
    /// Creates a point with x and y coordinates from `Float` values.
    ///
    /// - localizationKey: Point(x{Float}:y{Float}:)
    public init(x: Float = 0, y: Float = 0) {
        self.x = Double(x)
        self.y = Double(y)
    }
    
    /// Creates a point with x and y coordinates from `CGFloat` values.
    ///
    /// - localizationKey: Point(x{CGFloat}:y{CGFloat}:)
    public init(x: CGFloat = 0, y: CGFloat = 0) {
        self.x = Double(x)
        self.y = Double(y)
    }
    
    /// Creates a point with x and y coordinates from `Int` values.
    ///
    /// - localizationKey: Point(x{Int}:y{Int}:)
    public init(x: Int = 0, y: Int = 0) {
        self.x = Double(x)
        self.y = Double(y)
    }
    
    /// Creates a point with a `CGPoint`.
    ///
    /// - localizationKey: Point(_{cgpoint}:)
    public init(_ cgPoint: CGPoint) {
        self.x = Double(cgPoint.x)
        self.y = Double(cgPoint.y)
    }
    
    /// The point as a `CGPoint` value.
    ///
    /// - localizationKey: Point.cgPoint
    public var cgPoint: CGPoint { return CGPoint(x: x, y: y) }
    
    // Returns a description of the point, used for accessibility.
    public var description: String {
        let format = NSLocalizedString("Point with coordinates x:%@, y:%@", tableName: "SPCCore", comment: "Point description, used for accessibility.")
        return String.localizedStringWithFormat(format, String(x), String(y))
    }
}

extension Point: Hashable, Equatable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.x)
        hasher.combine(self.y)
    }
    
    public static func ==(lhs: Point, rhs: Point) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
}

public extension CGPoint {
    init(_ point: Point) {
        self.init()
        self.x = CGFloat(point.x)
        self.y = CGFloat(point.y)
    }
    
    var point: Point {
        return Point(x: self.x, y: self.y)
    }
}

public extension Point {
    /// Returns an array of count points on a circle around the center point.
    ///
    /// - Parameter radius: The radius of the circle.
    /// - Parameter count: The number of points to return.
    /// - Parameter centerPoint: The center point of the circle.
    ///
    /// - localizationKey: Point.pointsInCircleWith(radius:count:around:)
    static func pointsInCircleWith(radius: Double, count: Int, around centerPoint: Point) -> [Point] {
        
        var points = [Point]()
        
        let slice = 2 * Double.pi / Double(count)
        
        for i in 0..<count {
            let angle = slice * Double(i)
            let x = centerPoint.x + (radius * cos(angle))
            let y = centerPoint.y + (radius * sin(angle))
            points.append(Point(x: x, y: y))
        }
        
        return points
    }
}

extension Point: PlaygroundValueTransformable {
    
    public var playgroundValue: PlaygroundValue? {
        return .array([.floatingPoint(x), .floatingPoint(y)])
    }
    
    public static func from(_ playgroundValue: PlaygroundValue) -> PlaygroundValueTransformable? {
        guard
            case .array(let components) = playgroundValue,
            components.count > 1,
            case .floatingPoint(let x) = components[0],
            case .floatingPoint(let y) = components[1]
            
            else { return nil }
        
        return Point(x: x, y: y)
    }
}

