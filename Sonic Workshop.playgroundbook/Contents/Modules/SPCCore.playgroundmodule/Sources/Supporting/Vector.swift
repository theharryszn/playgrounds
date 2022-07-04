//
//  Vector.swift
//  
//  Copyright © 2020 Apple Inc. All rights reserved.
//

import Foundation
import CoreGraphics

/// A structure that contains a two-dimensional vector.
///
/// - localizationKey: Vector
public struct Vector: Equatable, Codable {
    public var dx: Double
    public var dy: Double
    
    /// Creates a vector with a `dx` and `dy`.
    ///
    /// - Parameter dx: Dimensional *x* value.
    /// - Parameter dy: Dimensional *y* value.
    ///
    /// - localizationKey: Vector(dx:dy:)
    public init(dx: Double, dy: Double) {
        self.dx = dx
        self.dy = dy
    }
    
    /// Creates a vector with a `CGVector`.
    ///
    /// - localizationKey: Vector(_{cgvector}:)
    public init(_ vector: CGVector) {
        self.dx = Double(vector.dx)
        self.dy = Double(vector.dy)
    }
}
