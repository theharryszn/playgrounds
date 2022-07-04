//
//  SKActionExtension.swift
//  
//  Copyright © 2020 Apple Inc. All rights reserved.
//

import Foundation
import SpriteKit
import SPCCore

extension SKAction {
    
    /// Creates an animation from an image or set of images, at a specified interval.
    ///
    /// - Parameter images: An image or set of images to animate.
    /// - Parameter timePerFrame: The amount of time each image appears within the animation.
    ///
    /// - localizationKey: SKAction.createAnimation(images:timePerFrame:)
    class func createAnimation(fromImages images: [UIImage], timePerFrame: TimeInterval) -> SKAction {
        var animation = [SKTexture]()
        for element in images {
            animation.append(SKTexture(image: element))
        }
        let animationCycle = SKAction.animate(with: animation, timePerFrame: timePerFrame)
        return animationCycle
    }
    
    /// Creates an animation from an image or set of images, at a specified interval.
    ///
    /// - Parameter urls: An image or set of images to animate from URLs.
    /// - Parameter timePerFrame: The amount of time each image appears within the animation.
    ///
    /// - localizationKey: SKAction.createAnimation(urls:timePerFrame:)
    public class func createAnimation(fromResourceURLs urls: [String], timePerFrame: TimeInterval) -> SKAction {
        var animation = [SKTexture]()
        
        for name in urls {
            let image = Image(imageLiteralResourceName: name)
            
            animation.append(SKTexture(image: image.uiImage))
        }
        
        let animationCycle = SKAction.animate(with: animation, timePerFrame: timePerFrame)
        
        return animationCycle
    }
    
    /// Creates an action that moves a graphic around the center point of an elliptical orbit. The direction of rotation is chosen at random.
    ///
    /// - Parameter x: The distance of the orbital path from the origin along the x-axis.
    /// - Parameter y: The distance of the orbital path from the origin along the y-axis.
    /// - Parameter period: The period of the orbit in seconds.
    ///
    /// - localizationKey: SKAction.orbitAction(x:y:period:)
    public class func orbit(x: CGFloat, y: CGFloat, period: Double = 4.0) -> SKAction {
        // x, y
        let center = CGPoint(x: 0, y: 0)
        let rect = CGRect(x: center.x - x, y: center.y - y, width: x * 2.0, height: y * 2.0)
        let ovalPath = UIBezierPath(ovalIn: rect)
        let reversed = randomInt(from: 0, to: 1) == 1
        
        var orbitAction = SKAction.follow(ovalPath.cgPath,
                                          asOffset: false ,
                                          orientToPath: true,
                                          duration: period)
        if reversed {
            orbitAction = orbitAction.reversed()
        }
        
        return .repeatForever(orbitAction)
    }

    /// Creates an action that pulsates a node by increasing and decreasing its scale a given number of times.
    ///
    /// - Parameter period: The period of each pulsation in seconds.
    /// - Parameter count: The number of pulsations; omit to pulsate indefinitely.
    ///
    /// - localizationKey: SKAction.pulsate(period:count:)
    public class func pulsate(period: Double = 5.0, count: Int = 0) -> SKAction {
        
        let originalScale: CGFloat = 1
        let scale = originalScale * 1.5
        let pulseOut = SKAction.scale(to: scale, duration: period)
        let pulseIn = SKAction.scale(to: originalScale, duration: period)
        pulseOut.timingMode = SKActionTimingMode.easeOut
        pulseIn.timingMode = SKActionTimingMode.easeOut
        
        let sequence = SKAction.sequence([pulseOut, pulseIn])
        let action: SKAction
        if count == 0 {
            action = .repeatForever(sequence)
        }
        else {
            action = .repeat(sequence, count: count)
        }
        return action
    }
    
    /// Creates an action that shakes a node for the given number of seconds.
    ///
    /// - Parameter duration: The time in seconds to shake the node.
    ///
    /// - localizationKey: SKAction.shake(duration:)
    public class func shake(duration: Double = 2.0) -> SKAction {
        
        let amplitudeX: Float = 10
        let amplitudeY: Float = 6
        let numberOfShakes = duration / 0.04
        var actionsArray:[SKAction] = []
        for _ in 1...Int(numberOfShakes) {
            let moveX = Float(arc4random_uniform(UInt32(amplitudeX))) - amplitudeX / 2
            let moveY = Float(arc4random_uniform(UInt32(amplitudeY))) - amplitudeY / 2
            let shakeAction = SKAction.moveBy(x: CGFloat(moveX), y: CGFloat(moveY), duration: 0.02)
            shakeAction.timingMode = SKActionTimingMode.easeOut
            actionsArray.append(shakeAction)
            actionsArray.append(shakeAction.reversed())
        }
        
        return .sequence(actionsArray)
    }
    
    /// Creates an action that plays an audio file.
    ///
    /// - Parameter fileName: The name of the audio file.
    ///
    /// - localizationKey: SKAction.audioPlayAction(fileNamed:)
    fileprivate class func audioPlayAction(fileNamed fileName: String) -> SKAction {
        
        let name = URL(fileURLWithPath: fileName).deletingPathExtension().lastPathComponent
        
        return SKAction.customAction(withDuration: 0.0) { node, time in
            
            if let audioNode = node.childNode(withName: name) {
                // Already has an audio node with the same name, so just play it.
                audioNode.run(SKAction.play())
            } else {
                // Add and play an audio node.
                let audioNode = SKAudioNode(fileNamed: fileName)
                audioNode.name = name
                audioNode.autoplayLooped = false
                node.addChild(audioNode)
                audioNode.run(SKAction.play())
            }
        }
    }
    
    
    fileprivate class func spiral(startRadius: CGFloat, endRadius: CGFloat, angle
        totalAngle: CGFloat, centerPoint: CGPoint, duration: TimeInterval) -> SKAction {
        
        func pointOnCircle(angle: CGFloat, radius: CGFloat, center: CGPoint) -> CGPoint {
            return CGPoint(x: center.x + radius * cos(angle),
                           y: center.y + radius * sin(angle))
        }
        
        // The distance the node travels away from/toward the center point, per revolution.
        let radiusPerRevolution: CGFloat = 5.0
        
        let action = SKAction.customAction(withDuration: duration) { node, time in
            // Current angle.
            let θ = totalAngle * time / CGFloat(time)
            
            // The equation: r = a + bθ
            let radius = startRadius + radiusPerRevolution * θ
            
            node.position = pointOnCircle(angle: θ, radius: radius, center: centerPoint)
        }
        
        return action
    }
    
    /// Creates an action that continuously rotates a node with a given period of rotation.
    ///
    /// - Parameter period: The period of each rotation in seconds.
    ///
    /// - localizationKey: SKAction.spin(period:)
    public class func spin(period: Double = 2.0) -> SKAction {
        
        let action = SKAction.rotate(byAngle: CGFloat.pi * 2.0, duration: max(period, 0.1))
        return .repeatForever(action)
        
    }

}
