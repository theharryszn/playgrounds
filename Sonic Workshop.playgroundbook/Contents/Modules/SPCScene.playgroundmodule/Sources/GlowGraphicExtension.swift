//
//  GlowGraphicExtension.swift
//  
//  Copyright © 2020 Apple Inc. All rights reserved.
//

import Foundation

extension Graphic {
    /// Causes the Graphic to glow by animating the opacity of a graphic blur effect a given number of times, or indefinitely.
    ///
    /// - Parameter radius: The radius of the glow, in points.
    /// - Parameter period: The period of each glow, in seconds.
    /// - Parameter count: The number of times to repeat the glow; pass (`-1`) is to pulsate indefinitely.
    ///
    /// - localizationKey: Graphic.glow(radius:period:count:)
    public func glow(radius: Double = 30.0, period: Double = 0.5, count: Int = 1) {
        SceneProxy().glow(id: self.id, radius: radius, period: period, count: count)
    }
}
