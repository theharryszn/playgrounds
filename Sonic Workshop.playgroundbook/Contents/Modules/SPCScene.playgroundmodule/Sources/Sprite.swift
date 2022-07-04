//
//  Sprite.swift
//  
//  Copyright © 2020 Apple Inc. All rights reserved.
//

import Foundation
import SpriteKit
import SPCCore

/// A Sprite is a type of graphic object, made from an image or string, that can be placed on the scene.
///
/// - localizationKey: Sprite
open class Sprite: Graphic {
    
    fileprivate static var defaultNameCount: Int = 1
    
    func updateMotionState(from newSprite: Sprite) {
        assert(newSprite.id == self.id, "*** You can only update using a sprite instance with a matching ID.")
        
        self.suppressMessageSending = true
        
        self.position = newSprite.position
        self.velocity = newSprite.velocity
        self.rotationalVelocity = newSprite.rotationalVelocity
        
        self.suppressMessageSending = false
    }
    
    /// The function that’s called when the sprite collides with another sprite.
    ///
    /// The `collision` parameter passed to the handler contains information about the collision:
    ///
    /// `collision.spriteA` is the current sprite.
    /// `collision.spriteB` is the sprite that collided with `spriteA`.
    ///
    /// - localizationKey: Sprite.onCollisionHandler
    public var onCollisionHandler: ((Collision) -> Void)?
    
    /// Sets the function that’s called when the sprite collides with another sprite.
    /// - parameter handler: The function to be called when a collision occurs.
    ///
    /// - localizationKey: Sprite.setOnCollisionHandler(_:)
    public func setOnCollisionHandler(_ handler: @escaping ((Collision) -> Void)) {
        onCollisionHandler = handler
    }
    
    /// Indicates whether gravity affects the physics body.
    ///
    /// - localizationKey: Sprite.isAffectedByGravity
    public var isAffectedByGravity: Bool = false {
        didSet {
            guard !suppressMessageSending else { return }
            SceneProxy().setAffectedByGravity(id: id, gravity: isAffectedByGravity)
        }
    }
    
    /// A Boolean value used to indicate if the Sprite should move in response to the physics simulation. The default is `true`: the sprite moves.
    ///
    /// - localizationKey: Sprite.isDynamic
    public var isDynamic: Bool = true {
        didSet {
            guard !suppressMessageSending else { return }
            SceneProxy().setIsDynamic(id: id, dynamic: isDynamic)
        }
    }
    
    /// Indicates whether angular forces and impulses affect the physics body.
    ///
    /// - localizationKey: Sprite.allowsRotation
    public var allowsRotation: Bool = false {
        didSet {
            guard !suppressMessageSending else { return }
            SceneProxy().setAllowsRotation(id: id, rotation: allowsRotation)
        }
    }
    
    /// Determines how much energy the sprite loses when it bounces off another object.
    ///
    /// - localizationKey: Sprite.bounciness
    public var bounciness: Double = 0.2 {
        didSet {
            guard !suppressMessageSending else { return }
            SceneProxy().setBounciness(id: id, bounciness: bounciness)
        }
    }
    
    /// The roughness of the surface of the sprite.
    ///
    /// Use this property to apply a frictional force to sprites.
    /// The property must be a value between `0.0` and `1.0`. The default value is `0.2`.
    ///
    /// - localizationKey: Sprite.friction
    public var friction: Double = 0.2 {
        didSet {
            guard !suppressMessageSending else { return }
            SceneProxy().setFriction(id: id, friction: friction)
        }
    }
    
    /// The density of the sprite.
    ///
    /// The sprite’s mass is determined based on its size and its density.
    /// The default is `1.0`
    ///
    /// - localizationKey: Sprite.density
    public var density: Double = 1.0 {
        didSet {
            guard !suppressMessageSending else { return }
            SceneProxy().setDensity(id: id, density: density)
        }
    }
    
    /// A property that reduces the body’s linear velocity as it moves.
    ///
    /// Use this property to simulate fluid or air friction forces on the sprite.
    /// The property must be a value between `0.0` and `1.0`.
    /// The default value is `0.1`.
    /// If the value is `0.0`, no drag is applied to the object.
    ///
    /// - localizationKey: Sprite.drag
    public var drag: Double = 0.1 {
        didSet {
            guard !suppressMessageSending else { return }
            SceneProxy().setDrag(id: id, drag: drag)
        }
    }
    
    /// A property that reduces the body’s rotational velocity over time.
    ///
    /// Use this property to simulate fluid or air friction forces on the sprite.
    /// The property must be a value between `0.0` and `1.0`.
    /// The default value is `0.1`.
    /// If the value is `0.0`, no rotational drag is applied to the object.
    ///
    /// - localizationKey: Sprite.rotationalDrag
    public var rotationalDrag: Double = 0.1 {
        didSet {
            guard !suppressMessageSending else { return }
            SceneProxy().setRotationalDrag(id: id, drag: rotationalDrag)
        }
    }
    
