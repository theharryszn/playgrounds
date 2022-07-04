//
//  Size.swift
//  
//  Copyright © 2020 Apple Inc. All rights reserved.
//

import CoreGraphics
import PlaygroundSupport

/// `Size` is a struct for specifying the width and height of a graphic.
///
/// - localizationKey: Size
public struct Size: Codable {
    
    /// The size whose width and height are both zero.
    ///
    /// - localizationKey: Size.zero
    public static let zero = Size(width: 0, height: 0)
    
    /// The width value of the size.
    ///
    /// - localizationKey: Size.width
    public var width: Double
    
    /// The height value of the size.
    ///
    /// - localizationKey: Size.height
    public var height: Double
    
    /// Creates a size with a width and a height from `Double` values.
    ///
    /// - Parameter width: The Size width.
    /// - Parameter height: The Size height.
    ///
    /// - localizationKey: Size(width{double}:height{double}:)
    public init(width: Double, height: Double) {
        self.width = width
        self.height = height
    }
    
    /// Creates a size with a width and a height from `Float` values.
    ///
    /// - localizationKey: Size(width{float}:height{float}:)
    public init(width: Float, height: Float) {
        self.width = Double(width)
        self.height = Double(height)
    }
    
    /// Creates a size with a width and a height from `CGFloat` values.
    ///
    /// - localizationKey: Size(width{cgfloat}:height{cgfloat}:)
    public init(width: CGFloat, height: CGFloat) {
        self.width = Double(width)
        self.height = Double(height)
    }
    
    /// Creates a size with a width and a height from `Int` values.
    ///
    /// - localizationKey: Size(width{int}:height{int}:)
    public init(width: Int, height: Int) {
        self.width = Double(width)
        self.height = Double(height)
    }
    
    /// Creates a size with a `CGVector`.
    ///
    /// - localizationKey: Size(_{vector}:)
    public init(vector: CGVector) {
        self.width = Double(vector.dx)
        self.height = Double(vector.dy)
    }
    
    /// Creates a size with a `CGSize`.
    ///
    /// - localizationKey: Size(_{cgsize}:)
    public init(_ cgSize: CGSize) {
        self.width = Double(cgSize.width)
        self.height = Double(cgSize.height)
    }
    
    /// The `CGSize` value of the size.
    ///
    /// - localizationKey: Size.cgSize
    public var cgSize: CGSize { return CGSize(width: CGFloat(width), height: CGFloat(height)) }
}

public extension CGSize {
    init(_ size: Size) {
        self.init()
        self.width = CGFloat(size.width)
        self.height = CGFloat(size.height)
    }
    
    var size: Size {
        return Size(width: self.width, height: self.height)
    }
}

extension Size: PlaygroundValueTransformable {
    
    public var playgroundValue: PlaygroundValue? {
        return .array([.floatingPoint(width), .floatingPoint(height)])
    }
    
    public static func from(_ playgroundValue: PlaygroundValue) -> PlaygroundValueTransformable? {
        guard
            case .array(let components) = playgroundValue,
            components.count == 2,
            case .floatingPoint(let width) = components[0],
            case .floatingPoint(let height) = components[1]
            
            else { return nil }
        
        return Size(width: width, height: height)
    }
}


