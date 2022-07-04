//
//  Joint.swift
//  
//  Copyright © 2020 Apple Inc. All rights reserved.
//

import Foundation
import SPCCore
import SPCIPC

/// A joint, used to connect two sprites (or one sprite with the scene).
///
/// - localizationKey: Joint
public class Joint: MessageControl {
    
    fileprivate static var defaultNameCount = 0
    
    /// An id, used to identify a Joint. Read-only.
    ///
    /// - localizationKey: Joint.id
    public let id = UUID().uuidString
         
    /// The name of the joint.
    ///
    /// - localizationKey: Joint.name
    public var name: String
        
    public var suppressMessageSending: Bool = false
    
    /// The first sprite attached to the joint.
    ///
    /// - localizationKey: Joint.firstSprite
    public let firstSprite: Sprite
    
    /// The second sprite attached to the joint. If this value is `nil`, the system attaches `firstSprite` to the scene.
    ///
    /// - localizationKey: Joint.secondSprite
    public let secondSprite: Sprite?
        
    fileprivate init(name: String, from firstSprite: Sprite, to secondSprite: Sprite?) {
        if name.isEmpty {
            Joint.defaultNameCount += 1
            self.name = "\(type(of:self))\(Joint.defaultNameCount)"
        }
        else {
            self.name = name
        }
        
        self.firstSprite = firstSprite
        self.secondSprite = secondSprite
    }
    
    deinit {
        SceneProxy().deleteJoint(jointID: self.id)
    }
    
    /// Creates a joint that fuses two sprites together at a reference point.
    ///
    /// - parameter name: The joint’s name. If this is empty, the system assigns a name.
    /// - parameter firstSprite: The first sprite.
    /// - parameter secondSprite: The second sprite. If this value is `nil`, the system attaches `firstSprite` to the scene.
    /// - parameter anchor: The location of the connection between the two sprites.
    ///
    /// - localizationKey: Joint.fixed(name:from:to:at:)
    public static func fixed(name: String = "", from firstSprite: Sprite, to secondSprite: Sprite? = nil, at anchor: Point) -> FixedJoint {
        let joint = FixedJoint(name: name, from: firstSprite, to: secondSprite, at: anchor)
        
        SceneProxy().createFixedJoint(jointID: joint.id,
                                      from: joint.firstSprite.id,
                                      to: joint.secondSprite?.id,
                                      at: joint.anchor)
        return joint
    }
    
    /// Creates a joint that imposes a maximum distance between two sprites, as if they were connected by a rope.
    ///
    /// - parameter name: The joint’s name. If this is empty, the system assigns a name.
    /// - parameter firstSprite: The first sprite.
    /// - parameter firstAnchor: The connection for `firstSprite`.
    /// - parameter secondSprite: The second sprite. If this value is `nil`, the system attaches `firstSprite` to the scene.
    /// - parameter secondAnchor: The connection for `secondSprite`.
    ///
    /// - localizationKey: Joint.limit(name:from:at:to:at:)
    public static func limit(name: String = "", from firstSprite: Sprite, at firstAnchor: Point, to secondSprite: Sprite? = nil,  at secondAnchor: Point) -> LimitJoint {
        let joint = LimitJoint(name: name, from: firstSprite, at: firstAnchor, to: secondSprite, at: secondAnchor)
        
        SceneProxy().createLimitJoint(jointID: joint.id,
                                      from: joint.firstSprite.id,
                                      at: joint.firstAnchor,
                                      to: joint.secondSprite?.id,
                                      at: joint.secondAnchor)
        
        return joint
    }
    
    /// Creates a joint that pins together two sprites, allowing independent rotation.
    ///
    /// - parameter name: The joint’s name. If this is empty, the system assigns a name.
    /// - parameter firstSprite: The first sprite.
    /// - parameter secondSprite: The second sprite. If this value is `nil`, the system attaches `firstSprite` to the scene.
    /// - parameter axle: The location of the connection between the two sprites; the sprites rotate around this point.
    ///
    /// - localizationKey: Joint.pin(name:from:to:around:)
    public static func pin(name: String = "", from firstSprite: Sprite, to secondSprite: Sprite? = nil, around axle: Point) -> PinJoint {
        let joint = PinJoint(name: name, from: firstSprite, to: secondSprite, around: axle)
        
        SceneProxy().createPinJoint(jointID: joint.id,
                                    from: joint.firstSprite.id,
                                    to: joint.secondSprite?.id,
                                    at: joint.axle)
        
        return joint
    }
    