    /// A vector that indicates both the direction and speed of the sprite’s motion within the physics engine.
    ///
    /// This is the velocity of the sprite calculated by the physics simulation.
    /// Calling the `move(to: duration:)` or `moveBy(x:, y:, duration:)` does not affect the simulation's velocity.
    /// Avoid calling the `move` methods or setting the sprite’s `position`,
    /// if the sprite participates in the physics simulation.
    ///
    /// - localizationKey: Sprite.velocity
    public var velocity: Vector = Vector(dx: 0.0, dy: 0.0) {
        didSet {
            guard !suppressMessageSending else { return }
            SceneProxy().setVelocity(id: id, velocity: CGVector(dx: velocity.dx, dy: velocity.dy))
        }
    }
    
    /// The sprite’s rotational velocity in radians per second.
    ///
    /// This is the rotational (angular) velocity of the sprite calculated by the physics simulation.
    /// Calling `rotate(byAngle:duration:)` or `rotate(toAngle:duration:)` does not affect the simulation's rotational velocity.
    /// Avoid calling the `rotate` methods if the sprite participates in the physics simulation.
    ///
    /// - localizationKey: Sprite.rotationalVelocity
    public var rotationalVelocity: Double = 0.0 {
        didSet {
            guard !suppressMessageSending else { return }
            SceneProxy().setRotationalVelocity(id: id, rotationalVelocity: rotationalVelocity)
        }
    }
    
    /// An option set that defines which categories this sprite belongs to.
    ///
    /// Every sprite can be assigned to up to 32 different categories.
    /// Define the values as described in `InteractionCategory`.
    /// This property is used in conjunction with  `collisionNotificationCategories` and
    /// `collisionCategories` to determine how sprites can interact.
    ///
    /// The default value is `.all`, indicating that the sprite interacts with all categories.
    ///
    /// - localizationKey: Sprite.interactionCategory
    public var interactionCategory: InteractionCategory = .all {
        didSet {
            guard !suppressMessageSending else { return }
            SceneProxy().setInteractionCategory(id: id, interactionCategory: interactionCategory)
        }
    }
    
    /// An option set that determines whether sprites generate collision notifications when they touch.
    ///
    /// When two sprites touch or overlap, the system compares the intersection of the sprite’s `interactionCategory` with the
    /// contacting sprite’s `collisionNotificationCategories`.
    /// If the intersection contains a value, the system sends a collision notification to the scene.
    ///
    /// The default value is  `.all`, indicating that this sprite generates collision notifications when it touches any other sprite.
    ///
    /// - localizationKey: Sprite.collisionNotificationCategories
    public var collisionNotificationCategories: InteractionCategory = .all {
        didSet {
            guard !suppressMessageSending else { return }
            SceneProxy().setContactCategories(id: id, contactCategories: collisionNotificationCategories)
        }
    }
    
    /// An option set that determines whether the physics engine automatically calculates the result of a collision when this sprite touches another sprite.
    ///
    /// When two sprites contact, a collision may occur.
    /// The system compares the intersection of the sprite’s `interactionCategory` with the
    /// contacting sprite’s `collisionCategories`.
    /// If the intersection contains a value, the sprite is affected by the collision.
    /// Note that one sprite may be affected by the collision, while the other is not.
    ///
    /// Collisions prevent the objects from interpenetrating each other.
    /// When one sprite  strikes another, SpriteKit automatically computes the results of the collision
    /// and applies impulse to the sprites affected by the collision.
    ///
    /// The default value is  `.all`, indicating that the sprite is affected by collisions with all other sprites..
    ///
    /// - localizationKey: Sprite.collisionCategories
    public var collisionCategories: InteractionCategory = .all {
        didSet {
            guard !suppressMessageSending else { return }
            SceneProxy().setCollisionCategories(id: id, collisionCategories: collisionCategories)
        }
    }
    
    /// The physics body’s velocity vector, measured in meters per second.
    ///
    /// - Parameter x: Sets the velocities *x* direction.
    /// - Parameter y: Sets the velocities *y* direction.
    ///
    /// - localizationKey: Sprite.setVelocity(x:y:)
    public func setVelocity(x: Double, y: Double) {
        guard !suppressMessageSending else { return }
        let velocity = CGVector(dx: x, dy: y)
        SceneProxy().setVelocity(id: id, velocity: velocity)
    }
    
    /// Applies an impulse to a Sprite.
    ///
    /// - Parameter x: Applies an impulse in the *x* direction.
    /// - Parameter y: Applies an impulse in the *y* direction.
    ///
    /// - localizationKey: Sprite.applyImpulse(x:y:)
    public func applyImpulse(x: Double, y: Double) {
        let vector = CGVector(dx: CGFloat(x), dy: CGFloat(y))
        SceneProxy().applyImpulse(id: id, vector: vector)
    }
    
