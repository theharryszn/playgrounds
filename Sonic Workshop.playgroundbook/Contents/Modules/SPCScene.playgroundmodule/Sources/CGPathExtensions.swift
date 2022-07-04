//
//  CGPathExtensions.swift
//  
//  Copyright © 2020 Apple Inc. All rights reserved.
//

import CoreGraphics

struct PathElement {
    var type : CGPathElementType
    var points : Array<CGPoint>
}

func degrees2radians(_ degrees: CGFloat) -> CGFloat {
    return CGFloat.pi * degrees/180
}

extension CGPath {
    typealias BodyType = @convention(block) (CGPathElement) -> Void
    // Get the actual points in the path
    func points() -> Array<CGPoint> {
        var bezierPoints = Array<CGPoint>()
        self.forEach{ (element: CGPathElement) in
            let numberOfPoints: Int = {
                switch element.type {
                case .moveToPoint, .addLineToPoint:
                    return 1
                case .addQuadCurveToPoint:
                    return 2
                case .addCurveToPoint:
                    return 3
                case .closeSubpath:
                    return 0
                @unknown default:
                    fatalError("Unknown CGPathElementType, \(element.type)")
                }
            }()
            for index in 0..<numberOfPoints {
                let point = element.points[index]
                bezierPoints.append(point)
            }
        }
        
        return bezierPoints
    }
    
    // Get just the elements, preserves path element type
    func pathElements() -> Array<PathElement> {
        var elements = Array<PathElement>()
        self.forEach { (element: CGPathElement) in
            // CGPathElements are only valid in the context of the apply() function. We need to exfiltrate their values to properly access them later.
            let pe = PathElement(type: element.type, points: Array<CGPoint>(arrayLiteral:element.points[0]))
            elements.append(pe)
        }
        return elements
    }
    
    private func forEach(_ body: @escaping BodyType) {
        func callback(info: UnsafeMutableRawPointer?, element: UnsafePointer<CGPathElement>) {
            let body = unsafeBitCast(info, to: BodyType.self)
            body(element.pointee)
        }
        let unsafeBody = unsafeBitCast(body, to: UnsafeMutableRawPointer.self)
        self.apply(info: unsafeBody, function: callback)
    }
    
    private static func pointsForPolygonWith(sides: Int, center: CGPoint, radius: CGFloat, angularOffset: CGFloat = 0) -> [CGPoint] {
        let angle = degrees2radians(360 / CGFloat(sides))
        var i = sides
        var points = [CGPoint]()
        while points.count <= sides {
            let point = CGPoint(x: center.x - radius * cos(angle * CGFloat(i) + degrees2radians(angularOffset)),
                                y: center.y - radius * sin(angle * CGFloat(i) + degrees2radians(angularOffset)))
            points.append(point)
            i -= 1
        }
        return points
    }
    
    static func starPath(center: CGPoint, radius: CGFloat, numberOfPoints: Int, sharpness: CGFloat) -> CGPath {
        let offset = CGFloat(360 / numberOfPoints / 2)
        let path = CGMutablePath()
        let innerPoints = pointsForPolygonWith(sides: numberOfPoints, center: center, radius: radius)
        let outerPoints = pointsForPolygonWith(sides: numberOfPoints, center: center, radius: radius * sharpness, angularOffset: offset)
        var i = 0
        path.move(to: innerPoints[0])
        for innerPoint in innerPoints {
            path.addLine(to: outerPoints[i])
            path.addLine(to: innerPoint)
            i += 1
        }
        path.closeSubpath()
        return path
    }
    
    static func polygonPath(center: CGPoint, radius: CGFloat, sides: Int) -> CGPath {
        let path = CGMutablePath()
        let points = pointsForPolygonWith(sides: sides, center: center, radius: radius)
        path.move(to: points[0])
        for point in points.dropFirst() {
            path.addLine(to: point)
        }
        path.closeSubpath()
        return path
    }
}

extension CGPoint : Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.x)
        hasher.combine(self.y)
    }
}
