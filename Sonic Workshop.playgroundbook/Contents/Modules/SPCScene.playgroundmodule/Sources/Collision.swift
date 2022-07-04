//
//  Collision.swift
//  
//  Copyright © 2020 Apple Inc. All rights reserved.
//
import SpriteKit
import SPCCore
import SPCIPC

/// A Collision holds information about when two sprites collide in the scene.
///
/// - localizationKey: Collision
public struct Collision: Equatable {
    
    /// One of the sprites in the collision.
    ///
    /// - localizationKey: Collision.spriteA
    public var spriteA: Sprite
    
    /// One of the sprites in the collision.
    ///
    /// - localizationKey: Collision.spriteB
    public var spriteB: Sprite
    
    /// The angle of a collision between two sprites.
    ///
    /// - localizationKey: Collision.angle
    public var angle: Vector
    
    /// The force of a collision between two sprites.
    ///
    /// - localizationKey: Collision.force
    public var force: Double
    
    /// Indicates whether or not the two Sprites in the Collision are 
    public var isOverlapping: Bool
    
}


/// A CollisionPair holds references to two sprites in a collision.
///
/// - localizationKey: CollisionPair

public struct CollisionPair: Equatable, Hashable {
    
    /// One of the sprites in the collision.
    ///
    /// - localizationKey: CollisionPair.spriteA
    public var spriteA: Sprite
    
    /// One of the sprites in the collision.
    ///
    /// - localizationKey: CollisionPair.spriteB
    public var spriteB: Sprite
    
}