    /// Creates a Sprite made up of a single image that repeats in a tiled arrangement
    /// of rows and columns.
    ///
    /// - Parameter image: The image to be repeated (tiled).
    /// - Parameter columns: The number of times the image is repeated horizontally
    /// - Parameter rows: The number of times the image is repeated vertically
    /// - Parameter isDynamic: An optional Boolean value that indicates if the Sprite should
    /// move in response to the physics simulation. The default is false
    /// (the sprite won’t move).
    ///
    /// - localizationKey: Sprite.setTiledImage(image:, columns:, rows:, isDynamic:)
    public func setTiledImage(image: Image, columns: Int, rows: Int, isDynamic: Bool = false) {
        SceneProxy().setTiledImage(id: self.id, image: image, columns: columns, rows: rows, isDynamic: isDynamic)
    }
    
    /// Applies a constant force to a Sprite over a duration of seconds.
    ///
    /// - Parameter x: Applies force in the *x* direction.
    /// - Parameter y: Applies force in the *y* direction.
    /// - Parameter duration: How long the force is applied, in seconds.
    ///
    /// - localizationKey: Sprite.applyForce(x:y:duration:)
    public func applyForce(x: Double, y: Double, duration: Double) {
        let vector = CGVector(dx: CGFloat(x), dy: CGFloat(y))
        SceneProxy().applyForce(id: id, vector: vector, duration: duration)
    }
    
    /// Creates a Sprite with a specified image and name.
    /// Example usage:
    /// ```
    /// let cupcake = Sprite(image: #imageLiteral(resourceName: \"gem2.png\"), name: \"cupcake\")
    /// ```
    ///
    /// - Parameter image: Image
    /// - Parameter name: String
    ///
    /// - localizationKey: Sprite(image:name:)
    public convenience init(image: Image, name: String = "") {
        if name == "" {
            self.init(graphicType: .sprite, name: "sprite" + String(Sprite.defaultNameCount))
            Sprite.defaultNameCount += 1
        } else {
            self.init(graphicType: .sprite, name: name)
        }
        self.image = image
        /*
         Manually sending a message here, as setting a property on a struct
         from within one of its own initializers won’t trigger the didSet property.
         */
        SceneProxy().setImage(id: id, image: image)
    }
    
    /// Creates a Sprite with a specified shape, color, gradient, and name.
    /// Example usage:
    /// ````
    /// let pentagon = Sprite(shape: .polygon(radius: 50, sides: 5), color: .red, gradientColor: .yellow, name: \"pentagon\")
    /// ````
    /// - Parameter shape: The shape of the Sprite.
    /// - Parameter color: The fill color.
    /// - Parameter gradientColor: A secondary gradient color.
    /// - Parameter name: An optional name you can give the Sprite; you may also leave this blank.
    ///
    /// - localizationKey: Sprite(shape:color:gradientColor:name:)
    public convenience init(shape: Shape, color: Color, gradientColor: Color? = nil, name: String = "") {
        if name == "" {
            self.init(graphicType: .sprite, name: "sprite" + String(Sprite.defaultNameCount))
            Sprite.defaultNameCount += 1
        } else {
            self.init(graphicType: .sprite, name: name)
        }
        updateShape(shape: shape, color: color, gradientColor: gradientColor ?? color)
    }
    
    /// Creates a tiled Sprite with a specified image, name, and number of columns and rows.
    /// Example usage:
    /// ````
    /// let wall = Sprite(image: #imageLiteral(resourceName: \"wall1.png\"), name: \"wall\", columns: \"12\", rows: \"1\")
    /// ````
    /// - Parameter image: An image you choose for the Sprite.
    /// - Parameter name: A name you give to the Sprite.
    /// - Parameter columns: How many columns of sprites you want.
    /// - Parameter rows: How many rows of sprites you want.
    /// - Parameter isDynamic: An optional Boolean value that indicates if the Sprite should move in response to the physics simulation. The default is `false` (the sprite won’t move).
    ///
    /// - localizationKey: Sprite(image:name:columns:rows:isDynamic:)
    public convenience init(image: Image, columns: Int, rows: Int, isDynamic: Bool = false, name: String = "") {
        if name == "" {
            self.init(graphicType: .sprite, name: "surface" + String(Sprite.defaultNameCount))
            Sprite.defaultNameCount += 1
        } else {
            self.init(graphicType: .sprite, name: name)
        }

        suppressMessageSending = true
        self.image = image
        suppressMessageSending = false

        SceneProxy().setTiledImage(id: id, image: image, columns: columns, rows: rows, isDynamic: isDynamic)
    }
    
    static func ==(lhs: Sprite, rhs: Sprite) -> Bool {
        return lhs.id == rhs.id
    }

}