    /// Creates a joint that allows two sprites to slide along an axis.
    ///
    /// - parameter name: The joint’s name. If this is empty, the system assigns a name.
    /// - parameter firstSprite: The first sprite.
    /// - parameter secondSprite: The second sprite. If this value is `nil`, the system attaches `firstSprite` to the scene.
    /// - parameter anchor: The location of the connection between the two sprites.
    /// - parameter axis: A vector that defines the direction that the joint is allowed to slide.
    ///
    /// - localizationKey: Joint.sliding(name:from:to:at:axis:)
    public static func sliding(name: String = "", from firstSprite: Sprite, to secondSprite: Sprite? = nil, at anchor: Point, axis: Vector) -> SlidingJoint {
        let joint =  SlidingJoint(name: name, from: firstSprite, to: secondSprite, at: anchor, axis: axis)
        
        SceneProxy().createSlidingJoint(jointID: joint.id,
                                        from: joint.firstSprite.id,
                                        to: joint.secondSprite?.id,
                                        at: joint.anchor,
                                        axis: joint.axis)
        
        return joint
    }
    
    /// Creates a joint that simulates a spring connecting two sprites.
    ///
    /// - parameter name: The joint’s name. If this is empty, the system assigns a name.
    /// - parameter firstSprite: The first sprite.
    /// - parameter firstAnchor: The connection for `firstSprite`.
    /// - parameter secondSprite: The second sprite. If this value is `nil`, the system attaches `firstSprite` to the scene.
    /// - parameter secondAnchor: The connection for `secondSprite`.
    ///
    /// - localizationKey: Joint.spring(name:from:at:to:at:)
    public static func spring(name: String = "", from firstSprite: Sprite, at firstAnchor: Point, to secondSprite: Sprite? = nil, at secondAnchor: Point) -> SpringJoint {
        let joint = SpringJoint(name: name, from: firstSprite, at: firstAnchor, to: secondSprite, at: secondAnchor)
        
        SceneProxy().createSpringJoint(jointID: joint.id,
                                       from: joint.firstSprite.id,
                                       at: joint.firstAnchor,
                                       to: joint.secondSprite?.id,
                                       at: joint.secondAnchor)
        
        return joint
    }
}

 
extension Joint: Hashable, Equatable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }

    public static func ==(lhs: Joint, rhs: Joint) -> Bool {
        return lhs.id == rhs.id
    }
}

/// A  joint that fuses two sprites together at a reference point.
public class FixedJoint: Joint {
    
    /// The location of the connection between the two sprites.
    ///
    /// - localizationKey: FixedJoint.anchor
    public let anchor: Point
    
    init(name: String = "", from firstSprite: Sprite, to secondSprite: Sprite? = nil, at anchor: Point) {
        self.anchor = anchor
        super.init(name: name, from: firstSprite, to: secondSprite)
    }
}

/// A joint that imposes a maximum distance between two sprites, as if they were connected by a rope.
public class LimitJoint: Joint {
    
    /// The location of the connection for `firstSprite`.
    ///
    /// - localizationKey: LimitJoint.firstAnchor
    public let firstAnchor: Point
    
    /// The location of the connection for `secondSprite`.
    ///
    /// - localizationKey: LimitJoint.secondAnchor
    public let secondAnchor: Point
    
    /// The maximum distance allowed between the two sprites.
    ///
    /// - localizationKey: LimitJoint.maxLength
    public var maxLength: Double {
        didSet {
            guard !suppressMessageSending else { return }
            SceneProxy().setLimitJointMaxLength(id: self.id, maxLength: maxLength)
        }
    }
    
