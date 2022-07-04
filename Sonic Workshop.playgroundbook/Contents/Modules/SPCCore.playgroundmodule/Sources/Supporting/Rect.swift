//
//  Rect.swift
//  
//  Copyright © 2020 Apple Inc. All rights reserved.
//

import CoreGraphics

/// `Rect` is a struct for specifying a rectangle using its position and size.
///
/// - localizationKey: Rect
public struct Rect: Codable {
    
    /// The rectangle whose position is the origin (0, 0), and whose width and height is zero.
    ///
    /// - localizationKey: Rect.zero
    public static let zero = Size(width: 0, height: 0)

    /// The position of the rectangle.
    ///
    /// - localizationKey: Rect.position
    public var position: Point
    
    /// The size of the rectangle.
    ///
    /// - localizationKey: Rect.size
    public var size: Size

    /// Creates a rectangle with the specified position and size.
    ///
    /// - localizationKey: Rect(position{point}:size:{size})
    public init(position: Point, size: Size) {
        self.position = position
        self.size = size
    }
    
    /// Creates a rectangle centered on the specified x and y coordinates, and with the specified width and height.
    ///
    /// - localizationKey: Rect(x:y:width:height:)
    public init(x: Double, y: Double, width: Double, height: Double) {
        self.position = Point(x: x, y: y)
        self.size = Size(width: width, height: height)
    }
    
    /// Creates a rectangle from a `CGPoint` and a `CGSize`.
    ///
    /// - localizationKey: Rect(position{cgpoint}:size:{cgsize})
    public init(position: CGPoint, size: CGSize) {
        self.position = Point(position)
        self.size = Size(size)
    }
    
    /// Creates a rectangle from a `CGRect`.
    ///
    /// - localizationKey: Rect(cgRect:)
    public init(_ cgRect: CGRect) {
        self.position = Point(cgRect.origin)
        self.size = Size(cgRect.size)
    }
    
    /// The `CGRect` value of the rectangle.
    ///
    /// - localizationKey: Size.cgRect
    public var cgRect: CGRect { return CGRect(origin: position.cgPoint, size: size.cgSize) }
}

extension CGRect {
    public init(origin: Point, size: Size) {
        self.init(origin: origin.cgPoint, size: size.cgSize)
    }
}
