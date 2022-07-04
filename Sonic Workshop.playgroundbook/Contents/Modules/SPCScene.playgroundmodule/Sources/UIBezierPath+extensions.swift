//
//  UIBezierPath+extensions.swift
//  
//  Copyright © 2020 Apple Inc. All rights reserved.
//

import Foundation
import UIKit

extension UIBezierPath
{
    public convenience init(starIn rect: CGRect, points: Int, sharpness: CGFloat = 1.4) {
        let midpoint = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2 / sharpness
        let path = CGPath.starPath(center: midpoint, radius: radius, numberOfPoints: points, sharpness: sharpness)
        self.init(cgPath: path)
    }
    
    public convenience init(polygonIn rect: CGRect, sides: Int) {
        let midpoint = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        let path = CGPath.polygonPath(center: midpoint, radius: radius, sides: sides)
        self.init(cgPath: path)
    }
}