    init(name: String = "", from firstSprite: Sprite, at firstAnchor: Point, to secondSprite: Sprite?, at secondAnchor: Point) {
        self.firstAnchor = firstAnchor
        self.secondAnchor = secondAnchor
        self.maxLength = firstAnchor.distance(from: secondAnchor)
        super.init(name: name, from: firstSprite, to: secondSprite)
    }
}

/// A joint that pins together two sprites, allowing them to rotate around the joint’s axle.
public  class PinJoint: Joint {
    
    /// The location of the connection between the two sprites.
    ///
    /// The sprites rotate around the axle.
    ///
    /// - localizationKey: PinJoint.axle
    public let axle: Point
    
    /// The speed, in radians per second, at which the sprites are driven around the axle.
    ///
    /// The pin joint must have a nonnegative `axleFriction` to transfer rotation from the axle to the sprites.
    /// The default value is `0.0`.
    ///
    /// - localizationKey: PinJoint.rotationSpeed
    public var rotationSpeed = 0.0 {
        didSet {
            guard !suppressMessageSending else { return }
            SceneProxy().setPinJointRotationSpeed(id: self.id, speed: rotationSpeed)
        }
    }
    
    /// The amount of resistance between the sprites and the axle.
    ///
    /// This value must be between `0.0` and `1.0`.  If the value is `0.0`, the sprites rotate freely around the axle with no resistance.
    /// At `1.0` the sprites are fused to the axle, and cannot rotate on their own.
    /// If you set the pin joint’s `rotationSpeed`, then the `axleFriction` determines the amount of slippage between the axle and the sprites.
    /// A low value indicates that the sprites tend to slip easily, while a high value causes the rotation speed to more strongly drive the sprite’s rotation.
    /// The default is `0.0`.
    ///
    /// - localizationKey: PinJoint.axleFriction
    public var axleFriction = 0.0 {
        didSet {
            guard !suppressMessageSending else { return }
            SceneProxy().setPinJointAxleFriction(id: self.id, axleFriction: axleFriction)
        }
    }
    
    /// A Boolean value that indicates whether the pin joint’s rotation is limited to a specified range. The default is `false`.
    ///
    /// - localizationKey: PinJoint.shouldEnableLimits
    public var shouldEnableLimits = false {
        didSet {
            guard !suppressMessageSending else { return }
            SceneProxy().setPinJointEnableAngleLimits(id: self.id, enableLimits: shouldEnableLimits)
        }
    }
    /// The smallest angle allowed for the pin joint, in radians. The default value is `0.0`.
    ///
    /// - localizationKey: PinJoint.lowerAngleLimit
    public var lowerAngleLimit = 0.0 {
        didSet {
            guard !suppressMessageSending else { return }
            SceneProxy().setPinJointLowerAngleLimit(id: self.id, lowerAngleLimit: lowerAngleLimit)
        }
    }
    
    /// The largest angle allowed for the point joint, in radians. The default value is `0.0`.
    ///
    /// - localizationKey: PinJoint.upperAngleLimit
    public var upperAngleLimit = 0.0 {
        didSet {
            guard !suppressMessageSending else { return }
            SceneProxy().setPinJointUpperAngleLimit(id: self.id, upperAngleLimit: upperAngleLimit)
        }
    }
    
    init(name: String = "", from firstSprite: Sprite, to secondSprite: Sprite? = nil, around axle: Point) {
        self.axle = axle
        super.init(name: name, from: firstSprite, to: secondSprite)
    }
}

/// A joint that allows two sprites to slide along an axis.
public class SlidingJoint: Joint {

    /// The location of the connection between the sprites and the axis.
    ///
    /// - localizationKey: SlidingJoint.anchor
    public let anchor: Point
    
    /// A vector that defines the direction that the sprites can slide.
    ///
    /// - localizationKey: SlidingJoint.axis
    public let axis: Vector
    
    /// A Boolean value that indicates whether the sliding joint is restricted so that the objects may only slide a defined distance away from each other. The default is `false`.
    ///
    /// - localizationKey: SlidingJoint.shouldEnableLimits
    public var shouldEnableLimits = false {
        didSet {
            guard !suppressMessageSending else { return }
            SceneProxy().setSlidingJointEnableDistanceLimits(id: self.id, enableLimits: shouldEnableLimits)
        }
    }
    
    /// The minimum distance allowed between the first and second sprite.
    ///
    /// This measures the distance from the `firstSprite` to the `secondSprite` along the axis.
    /// A negative value indicates that `firstSprite` can move past `secondSprite` along the axis.
    /// The default is `0.0`. This value must be less than `maximumDistanceLimit`.
    ///
    /// - localizationKey: SlidingJoint.minimumDistanceLimit
    public var minimumDistanceLimit = 0.0 {
        didSet {
            guard !suppressMessageSending else { return }
            SceneProxy().setSlidingJointMinimumDistanceLimit(id: self.id, minimumDistanceLimit: minimumDistanceLimit)
        }
    }
    
    /// The maximum distance allowed between the first and second sprite.
    ///
    /// This measures the distance from the `firstSprite` to the `secondSprite` along the axis.
    /// A negative value indicates that `firstSprite` can move past `secondSprite` along the axis.
    /// The default is `0.0`. This value must be greater than `minimumDistanceLimit`.
    ///
    /// - localizationKey: SlidingJoint.maximumDistanceLimit
    public var maximumDistanceLimit = 0.0 {
        didSet {
            guard !suppressMessageSending else { return }
            SceneProxy().setSlidingJointMaximumDistanceLimit(id: self.id, maximumDistanceLimit: maximumDistanceLimit)
        }
    }
    
    init(name: String = "", from firstSprite: Sprite, to secondSprite: Sprite? = nil, at anchor: Point, axis: Vector) {
        self.anchor = anchor
        self.axis = axis
        super.init(name: name, from: firstSprite, to: secondSprite)
    }
}

/// A joint that simulates a spring connecting two sprites.
public class SpringJoint: Joint {
    
    /// The location of the connection for `firstSprite`.
    ///
    /// - localizationKey: SpringJoint.firstAnchor
    public let firstAnchor: Point
    
    /// The location of the connection for `secondSprite`.
    ///
    /// - localizationKey: SpringJoint.secondAnchor
    public let secondAnchor: Point
    
    
    /// Defines how the spring’s motion should be damped due to friction.
    ///
    /// If the value is less than `1.0` then the system is underdamped.
    /// The spring oscillates before eventually coming to rest.
    /// Increasing the value increases the energy loss with each oscillation.
    ///
    /// If the value is `1.0` then the system is critically damped.
    /// The spring returns to its original size as quickly as possible without any oscillation.
    ///
    /// If the value is greater than `1.0`, the system is over damped.
    /// The system slowly returns to its original size without any oscillation.

    /// The default value is `0.0`.
    ///
    /// - localizationKey: SpringJoint.damping
    public var damping = 0.0 {
        didSet {
            guard !suppressMessageSending else { return }
            SceneProxy().setSpringJointDamping(id: self.id, damping: damping)
        }
    }
    
    /// Defines the frequency or stiffness of the spring.
    ///
    /// If the `damping` property is less than `1.0` then this is the frequency of the
    /// resulting oscillations.
    ///
    /// If the `damping` property is equal to `1.0` then `1 second / frequency` is the amount
    /// of time it takes the spring to return to its original size. For example, a frequency of `0.5` will take
    /// two seconds to come to rest, while a frequency of `10` takes 1/10th of a second.
    ///
    /// The default value is `0.0`, creating a rigid joint between the two sprites.
    ///
    /// - localizationKey: SpringJoint.frequency
    public var frequency = 0.0 {
        didSet {
            guard !suppressMessageSending else { return }
            SceneProxy().setSpringJointFrequency(id: self.id, frequency: frequency)
        }
    }
    
    init(name: String = "", from firstSprite: Sprite, at firstAnchor: Point, to secondSprite: Sprite? = nil, at secondAnchor: Point) {
        self.firstAnchor = firstAnchor
        self.secondAnchor = secondAnchor
        super.init(name: name, from: firstSprite, to: secondSprite)
    }
}
