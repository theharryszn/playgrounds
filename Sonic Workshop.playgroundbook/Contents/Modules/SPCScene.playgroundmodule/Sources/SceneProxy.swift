//
//  SceneProxy.swift
//  
//  Copyright © 2020 Apple Inc. All rights reserved.
//
import Foundation
import SpriteKit
import SPCIPC
import SPCCore
import SPCAudio

public protocol SceneProxyProtocol {
    func setBorderPhysics(hasCollisionBorder: Bool)
    func setSceneBackgroundColor(color: Color)
    func setSceneBackgroundImage(image: Image?)
    func setSceneGridVisible(isVisible: Bool)
    func clearScene()
    func placeGraphic(id: String, position: CGPoint, isPrintable: Bool, anchorPoint: AnchorPoint)
    func removeGraphic(id: String)
    func setSceneGravity(vector: CGVector)
    func setScenePositionalAudioListener(id: String)
    func createNode(id: String, graphicName: String, graphicType: GraphicType)
    func getGraphics()
    func setImage(id: String, image: Image?)
    func setTiledImage(id: String, image: Image?, columns: Int?, rows: Int?, isDynamic: Bool?)
    func setShape(id: String, shape: BasicShape?)
    func setText(id: String, text: String?)
    func setTextColor(id: String, color: Color)
    func setFontSize(id: String, size: Int)
    func setZPosition(id: String, position: Double)
    func setFontName(id: String, name: String)
    func setAffectedByGravity(id: String, gravity: Bool)
    func setIsDynamic(id: String, dynamic: Bool)
    func setAllowsRotation(id: String, rotation: Bool)
    func setXScale(id: String, scale: Double)
    func setYScale(id: String, scale: Double)
    func setVelocity(id: String, velocity: CGVector)
    func setRotationalVelocity(id: String, rotationalVelocity: Double)
    func setBounciness(id: String, bounciness: Double)
    func setFriction(id: String, friction: Double)
    func setDensity(id: String, density: Double)
    func setDrag(id: String, drag: Double)
    func setRotationalDrag(id: String, drag: Double)
    func setInteractionCategory(id: String, interactionCategory: InteractionCategory)
    func setCollisionCategories(id: String, collisionCategories: InteractionCategory)
    func setContactCategories(id: String, contactCategories: InteractionCategory)
    func createFixedJoint(jointID: String, from firstSpriteID: String, to secondSpriteID: String?, at anchor: Point)
    func createLimitJoint(jointID: String, from firstSpriteID: String, at firstAnchor: Point, to secondSpriteID: String?, at secondAnchor: Point)
    func createPinJoint(jointID: String, from firstSpriteID: String, to secondSpriteID: String?, at anchor: Point)
    func createSlidingJoint(jointID: String, from firstSpriteID: String, to secondSpriteID: String?, at anchor: Point, axis: Vector)
    func createSpringJoint(jointID: String, from firstSpriteID: String, at firstAnchor: Point, to secondSpriteID: String?, at secondAnchor: Point)
    func addJoint(jointID: String)
    func addParticleEmitter(id: String, name: String, duration: Double, color: Color)
    func removeJoint(jointID: String)
    func deleteJoint(jointID: String)
    func setLimitJointMaxLength(id: String, maxLength: Double)
    func setPinJointRotationSpeed(id: String, speed: Double)
    func setPinJointEnableAngleLimits(id: String, enableLimits: Bool)
    func setPinJointLowerAngleLimit(id: String, lowerAngleLimit: Double)
    func setPinJointUpperAngleLimit(id: String, upperAngleLimit: Double)
    func setPinJointAxleFriction(id: String, axleFriction: Double)
    func setSlidingJointEnableDistanceLimits(id: String, enableLimits: Bool)
    func setSlidingJointMinimumDistanceLimit(id: String, minimumDistanceLimit: Double)
    func setSlidingJointMaximumDistanceLimit(id: String, maximumDistanceLimit: Double)
    func setSpringJointDamping(id: String, damping: Double)
    func setSpringJointFrequency(id: String, frequency: Double)
    func touchEventAcknowledgement()
    func runAction(id: String, action: SKAction, name: String?)
    func removeAction(id: String, name: String)
    func removeAllActions(id: String)
    func runAnimation(id: String, animation: String, duration: Double, numberOfTimes: Int)
    func runCustomAnimation(id: String, animationSequence: [String], duration: Double, numberOfTimes: Int)
    func applyImpulse(id: String, vector: CGVector)
    func applyForce(id: String, vector: CGVector, duration: Double)
    func useOverlay(overlay: Overlay)
    func setAllowsTouchInteraction(id: String, allowsTouchInteraction: Bool)
    func setDisablesOnDisconnect(id:String, disablesOnDisconnect: Bool)
    func glow(id: String, radius: Double, period: Double, count: Int)
    func setTintColor(id: String, color: UIColor?, blend: Double)
    func setLightSensorImage(image: UIImage?)
    func placeRelativeGraphic(graphic: String, relativeTo: String, xOffset: Double, yOffset: Double)
    func addAudio(id: String, sound: Sound, positional: Bool, looping: Bool, volume: Double)
    func removeAudio(id: String)
    func playAudio(id: String)
    func stopAudio(id: String)
    func setIsAudioPositional(id: String, isAudioPositional: Bool)
}

protocol SceneUserCodeProxyProtocol {
    func updateGraphicAttributes(positions: [String : CGPoint], velocities: [String: CGVector], rotationalVelocities: [String: CGFloat], sizes: [String : CGSize])
    func getGraphicsReply(graphics: [Graphic])
    func removedGraphic(id: String)
    func sceneTouchEvent(touch: Touch)
    func sceneCollisionEvent(collision: Collision)
}

public class SceneProxy: SceneProxyProtocol, Messagable, LiveViewRegistering {
    
    static var receivers = [SceneProxyProtocol]()
    
    static func registerToRecieveDecodedMessage(as object: SceneProxyProtocol) {
        receivers.append(object)
    }
    
    public init() {}
    
    enum MessageType: String {
        case SetBorderPhysics
        case SetSceneBackgroundColor
        case SetSceneBackgroundImage
        case SetSceneGridVisible
        case ClearScene
        case PlaceGraphic
        case RemoveGraphic
        case SetSceneGravity
        case SetScenePositionalAudioListener
        case CreateNode
        case GetGraphics
        case SetImage
        case SetTiledImage
        case SetShape
        case SetText
        case SetTextColor
        case SetFontSize
        case SetZPosition
        case SetFontName
        case SetAffectedByGravity
        case SetIsDynamic
        case SetAllowsRotation
        case SetXScale
        case SetYScale
        case SetVelocity
        case SetRotationalVelocity
        case SetBounciness
        case SetFriction
        case SetDensity
        case SetDrag
        case SetRotationalDrag
        case SetInteractionCategory
        case SetCollisionCategories
        case SetContactCategories
        case CreateFixedJoint
        case CreateLimitJoint
        case CreatePinJoint
        case CreateSlidingJoint
        case CreateSpringJoint
        case AddJoint
        case AddParticleEmitter
        case RemoveJoint
        case DeleteJoint
        case SetLimitJointMaxLength
        case SetPinJointRotationSpeed
        case SetPinJointEnableAngleLimits
        case SetPinJointLowerAngleLimit
        case SetPinJointUpperAngleLimit
        case SetPinJointAxleFriction
        case SetSlidingJointEnableDistanceLimits
        case SetSlidingJointMinimumDistanceLimit
        case SetSlidingJointMaximumDistanceLimit
        case SetSpringJointDamping
        case SetSpringJointFrequency
        case TouchEventAcknowledgement
        case RunAction
        case RemoveAction
        case RemoveAllActions
        case RunAnimation
        case RunCustomAnimation
        case ApplyImpulse
        case ApplyForce
        case UseOverlay
        case SetAllowsTouchInteraction
        case SetDisablesOnDisconnect
        case Glow
        case SetTintColor
        case SetLightSensorImage
        case PlaceRelativeGraphic
        case AddAudio
        case RemoveAudio
        case PlayAudio
        case StopAudio
        case SetIsAudioPositional
    }
    
    public static func liveViewRegistration() {
        Message.registerToReceiveData(as: self)
    }
    
    public func setBorderPhysics(hasCollisionBorder: Bool) {
        Message.send(SetBorderPhysics(hasCollisionBorder: hasCollisionBorder), payload: type(of: SetBorderPhysics.self), proxy: type(of: self))
    }
    
    public func setSceneBackgroundColor(color: Color) {
        Message.send(SetSceneBackgroundColor(inColor: color), payload: type(of: SetSceneBackgroundColor.self), proxy: type(of: self))
    }
    
    public func setSceneBackgroundImage(image: Image?) {
        Message.send(SetSceneBackgroundImage(withImage: image), payload: type(of: SetSceneBackgroundImage.self), proxy: type(of: self))
    }
    
    public func setSceneGridVisible(isVisible: Bool) {
        Message.send(SetSceneGridVisible(isVisible: isVisible), payload: type(of: SetSceneGridVisible.self), proxy: type(of: self))
    }
    
    public func clearScene() {
        Message.send(ClearScene(), payload: type(of: ClearScene.self), proxy: type(of: self))
    }
    
    public func placeGraphic(id: String, position: CGPoint, isPrintable: Bool, anchorPoint: AnchorPoint) {
        Message.send(PlaceGraphic(inId: id, inPos: position, printable: isPrintable, anchor: anchorPoint),
                     payload: type(of: PlaceGraphic.self), proxy: type(of: self))
    }
    
    public func placeRelativeGraphic(graphic: String, relativeTo: String, xOffset: Double, yOffset: Double) {
        Message.send(PlaceRelativeGraphic(graphic: graphic, relativeTo: relativeTo, xOffset: xOffset, yOffset: yOffset), payload: type(of: PlaceRelativeGraphic.self), proxy: type(of: self))
    }
    
    public func removeGraphic(id: String) {
        Message.send(RemoveGraphic(id: id), payload: type(of: RemoveGraphic.self), proxy: type(of: self))
    }
    
    public func setSceneGravity(vector: CGVector) {
        Message.send(SetSceneGravity(vector: vector), payload: type(of: SetSceneGravity.self), proxy: type(of: self))
    }
    
    public func setScenePositionalAudioListener(id: String) {
        Message.send(SetScenePositionalAudioListener(id: id), payload: type(of: SetScenePositionalAudioListener.self), proxy: type(of: self))
    }
    
    public func createNode(id: String, graphicName: String, graphicType: GraphicType) {
        Message.send(CreateNode(id: id, graphicName: graphicName, type: graphicType), payload: type(of: CreateNode.self), proxy: type(of: self))
    }
    
    public func getGraphics() {
        Message.send(GetGraphics(), payload: type(of: GetGraphics.self), proxy: type(of: self))
    }
    
    public func setImage(id: String, image: Image?) {
        Message.send(SetImage(inId: id, inImage: image), payload: type(of: SetImage.self), proxy: type(of: self))
    }
    
    public func setTiledImage(id: String, image: Image?, columns: Int?, rows: Int?, isDynamic: Bool?) {
        Message.send(SetTiledImage(inId: id, numColumns: columns, numRows: rows, dynamic: isDynamic, inImage: image),
                     payload: type(of: SetTiledImage.self), proxy: type(of: self))
    }
    
    public func setShape(id: String, shape: BasicShape?) {
        Message.send(SetShape(inId: id, inShape: shape), payload: type(of: SetShape.self), proxy: type(of: self))
    }
    
    public func setText(id: String, text: String?) {
        Message.send(SetText(id: id, text: text), payload: type(of: SetText.self), proxy: type(of: self))
    }
    
    public func setTextColor(id: String, color: Color) {
        Message.send(SetTextColor(inId: id, color: color), payload: type(of: SetTextColor.self), proxy: type(of: self))
    }
    
    public func setFontSize(id: String, size: Int) {
        Message.send(SetFontSize(id: id, size: size), payload: type(of: SetFontSize.self), proxy: type(of: self))
    }
    
    public func setZPosition(id: String, position: Double) {
        Message.send(SetZPosition(id: id, position: position), payload: type(of: SetZPosition.self), proxy: type(of: self))

    }
    public func setFontName(id: String, name: String) {
        Message.send(SetFontName(id: id, name: name), payload: type(of: SetFontName.self), proxy: type(of: self))
    }
    
    public func setAffectedByGravity(id: String, gravity: Bool) {
        Message.send(SetAffectedByGravity(id: id, gravity: gravity), payload: type(of: SetAffectedByGravity.self), proxy: type(of: self))
    }
    
    public func setIsDynamic(id: String, dynamic: Bool) {
        Message.send(SetIsDynamic(id: id, isDynamic: dynamic), payload: type(of: SetIsDynamic.self), proxy: type(of: self))
    }
    
    public func setAllowsRotation(id: String, rotation: Bool) {
        Message.send(SetAllowsRotation(id: id, allowsRotation: rotation), payload: type(of: SetAllowsRotation.self), proxy: type(of: self))
    }
    
    public func setXScale(id: String, scale: Double) {
        Message.send(SetXScale(id: id, xScale: scale), payload: type(of: SetXScale.self), proxy: type(of: self))
    }
    
    public func setYScale(id: String, scale: Double) {
        Message.send(SetYScale(id: id, yScale: scale), payload: type(of: SetYScale.self), proxy: type(of: self))
    }
    
    public func setVelocity(id: String, velocity: CGVector) {
        Message.send(SetVelocity(id: id, velocity: velocity), payload: type(of: SetVelocity.self), proxy: type(of: self))
    }
    
    public func setRotationalVelocity(id: String, rotationalVelocity: Double) {
        Message.send(SetRotationalVelocity(id: id, rotationalVelocity: rotationalVelocity),
                     payload: type(of: SetRotationalVelocity.self),
                     proxy: type(of: self))
    }
    
    public func setBounciness(id: String, bounciness: Double) {
        Message.send(SetBounciness(id: id, bounciness: bounciness), payload: type(of: SetBounciness.self), proxy: type(of: self))
    }
    
    public func setFriction(id: String, friction: Double) {
        Message.send(SetFriction(id: id, friction: friction), payload: type(of: SetFriction.self), proxy: type(of: self))
    }
    
    public func setDensity(id: String, density: Double) {
        Message.send(SetDensity(id: id, density: density), payload: type(of: SetDensity.self), proxy: type(of: self))
    }
    
    public func setDrag(id: String, drag: Double) {
        Message.send(SetDrag(id: id, drag: drag), payload: type(of: SetDrag.self), proxy: type(of: self))
    }
    
    public func setRotationalDrag(id: String, drag: Double) {
        Message.send(SetRotationalDrag(id: id, drag: drag), payload: type(of: SetRotationalDrag.self), proxy: type(of: self))
    }
    
    public func setInteractionCategory(id: String, interactionCategory: InteractionCategory) {
        Message.send(SetInteractionCategory(id: id, interactionCategory: interactionCategory), payload: type(of: SetInteractionCategory.self), proxy: type(of: self))
    }
    
    public func setCollisionCategories(id: String, collisionCategories: InteractionCategory) {
        Message.send(SetCollisionCategories(id: id, collisionCategories: collisionCategories), payload: type(of: SetCollisionCategories.self), proxy: type(of: self))
    }
    
    public func setContactCategories(id: String, contactCategories: InteractionCategory) {
        Message.send(SetContactCategories(id: id, contactCategories: contactCategories), payload: type(of: SetContactCategories.self), proxy: type(of: self))
    }
    
    // MARK: Managing Joints
    
    public func createFixedJoint(jointID: String, from firstSpriteID: String, to secondSpriteID: String?, at anchor: Point) {
        Message.send(CreateFixedJoint(jointID: jointID, from: firstSpriteID, to: secondSpriteID, at: anchor),
                     payload: type(of: CreateFixedJoint.self),
                     proxy: type(of: self))
    }
    
    public func createLimitJoint(jointID: String, from firstSpriteID: String, at firstAnchor: Point, to secondSpriteID: String?, at secondAnchor: Point) {
        Message.send(CreateLimitJoint(jointID: jointID, from: firstSpriteID, at: firstAnchor, to: secondSpriteID, at: secondAnchor),
                     payload: type(of: CreateLimitJoint.self),
                     proxy: type(of: self))
    }
    
    public func createPinJoint(jointID: String, from firstSpriteID: String, to secondSpriteID: String?, at anchor: Point) {
        Message.send(CreatePinJoint(jointID: jointID, from: firstSpriteID, to: secondSpriteID, at: anchor),
                     payload: type(of: CreatePinJoint.self),
                     proxy: type(of: self))
    }
    
    public func createSlidingJoint(jointID: String, from firstSpriteID: String, to secondSpriteID: String?, at anchor: Point, axis: Vector) {
        Message.send(CreateSlidingJoint(jointID: jointID, from: firstSpriteID, to: secondSpriteID, at: anchor, axis: axis),
                     payload: type(of: CreateSlidingJoint.self),
                     proxy: type(of: self))
    }
    
    public func createSpringJoint(jointID: String, from firstSpriteID: String, at firstAnchor: Point, to secondSpriteID: String?, at secondAnchor: Point) {
        Message.send(CreateSpringJoint(jointID: jointID, from: firstSpriteID, at: firstAnchor, to: secondSpriteID, at: secondAnchor),
                     payload: type(of: CreateSpringJoint.self),
                     proxy: type(of: self))
    }
    
    public func addJoint(jointID: String) {
        Message.send(AddJoint(jointID: jointID),
                     payload: type(of: AddJoint.self),
                     proxy: type(of: self))
    }
    
    public func removeJoint(jointID: String) {
        Message.send(RemoveJoint(jointID: jointID),
                     payload: type(of: RemoveJoint.self),
                     proxy: type(of: self))
    }
    
    public func deleteJoint(jointID: String) {
        Message.send(DeleteJoint(jointID: jointID),
                     payload: type(of: DeleteJoint.self),
                     proxy: type(of: self))
    }
    
    // MARK: Joint Arguments
    
    public func setLimitJointMaxLength(id: String, maxLength: Double) {
        Message.send(SetLimitJointMaxLength(id: id, maxLength: maxLength), payload: type(of: SetLimitJointMaxLength.self), proxy: type(of: self))
    }
    
    public func setPinJointRotationSpeed(id: String, speed: Double) {
        Message.send(SetPinJointRotationSpeed(id: id, speed: speed), payload: type(of: SetPinJointRotationSpeed.self), proxy: type(of: self))
    }
    
    public func setPinJointEnableAngleLimits(id: String, enableLimits: Bool) {
        Message.send(SetPinJointEnableAngleLimits(id: id, enableLimits: enableLimits), payload: type(of: SetPinJointEnableAngleLimits.self), proxy: type(of: self))
    }
    
    public func setPinJointLowerAngleLimit(id: String, lowerAngleLimit: Double) {
        Message.send(SetPinJointLowerAngleLimit(id: id, lowerAngleLimit: lowerAngleLimit), payload: type(of: SetPinJointLowerAngleLimit.self), proxy: type(of: self))
    }
    
    public func setPinJointUpperAngleLimit(id: String, upperAngleLimit: Double) {
        Message.send(SetPinJointUpperAngleLimit(id: id, upperAngleLimit: upperAngleLimit), payload: type(of: SetPinJointUpperAngleLimit.self), proxy: type(of: self))
    }
    
    public func setPinJointAxleFriction(id: String, axleFriction: Double) {
        Message.send(SetPinJointAxleFriction(id: id, axleFriction: axleFriction), payload: type(of: SetPinJointAxleFriction.self), proxy: type(of: self))
    }
    
    public func setSlidingJointEnableDistanceLimits(id: String, enableLimits: Bool) {
        Message.send(SetSlidingJointEnableDistanceLimits(id: id, enableLimits: enableLimits), payload: type(of: SetSlidingJointEnableDistanceLimits.self), proxy: type(of: self))
    }
    
    public func setSlidingJointMinimumDistanceLimit(id: String, minimumDistanceLimit: Double) {
        Message.send(SetSlidingJointMinimumDistanceLimit(id: id, minimumDistanceLimit: minimumDistanceLimit), payload: type(of: SetSlidingJointMinimumDistanceLimit.self), proxy: type(of: self))
    }
    
    public func setSlidingJointMaximumDistanceLimit(id: String, maximumDistanceLimit: Double) {
        Message.send(SetSlidingJointMaximumDistanceLimit(id: id, maximumDistanceLimit: maximumDistanceLimit), payload: type(of: SetSlidingJointMaximumDistanceLimit.self), proxy: type(of: self))
    }
    
    public func setSpringJointDamping(id: String, damping: Double) {
        Message.send(SetSpringJointDamping(id: id, damping: damping), payload: type(of: SetSpringJointDamping.self), proxy: type(of: self))
    }
    
    public func setSpringJointFrequency(id: String, frequency: Double) {
        Message.send(SetSpringJointFrequency(id: id, frequency: frequency), payload: type(of: SetSpringJointFrequency.self), proxy: type(of: self))
    }
    
    public func touchEventAcknowledgement() {
        Message.send(TouchEventAcknowledgement(), payload: type(of: TouchEventAcknowledgement.self), proxy: type(of: self))
    }
    
    public func runAction(id: String, action: SKAction, name: String?) {
        Message.send(RunAction(id: id, action: action, name: name), payload: type(of: RunAction.self), proxy: type(of: self))
    }
    
    public func removeAction(id: String, name: String) {
        Message.send(RemoveAction(id: id, name: name), payload: type(of: RemoveAction.self), proxy: type(of: self))
    }
    
    public func addParticleEmitter(id: String, name: String, duration: Double, color: Color) {
        Message.send(AddParticleEmitter(id: id, name: name, duration: duration, color: color), payload: type(of: AddParticleEmitter.self), proxy: type(of: self))
    }
    
    public func removeAllActions(id: String) {
        Message.send(RemoveAllActions(id: id), payload: type(of: RemoveAllActions.self), proxy: type(of: self))
    }
    
    public func runAnimation(id: String, animation: String, duration: Double, numberOfTimes: Int) {
        Message.send(RunAnimation(id: id, animation: animation, duration: duration, numberOfTimes: numberOfTimes), payload: type(of: RunAnimation.self), proxy: type(of: self))
    }
    
    public func runCustomAnimation(id: String, animationSequence: [String], duration: Double, numberOfTimes: Int) {
        Message.send(RunCustomAnimation(id: id, animationSequence: animationSequence, duration: duration, numberOfTimes: numberOfTimes),
                     payload: type(of: RunCustomAnimation.self), proxy: type(of: self))
    }
    
    public func applyImpulse(id: String, vector: CGVector) {
        Message.send(ApplyImpulse(id: id, vector: vector), payload: type(of: ApplyImpulse.self), proxy: type(of: self))
    }
    
    public func applyForce(id: String, vector: CGVector, duration: Double) {
        Message.send(ApplyForce(id: id, vector: vector, duration: duration), payload: type(of: ApplyForce.self), proxy: type(of: self))
    }
    
    public func useOverlay(overlay: Overlay) {
        Message.send(UseOverlay(inOverlay: overlay), payload: type(of: UseOverlay.self), proxy: type(of: self))
    }
    
    public func setAllowsTouchInteraction(id: String, allowsTouchInteraction: Bool) {
        Message.send(SetAllowsTouchInteraction(id: id, allowsTouchInteraction: allowsTouchInteraction), payload: type(of: SetAllowsTouchInteraction.self), proxy: type(of: self))
    }
    
    public func setDisablesOnDisconnect(id: String, disablesOnDisconnect: Bool) {
        Message.send(SetDisablesOnDisconnect(id: id, disablesOnDisconnect: disablesOnDisconnect), payload: type(of: SetDisablesOnDisconnect.self), proxy: type(of: self))
    }
    
    public func glow(id: String, radius: Double, period: Double, count: Int) {
        Message.send(Glow(id: id, radius: radius, period: period, count: count), payload: type(of: Glow.self), proxy: type(of: self))
    }
    
    public func setTintColor(id: String, color: UIColor?, blend: Double) {
        Message.send(SetTintColor(inId: id, color: color, inBlend: blend), payload: type(of: SetTintColor.self), proxy: type(of: self))
    }
    
    public func setLightSensorImage(image: UIImage?) {
        Message.send(SetLightSensorImage(inImage: image), payload: type(of: SetLightSensorImage.self), proxy: type(of: self))
    }
    
    public func addAudio(id: String, sound: Sound, positional: Bool, looping: Bool, volume: Double) {
        Message.send(AddAudio(id: id, sound: sound, positional: positional, looping: looping, volume: volume), payload: type(of: AddAudio.self), proxy: type(of: self))
    }
    
    public func removeAudio(id: String) {
        Message.send(RemoveAudio(id: id), payload: type(of: RemoveAudio.self), proxy: type(of: self))
    }
    
    public func playAudio(id: String) {
        Message.send(PlayAudio(id: id), payload: type(of: PlayAudio.self), proxy: type(of: self))
    }
    
    public func stopAudio(id: String) {
        Message.send(StopAudio(id: id), payload: type(of: StopAudio.self), proxy: type(of: self))
    }
    
    public func setIsAudioPositional(id: String, isAudioPositional: Bool) {
        Message.send(SetIsAudioPositional(id: id, isAudioPositional: isAudioPositional), payload: type(of: SetIsAudioPositional.self), proxy: type(of: self))
    }
    
    
    public static func decode(data: Data, withId id: String) {
        if let type = MessageType(rawValue: id) {
            switch type {
            case .SetBorderPhysics:
                if let decoded = try? JSONDecoder().decode(SetBorderPhysics.self, from: data) {
                    receivers.forEach({$0.setBorderPhysics(hasCollisionBorder: decoded.hasCollisionBorder)})
                }
            case .SetSceneBackgroundColor:
                if let decoded = try? JSONDecoder().decode(SetSceneBackgroundColor.self, from: data) {
                    receivers.forEach({$0.setSceneBackgroundColor(color: decoded.color)})
                }
            case .SetSceneBackgroundImage:
                if let decoded = try? JSONDecoder().decode(SetSceneBackgroundImage.self, from: data) {
                    receivers.forEach({$0.setSceneBackgroundImage(image: decoded.image)})
                }
            case .SetSceneGridVisible:
                if let decoded = try? JSONDecoder().decode(SetSceneGridVisible.self, from: data) {
                    receivers.forEach({$0.setSceneGridVisible(isVisible: decoded.isVisible)})
                }
            case .ClearScene:
                receivers.forEach({$0.clearScene()})
            case .PlaceGraphic:
                if let decoded = try? JSONDecoder().decode(PlaceGraphic.self, from: data) {
                    receivers.forEach({$0.placeGraphic(id: decoded.id, position: decoded.position, isPrintable: decoded.isPrintable, anchorPoint: decoded.anchorPoint)})
                }
            case .PlaceRelativeGraphic:
                if let decoded = try? JSONDecoder().decode(PlaceRelativeGraphic.self, from: data) {
                    receivers.forEach({$0.placeRelativeGraphic(graphic: decoded.graphic, relativeTo: decoded.relativeTo, xOffset: decoded.xOffset, yOffset: decoded.yOffset)})
                }
            case .RemoveGraphic:
                if let decoded = try? JSONDecoder().decode(RemoveGraphic.self, from: data) {
                    receivers.forEach({$0.removeGraphic(id: decoded.id)})
                }
            case .SetSceneGravity:
                if let decoded = try? JSONDecoder().decode(SetSceneGravity.self, from: data) {
                    receivers.forEach({$0.setSceneGravity(vector: decoded.vector)})
                }
            case .SetScenePositionalAudioListener:
                if let decoded = try? JSONDecoder().decode(SetScenePositionalAudioListener.self, from: data) {
                    receivers.forEach({$0.setScenePositionalAudioListener(id: decoded.id)})
                }
            case .CreateNode:
                if let decoded = try? JSONDecoder().decode(CreateNode.self, from: data) {
                    receivers.forEach({$0.createNode(id: decoded.id, graphicName: decoded.graphicName, graphicType: decoded.graphicType)})
                }
            case .GetGraphics:
                receivers.forEach({$0.getGraphics()})
            case .SetImage:
                if let decoded = try? JSONDecoder().decode(SetImage.self, from: data) {
                    receivers.forEach({$0.setImage(id: decoded.id, image: decoded.image)})
                }
            case .SetTiledImage:
                if let decoded = try? JSONDecoder().decode(SetTiledImage.self, from: data) {
                    receivers.forEach({$0.setTiledImage(id: decoded.id, image: decoded.image, columns: decoded.columns, rows: decoded.rows, isDynamic: decoded.isDynamic)})
                }
            case .SetShape:
                if let decoded = try? JSONDecoder().decode(SetShape.self, from: data) {
                    receivers.forEach({$0.setShape(id: decoded.id, shape: decoded.shape)})
                }
            case .SetText:
                if let decoded = try? JSONDecoder().decode(SetText.self, from: data) {
                    receivers.forEach({$0.setText(id: decoded.id, text: decoded.text)})
                }
            case .SetTextColor:
                if let decoded = try? JSONDecoder().decode(SetTextColor.self, from: data) {
                    receivers.forEach({$0.setTextColor(id: decoded.id, color: decoded.color)})
                }
            case .SetFontSize:
                if let decoded = try? JSONDecoder().decode(SetFontSize.self, from: data) {
                    receivers.forEach({$0.setFontSize(id: decoded.id, size: decoded.size)})
                }
            case .SetZPosition:
                if let decoded = try? JSONDecoder().decode(SetZPosition.self, from: data) {
                    receivers.forEach({$0.setZPosition(id: decoded.id, position: decoded.position)})
                }
            case .SetFontName:
                if let decoded = try? JSONDecoder().decode(SetFontName.self, from: data) {
                    receivers.forEach({$0.setFontName(id: decoded.id, name: decoded.name)})
                }
            case .SetAffectedByGravity:
                if let decoded = try? JSONDecoder().decode(SetAffectedByGravity.self, from: data) {
                    receivers.forEach({$0.setAffectedByGravity(id: decoded.id, gravity: decoded.gravity)})
                }
            case .SetIsDynamic:
                if let decoded = try? JSONDecoder().decode(SetIsDynamic.self, from: data) {
                    receivers.forEach({$0.setIsDynamic(id: decoded.id, dynamic: decoded.isDynamic)})
                }
            case .SetAllowsRotation:
                if let decoded = try? JSONDecoder().decode(SetAllowsRotation.self, from: data) {
                    receivers.forEach({$0.setAllowsRotation(id: decoded.id, rotation: decoded.allowsRotation)})
                }
            case .SetXScale:
                if let decoded = try? JSONDecoder().decode(SetXScale.self, from: data) {
                    receivers.forEach({$0.setXScale(id: decoded.id, scale: decoded.xScale)})
                }
            case .SetYScale:
                if let decoded = try? JSONDecoder().decode(SetYScale.self, from: data) {
                    receivers.forEach({$0.setYScale(id: decoded.id, scale: decoded.yScale)})
                }
            case .SetVelocity:
                if let decoded = try? JSONDecoder().decode(SetVelocity.self, from: data) {
                    receivers.forEach({$0.setVelocity(id: decoded.id, velocity: decoded.velocity)})
                }
            case .SetRotationalVelocity:
                if let decoded = try? JSONDecoder().decode(SetRotationalVelocity.self, from: data) {
                    receivers.forEach({$0.setRotationalVelocity(id: decoded.id, rotationalVelocity: decoded.rotationalVelocity)})
                }
            case .SetBounciness:
                if let decoded = try? JSONDecoder().decode(SetBounciness.self, from: data) {
                    receivers.forEach({$0.setBounciness(id: decoded.id, bounciness: decoded.bounciness)})
                }
            case .SetFriction:
                if let decoded = try? JSONDecoder().decode(SetFriction.self, from: data) {
                    receivers.forEach({$0.setFriction(id: decoded.id, friction: decoded.friction)})
                }
            case .SetDensity:
                if let decoded = try? JSONDecoder().decode(SetDensity.self, from: data) {
                    receivers.forEach({$0.setDensity(id: decoded.id, density: decoded.density)})
                }
            case .SetDrag:
                if let decoded = try? JSONDecoder().decode(SetDrag.self, from: data) {
                    receivers.forEach({$0.setDrag(id: decoded.id, drag: decoded.drag)})
                }
            case .SetRotationalDrag:
                if let decoded = try? JSONDecoder().decode(SetRotationalDrag.self, from: data) {
                    receivers.forEach({$0.setRotationalDrag(id: decoded.id, drag: decoded.drag)})
                }
            case .SetInteractionCategory:
                if let decoded = try? JSONDecoder().decode(SetInteractionCategory.self, from: data) {
                    receivers.forEach({$0.setInteractionCategory(id: decoded.id, interactionCategory: decoded.interactionCategory)})
                }
            case .SetCollisionCategories:
                if let decoded = try? JSONDecoder().decode(SetCollisionCategories.self, from: data) {
                    receivers.forEach({$0.setCollisionCategories(id: decoded.id, collisionCategories: decoded.collisionCategories)})
                }
            case .SetContactCategories:
                if let decoded = try? JSONDecoder().decode(SetContactCategories.self, from: data) {
                    receivers.forEach({$0.setContactCategories(id: decoded.id, contactCategories: decoded.contactCategories)})
                }
            case .CreateFixedJoint:
                if let decoded = try? JSONDecoder().decode(CreateFixedJoint.self, from: data) {
                    receivers.forEach {
                        $0.createFixedJoint(jointID: decoded.jointID,
                                            from: decoded.firstSpriteID,
                                            to: decoded.secondSpriteID,
                                            at: decoded.anchor)
                        
                    }
                }
            case .CreateLimitJoint:
                if let decoded = try? JSONDecoder().decode(CreateLimitJoint.self, from: data) {
                    receivers.forEach {
                        $0.createLimitJoint(jointID: decoded.jointID,
                                            from: decoded.firstSpriteID,
                                            at: decoded.firstAnchor,
                                            to: decoded.secondSpriteID,
                                            at: decoded.secondAnchor)
                    }
                }
            case .CreatePinJoint:
                if let decoded = try? JSONDecoder().decode(CreatePinJoint.self, from: data) {
                    receivers.forEach {
                        $0.createPinJoint(jointID: decoded.jointID,
                                          from: decoded.firstSpriteID,
                                          to: decoded.secondSpriteID,
                                          at: decoded.anchor)
                    }
                }
            case .CreateSlidingJoint:
                if let decoded = try? JSONDecoder().decode(CreateSlidingJoint.self, from: data) {
                    receivers.forEach {
                        $0.createSlidingJoint(jointID: decoded.jointID,
                                              from: decoded.firstSpriteID,
                                              to: decoded.secondSpriteID,
                                              at: decoded.anchor,
                                              axis: decoded.axis)
                    }
                }
            case .CreateSpringJoint:
                if let decoded = try? JSONDecoder().decode(CreateSpringJoint.self, from: data) {
                    receivers.forEach {
                        $0.createSpringJoint(jointID: decoded.jointID,
                                             from: decoded.firstSpriteID,
                                             at: decoded.firstAnchor,
                                             to: decoded.secondSpriteID,
                                             at: decoded.secondAnchor)
                    }
                }
            case .AddJoint:
                if let decoded = try? JSONDecoder().decode(AddJoint.self, from: data) {
                    receivers.forEach {
                        $0.addJoint(jointID: decoded.jointID)
                    }
                }
            case .AddParticleEmitter:
                if let decoded = try? JSONDecoder().decode(AddParticleEmitter.self, from: data) {
                    receivers.forEach({$0.addParticleEmitter(id: decoded.id, name: decoded.name, duration: decoded.duration, color: decoded.color)})
                }
            case .RemoveJoint:
                if let decoded = try? JSONDecoder().decode(RemoveJoint.self, from: data) {
                    receivers.forEach {
                        $0.removeJoint(jointID: decoded.jointID)
                    }
                }
            case .DeleteJoint:
                if let decoded = try? JSONDecoder().decode(DeleteJoint.self, from: data) {
                    receivers.forEach {
                        $0.deleteJoint(jointID: decoded.jointID)
                    }
                }
            case .SetLimitJointMaxLength:
                if let decoded = try? JSONDecoder().decode(SetLimitJointMaxLength.self, from: data) {
                    receivers.forEach({$0.setLimitJointMaxLength(id: decoded.id, maxLength: decoded.maxLength)})
                }
            case .SetPinJointRotationSpeed:
                if let decoded = try? JSONDecoder().decode(SetPinJointRotationSpeed.self, from: data) {
                    receivers.forEach({$0.setPinJointRotationSpeed(id: decoded.id, speed: decoded.speed)})
                 }
            case .SetPinJointEnableAngleLimits:
                if let decoded = try? JSONDecoder().decode(SetPinJointEnableAngleLimits.self, from: data) {
                    receivers.forEach({$0.setPinJointEnableAngleLimits(id: decoded.id, enableLimits: decoded.enableLimits)})
                 }
            case .SetPinJointLowerAngleLimit:
                if let decoded = try? JSONDecoder().decode(SetPinJointLowerAngleLimit.self, from: data) {
                    receivers.forEach({$0.setPinJointLowerAngleLimit(id: decoded.id, lowerAngleLimit: decoded.lowerAngleLimit)})
                 }
            case .SetPinJointUpperAngleLimit:
                if let decoded = try? JSONDecoder().decode(SetPinJointUpperAngleLimit.self, from: data) {
                    receivers.forEach({$0.setPinJointUpperAngleLimit(id: decoded.id, upperAngleLimit: decoded.upperAngleLimit)})
                 }
            case .SetPinJointAxleFriction:
                if let decoded = try? JSONDecoder().decode(SetPinJointAxleFriction.self, from: data) {
                    receivers.forEach({$0.setPinJointAxleFriction(id: decoded.id, axleFriction: decoded.axleFriction)})
                }
            case .SetSlidingJointEnableDistanceLimits:
                if let decoded = try? JSONDecoder().decode(SetSlidingJointEnableDistanceLimits.self, from: data) {
                    receivers.forEach({$0.setSlidingJointEnableDistanceLimits(id: decoded.id, enableLimits: decoded.enableLimits)})
                }
            case .SetSlidingJointMinimumDistanceLimit:
                if let decoded = try? JSONDecoder().decode(SetSlidingJointMinimumDistanceLimit.self, from: data) {
                    receivers.forEach({$0.setSlidingJointMinimumDistanceLimit(id: decoded.id, minimumDistanceLimit: decoded.minimumDistanceLimit)})
                }
            case .SetSlidingJointMaximumDistanceLimit:
                if let decoded = try? JSONDecoder().decode(SetSlidingJointMaximumDistanceLimit.self, from: data) {
                    receivers.forEach({$0.setSlidingJointMaximumDistanceLimit(id: decoded.id, maximumDistanceLimit: decoded.maximumDistanceLimit)})
                }
            case .SetSpringJointDamping:
                if let decoded = try? JSONDecoder().decode(SetSpringJointDamping.self, from: data) {
                    receivers.forEach({$0.setSpringJointDamping(id: decoded.id, damping: decoded.damping)})
                }
            case .SetSpringJointFrequency:
                if let decoded = try? JSONDecoder().decode(SetSpringJointFrequency.self, from: data) {
                    receivers.forEach({$0.setSpringJointFrequency(id: decoded.id, frequency:decoded.frequency)})
                }
            case .TouchEventAcknowledgement:
                receivers.forEach({$0.touchEventAcknowledgement()})
            case .RunAction:
                if let decoded = try? JSONDecoder().decode(RunAction.self, from: data) {
                    receivers.forEach({$0.runAction(id: decoded.id, action: decoded.action, name: decoded.name)})
                }
            case .RemoveAction:
                if let decoded = try? JSONDecoder().decode(RemoveAction.self, from: data) {
                    receivers.forEach({$0.removeAction(id: decoded.id, name: decoded.name)})
                }
            case .RemoveAllActions:
                if let decoded = try? JSONDecoder().decode(RemoveAllActions.self, from: data) {
                    receivers.forEach({$0.removeAllActions(id: decoded.id)})
                }
            case .RunAnimation:
                if let decoded = try? JSONDecoder().decode(RunAnimation.self, from: data) {
                    receivers.forEach({$0.runAnimation(id: decoded.id, animation: decoded.animation, duration: decoded.duration, numberOfTimes: decoded.numberOfTimes)})
                }
            case .RunCustomAnimation:
                if let decoded = try? JSONDecoder().decode(RunCustomAnimation.self, from: data) {
                    receivers.forEach({$0.runCustomAnimation(id: decoded.id, animationSequence: decoded.animationSequence, duration: decoded.duration, numberOfTimes: decoded.numberOfTimes)})
                }
            case .ApplyImpulse:
                if let decoded = try? JSONDecoder().decode(ApplyImpulse.self, from: data) {
                    receivers.forEach({$0.applyImpulse(id: decoded.id, vector: decoded.vector)})
                }
            case .ApplyForce:
                if let decoded = try? JSONDecoder().decode(ApplyForce.self, from: data) {
                    receivers.forEach({$0.applyForce(id: decoded.id, vector: decoded.vector, duration: decoded.duration)})
                }
            case .UseOverlay:
                if let decoded = try? JSONDecoder().decode(UseOverlay.self, from: data) {
                    receivers.forEach({$0.useOverlay(overlay: decoded.overlay)})
                }
            case .SetAllowsTouchInteraction:
                if let decoded = try? JSONDecoder().decode(SetAllowsTouchInteraction.self, from: data) {
                    receivers.forEach({$0.setAllowsTouchInteraction(id: decoded.id, allowsTouchInteraction: decoded.allowsTouchInteraction)})
                }
            case .SetDisablesOnDisconnect:
                if let decoded = try? JSONDecoder().decode(SetDisablesOnDisconnect.self, from: data) {
                    receivers.forEach({$0.setDisablesOnDisconnect(id: decoded.id, disablesOnDisconnect: decoded.disablesOnDisconnect)})
                }
            case .Glow:
                if let decoded = try? JSONDecoder().decode(Glow.self, from: data) {
                    receivers.forEach({$0.glow(id: decoded.id, radius: decoded.radius, period: decoded.period, count: decoded.count)})
                }
            case .SetTintColor:
                if let decoded = try? JSONDecoder().decode(SetTintColor.self, from: data) {
                    receivers.forEach({$0.setTintColor(id: decoded.id, color: decoded.color, blend: decoded.blend)})
                }
            case .SetLightSensorImage:
                if let decoded = try? JSONDecoder().decode(SetLightSensorImage.self, from: data) {
                    receivers.forEach({$0.setLightSensorImage(image: decoded.image)})
                }
            case .AddAudio:
                if let decoded = try? JSONDecoder().decode(AddAudio.self, from: data) {
                    receivers.forEach({$0.addAudio(id: decoded.id, sound: decoded.sound, positional: decoded.positional, looping: decoded.looping, volume: decoded.volume)})
                }
            case .RemoveAudio:
                if let decoded = try? JSONDecoder().decode(RemoveAudio.self, from: data) {
                    receivers.forEach({$0.removeAudio(id: decoded.id)})
                }
            case .PlayAudio:
                if let decoded = try? JSONDecoder().decode(PlayAudio.self, from: data) {
                    receivers.forEach({$0.playAudio(id: decoded.id)})
                }
            case .StopAudio:
                if let decoded = try? JSONDecoder().decode(StopAudio.self, from: data) {
                    receivers.forEach({$0.stopAudio(id: decoded.id)})
                }
            case .SetIsAudioPositional:
                if let decoded = try? JSONDecoder().decode(SetIsAudioPositional.self, from: data) {
                    receivers.forEach({$0.setIsAudioPositional(id: decoded.id, isAudioPositional: decoded.isAudioPositional)})
                }
            }
        }
    }
}

class SceneUserCodeProxy: SceneUserCodeProxyProtocol, Messagable {
    static var receivers = [SceneUserCodeProxyProtocol]()
    
    static func registerToReceiveDecodedMessage(as object: SceneUserCodeProxyProtocol) {
        receivers.append(object)
        Message.registerToReceiveData(as: self)
    }
    
    enum MessageType: String {
        case UpdateGraphicAttributes
        case GetGraphicsReply
        case RemoveGraphic
        case SceneTouchEvent
        case SceneCollisionEvent
    }
    
    func updateGraphicAttributes(positions: [String : CGPoint], velocities: [String: CGVector], rotationalVelocities: [String: CGFloat], sizes: [String : CGSize]) {
        Message.send(UpdateGraphicAttributes(positions: positions, velocities: velocities, rotationalVelocities: rotationalVelocities, sizes: sizes), payload: type(of: UpdateGraphicAttributes.self), proxy: type(of: self))
    }
    
    func getGraphicsReply(graphics: [Graphic]) {
        Message.send(GetGraphicsReply(graphicList: graphics), payload: type(of: GetGraphicsReply.self), proxy: type(of: self))
    }
    
    func removedGraphic(id: String) {
        Message.send(RemoveGraphic(id: id), payload: type(of: RemovedGraphic.self), proxy: type(of: self))
    }
    
    func sceneTouchEvent(touch: Touch) {
        Message.send(SceneTouchEvent(inTouch: touch), payload: type(of: SceneTouchEvent.self), proxy: type(of: self))
    }
    
    func sceneCollisionEvent(collision: Collision) {
        Message.send(SceneCollisionEvent(collision: collision), payload: type(of: SceneCollisionEvent.self), proxy: type(of: self))
    }
    
    static func decode(data: Data, withId id: String) {
        if let type = MessageType.init(rawValue: id) {
            switch type {
            case .UpdateGraphicAttributes:
                if let decoded = try? JSONDecoder().decode(UpdateGraphicAttributes.self, from: data) {
                    receivers.forEach({$0.updateGraphicAttributes(positions: decoded.positions, velocities: decoded.velocities, rotationalVelocities: decoded.rotationalVelocities, sizes: decoded.sizes)})
                }
            case .GetGraphicsReply:
                if let decoded = try? JSONDecoder().decode(GetGraphicsReply.self, from: data) {
                    receivers.forEach({$0.getGraphicsReply(graphics: decoded.graphics)})
                }
            case .RemoveGraphic:
                if let decoded = try? JSONDecoder().decode(RemovedGraphic.self, from: data) {
                    receivers.forEach({$0.removedGraphic(id: decoded.id)})
                }
            case .SceneTouchEvent:
                if let decoded = try? JSONDecoder().decode(SceneTouchEvent.self, from: data) {
                    receivers.forEach({$0.sceneTouchEvent(touch: decoded.touch)})
                }
            case .SceneCollisionEvent:
                if let decoded = try? JSONDecoder().decode(SceneCollisionEvent.self, from: data) {
                    receivers.forEach({$0.sceneCollisionEvent(collision: decoded.collision)})
                }
            }
        }
    }
}

struct SetBorderPhysics: Sendable  {
    var hasCollisionBorder: Bool
}

struct SetSceneBackgroundColor: Sendable {
    private var colorstruct: ColorStruct
    var color: UIColor {
        return colorstruct.color
    }
    
    init(inColor: Color) {
        colorstruct = ColorStruct(newColor: inColor)
    }
}

struct SetSceneBackgroundImage: Sendable {
    private var path: String?
    var image: Image? {
        var retVal: Image? = nil
        if let name = path {
            retVal = Image(imageLiteralResourceName: name)
        }
        return retVal
    }
    
    init(withImage: Image? = nil) {
        let imagePath = withImage?.path
        path = imagePath
    }
}

struct SetSceneGridVisible: Sendable {
    var isVisible: Bool
}

struct ClearScene: Sendable {}

struct PlaceGraphic: Sendable {
    var id: String
    var position: CGPoint
    var isPrintable: Bool
    private var point: Int
    var anchorPoint: AnchorPoint {
        return AnchorPoint(rawValue: point)!
    }
    
    init(inId: String, inPos: CGPoint, printable: Bool, anchor: AnchorPoint) {
        id = inId
        position = inPos
        isPrintable = printable
        point = anchor.rawValue
    }
}

struct UpdateGraphicAttributes: Sendable {
    var positions: [String: CGPoint]
    var velocities: [String: CGVector]
    var rotationalVelocities: [String: CGFloat]
    var sizes: [String: CGSize]
}

struct RemoveGraphic: Sendable {
    var id: String
}

struct SetSceneGravity: Sendable{
    var vector: CGVector
}

struct SetScenePositionalAudioListener: Sendable {
    var id: String
}

//MARK: Node Lifetime Management

struct CreateNode: Sendable {
    var id: String
    var graphicName: String
    private var type: String
    var graphicType: GraphicType {
        return GraphicType(rawValue: type)!
    }
    
    init(id: String, graphicName: String, type: GraphicType) {
        self.id = id
        self.graphicName = graphicName
        self.type = type.rawValue
    }
}

struct GetGraphics: Sendable {}

struct GetGraphicsReply: Sendable {
    private var codableArray: [GraphicStruct]
    var graphics: [Graphic] {
        var convertedGraphics = [Graphic]()
        for value in codableArray {
            let graphic = Graphic(id: value.id)
            graphic.suppressMessageSending = true
            
            graphic.alpha = value.alpha
            graphic.graphicType = value.graphicType
            graphic.rotationRadians = value.rotationRadians
            graphic.position = Point(x: value.positionX, y: value.positionY)
            graphic.xScale = value.xScale
            graphic.yScale = value.yScale
            graphic.text = value.text
            graphic.name = value.name
            
            graphic.suppressMessageSending = false
            
            convertedGraphics.append(graphic)
        }
        return convertedGraphics
    }
    
    init(graphicList: [Graphic]) {
        codableArray = [GraphicStruct]()
        for graphic in graphicList {
            codableArray.append(GraphicStruct(id: graphic.id, graphicTypeVal: graphic.graphicType.rawValue, positionX: graphic.position.x, positionY: graphic.position.y, rotationRadians: graphic.rotationRadians, xScale: graphic.xScale, yScale: graphic.yScale, text: graphic.text, alpha: graphic.alpha, name: graphic.name))
        }
    }
}

struct RemovedGraphic: Sendable {
    var id: String
}

// MARK: Image

struct SetImage: Sendable {
    var id: String
    private var path: String?
    var image: Image? {
        if let realPath = path {
            return Image(imageLiteralResourceName: realPath)
        }
        else {
            return nil
        }
    }
    
    init(inId: String, inImage: Image?) {
        id = inId
        let inPath = inImage?.path
        path = inPath
    }
}

struct SetTiledImage: Sendable {
    var id: String
    var columns: Int?
    var rows: Int?
    var isDynamic: Bool?
    private var path: String?
    var image: Image? {
        if let realPath = path {
            return Image(imageLiteralResourceName: realPath)
        }
        else {
            return nil
        }
    }
    init(inId: String, numColumns: Int?, numRows: Int?, dynamic: Bool?, inImage: Image?) {
        id = inId
        columns = numColumns
        rows = numRows
        isDynamic = dynamic
        let inPath = inImage?.path
        path = inPath
    }
}

// MARK: Shape
struct SetShape: Sendable {
    // common shape elements
    var id: String
    private var carryingShape: Bool
    private var type: String?
    private var color: ColorStruct?
    private var gradientColor: ColorStruct?
    
    //circle, polygon, and star specific
    private var radius: Int?
    
    //square specific
    private var cornerRadius: Double?
    private var width: Int?
    private var height: Int?
    
    //polygon specific
    private var sides: Int?
    
    //star specific
    private var sharpness: Double?
    private var points: Int?
    
    var shape: BasicShape? {
        if carryingShape, let unwrappedColor = color, let unwrappedGradient = gradientColor,
            let wrappedType = type, let shapeType = BasicShape.ShapeType.init(rawValue: wrappedType){
            switch shapeType {
            case .circle:
                return .circle(radius: radius!, color: unwrappedColor.color, gradientColor: unwrappedGradient.color)
            case .rectangle:
                return .rectangle(width: width!, height: height!, cornerRadius: cornerRadius!, color: unwrappedColor.color, gradientColor: unwrappedGradient.color)
            case .polygon:
                return .polygon(radius: radius!, sides: sides!, color: unwrappedColor.color, gradientColor: unwrappedGradient.color)
            case .star:
                return .star(radius: radius!, points: points!, sharpness: sharpness!, color: unwrappedColor.color, gradientColor: unwrappedGradient.color)
            }
        }
        return nil
    }
    
    init(inId: String, inShape: BasicShape?) {
        id = inId
        if let unwrappedShape = inShape {
            carryingShape = true
            switch unwrappedShape {
            case .circle(radius: let rad, color: let color, gradientColor: let gradient):
                type = BasicShape.ShapeType.circle.rawValue
                radius = rad
                self.color = ColorStruct(newColor: color)
                gradientColor = ColorStruct(newColor: gradient)
            case .rectangle(width: let wide, height: let high, cornerRadius: let corner, color: let color, gradientColor: let gradient):
                type = BasicShape.ShapeType.rectangle.rawValue
                self.color = ColorStruct(newColor: color)
                gradientColor = ColorStruct(newColor: gradient)
                cornerRadius = corner
                width = wide
                height = high
            case .polygon(radius: let rad, sides: let side, color: let color, gradientColor: let gradient):
                type = BasicShape.ShapeType.polygon.rawValue
                self.color = ColorStruct(newColor: color)
                gradientColor = ColorStruct(newColor: gradient)
                radius = rad
                sides = side
            case .star(radius: let rad, points: let point, sharpness: let sharp, color: let color, gradientColor: let gradient):
                type = BasicShape.ShapeType.star.rawValue
                self.color = ColorStruct(newColor: color)
                gradientColor = ColorStruct(newColor: gradient)
                radius = rad
                points = point
                sharpness = sharp
            }
        }
        else {
            carryingShape = false
        }
    }
}

// MARK: Text related
struct SetText: Sendable {
    var id: String
    var text: String?
}

struct SetTextColor: Sendable {
    var id: String
    private var colorstruct: ColorStruct
    var color: Color {
        return colorstruct.color
    }
    
    init(inId: String, color: Color) {
        id = inId
        colorstruct = ColorStruct(newColor: color)
    }
}

struct SetFontSize: Sendable {
    var id: String
    var size: Int
}

struct SetZPosition: Sendable {
    var id: String
    var position: Double
}

struct SetFontName: Sendable {
    var id: String
    var name: String
}

//MARK: Sprite properties

struct SetAffectedByGravity: Sendable {
    var id: String
    var gravity: Bool
}

struct SetIsDynamic: Sendable {
    var id: String
    var isDynamic: Bool
}

struct SetAllowsRotation: Sendable {
    var id: String
    var allowsRotation: Bool
}

struct SetXScale: Sendable {
    var id: String
    var xScale: Double
}

struct SetYScale: Sendable {
    var id: String
    var yScale: Double
}

struct SetVelocity: Sendable {
    var id: String
    var velocity: CGVector
}

struct SetRotationalVelocity: Sendable {
    var id: String
    var rotationalVelocity: Double
}

struct SetBounciness: Sendable {
    var id: String
    var bounciness: Double
}

struct SetFriction: Sendable {
    var id: String
    var friction: Double
}

struct SetDensity: Sendable {
    var id: String
    var density: Double
}

struct SetDrag: Sendable {
    var id: String
    var drag: Double
}

struct SetRotationalDrag: Sendable {
    var id: String
    var drag: Double
}

struct SetInteractionCategory: Sendable {
    var id: String
    var interactionCategory: InteractionCategory
}

struct SetCollisionCategories: Sendable {
    var id: String
    var collisionCategories: InteractionCategory
}

struct SetContactCategories: Sendable {
    var id: String
    var contactCategories: InteractionCategory
}

// MARK: Joints

struct CreateFixedJoint: Sendable {
    var jointID: String
    var firstSpriteID: String
    var secondSpriteID: String?
    var anchor: Point
    
    init(jointID: String, from firstSpriteID: String, to secondSpriteID: String?, at anchor: Point) {
        self.jointID = jointID
        self.firstSpriteID = firstSpriteID
        self.secondSpriteID = secondSpriteID
        self.anchor = anchor
    }
}

struct CreateLimitJoint: Sendable {
    var jointID: String
    var firstSpriteID: String
    var firstAnchor: Point
    var secondSpriteID: String?
    var secondAnchor: Point
    
    init(jointID: String, from firstSpriteID: String, at firstAnchor: Point, to secondSpriteID: String?, at secondAnchor: Point) {
        self.jointID = jointID
        self.firstSpriteID = firstSpriteID
        self.firstAnchor = firstAnchor
        self.secondSpriteID = secondSpriteID
        self.secondAnchor = secondAnchor
    }
}

struct CreatePinJoint: Sendable {
    var jointID: String
    var firstSpriteID: String
    var secondSpriteID: String?
    var anchor: Point
    
    init(jointID: String, from firstSpriteID: String, to secondSpriteID: String?, at anchor: Point) {
        self.jointID = jointID
        self.firstSpriteID = firstSpriteID
        self.secondSpriteID = secondSpriteID
        self.anchor = anchor
    }
}

struct CreateSlidingJoint: Sendable {
    var jointID: String
    var firstSpriteID: String
    var secondSpriteID: String?
    var anchor: Point
    var axis: Vector
    
    init(jointID: String, from firstSpriteID: String, to secondSpriteID: String?, at anchor: Point, axis: Vector) {
        self.jointID = jointID
        self.firstSpriteID = firstSpriteID
        self.secondSpriteID = secondSpriteID
        self.anchor = anchor
        self.axis = axis
    }
}

struct CreateSpringJoint: Sendable {
    var jointID: String
    var firstSpriteID: String
    var firstAnchor: Point
    var secondSpriteID: String?
    var secondAnchor: Point
    
    init(jointID: String, from firstSpriteID: String, at firstAnchor: Point, to secondSpriteID: String?, at secondAnchor: Point) {
        self.jointID = jointID
        self.firstSpriteID = firstSpriteID
        self.firstAnchor = firstAnchor
        self.secondSpriteID = secondSpriteID
        self.secondAnchor = secondAnchor
    }
}

struct AddJoint: Sendable {
    var jointID: String
}

struct RemoveJoint: Sendable {
    var jointID: String
}

struct DeleteJoint: Sendable {
    var jointID: String
}

struct SetLimitJointMaxLength: Sendable {
    var id: String
    var maxLength: Double
}

struct SetPinJointRotationSpeed: Sendable {
    var id: String
    var speed: Double
}

struct SetPinJointEnableAngleLimits: Sendable {
    var id: String
    var enableLimits: Bool
}

struct SetPinJointLowerAngleLimit: Sendable {
    var id: String
    var lowerAngleLimit: Double
}

struct SetPinJointUpperAngleLimit: Sendable {
    var id: String
    var upperAngleLimit: Double
}

struct SetPinJointAxleFriction: Sendable {
    var id: String
    var axleFriction: Double
}

struct SetSlidingJointEnableDistanceLimits: Sendable {
    var id: String
    var enableLimits: Bool
}

struct SetSlidingJointMinimumDistanceLimit: Sendable {
    var id: String
    var minimumDistanceLimit: Double
}

struct SetSlidingJointMaximumDistanceLimit: Sendable {
    var id: String
    var maximumDistanceLimit: Double
}

struct SetSpringJointDamping: Sendable {
    var id: String
    var damping: Double
}

struct SetSpringJointFrequency: Sendable {
    var id: String
    var frequency: Double
}

// MARK: Touch handling

struct SceneTouchEvent: Sendable {
    private var point: Point
    private var previous: Double
    private var firstTouch: Bool
    private var firstTouchInGraphic: Bool
    private var lastTouchInGraphic: Bool
    private var lastTouch: Bool
    private var doubleTouch: Bool
    private var graphicStruct: GraphicStruct?
    private var capturedGraphicID: String
    var touch: Touch {
        var touch:Touch
        
        if let gStruct = graphicStruct {
            let graphic = Graphic(id: gStruct.id)
            graphic.suppressMessageSending = true
            
            graphic.alpha = gStruct.alpha
            graphic.graphicType = gStruct.graphicType
            graphic.rotationRadians = gStruct.rotationRadians
            graphic.position = Point(x: gStruct.positionX, y: gStruct.positionY)
            graphic.xScale = gStruct.xScale
            graphic.yScale = gStruct.yScale
            graphic.text = gStruct.text
            graphic.name = gStruct.name
            
            graphic.suppressMessageSending = false
            
            touch = Touch(position: point, previousPlaceDistance: previous, firstTouch: firstTouch, touchedGraphic: graphic, capturedGraphicID: capturedGraphicID)
        }
        else {
            touch = Touch(position: point, previousPlaceDistance: previous, firstTouch: firstTouch)
        }
        
        touch.firstTouchInGraphic = firstTouchInGraphic
        touch.lastTouchInGraphic = lastTouchInGraphic
        touch.lastTouch = lastTouch
        touch.doubleTouch = doubleTouch
        
        return touch
    }
    
    init(inTouch: Touch) {
        point = inTouch.position
        previous = inTouch.previousPlaceDistance
        firstTouch = inTouch.firstTouch
        firstTouchInGraphic = inTouch.firstTouchInGraphic
        lastTouchInGraphic = inTouch.lastTouchInGraphic
        lastTouch = inTouch.lastTouch
        doubleTouch = inTouch.doubleTouch
        capturedGraphicID = inTouch.capturedGraphicID
        if let unwrapped = inTouch.touchedGraphic {
            graphicStruct = GraphicStruct(id: unwrapped.id, graphicTypeVal: unwrapped.graphicType.rawValue, positionX: unwrapped.position.x, positionY: unwrapped.position.y, rotationRadians: unwrapped.rotationRadians, xScale: unwrapped.xScale, yScale: unwrapped.yScale, text: unwrapped.text, alpha: unwrapped.alpha, name: unwrapped.name)
        }
        else {
            graphicStruct = nil
        }
    }
}

struct TouchEventAcknowledgement: Sendable {}

struct SceneCollisionEvent: Sendable {
    private var spriteA: SpriteStruct
    private var spriteB: SpriteStruct
    private var vector: Vector
    private var force: Double
    private var isOverlapping: Bool
    var collision: Collision {
        let transformedSpriteA = spriteA.sprite
        let transformedSpriteB = spriteB.sprite
        return Collision(spriteA: transformedSpriteA, spriteB: transformedSpriteB, angle: vector, force: force, isOverlapping: isOverlapping)
    }
    
    init(collision: Collision) {
        spriteA = SpriteStruct(sprite: collision.spriteA)
        spriteB = SpriteStruct(sprite: collision.spriteB)
        vector = collision.angle
        force = collision.force
        isOverlapping = collision.isOverlapping
    }
}

struct RunAction: Sendable {
    var id: String
    var name: String?
    private var data: Data
    var action: SKAction {
        get {
            return (try? NSKeyedUnarchiver.unarchivedObject(ofClass: SKAction.self, from: data)) ?? SKAction()
        }
    }
    init(id: String, action: SKAction, name: String? = nil) {
        self.id = id
        self.name = name
        data = (try? NSKeyedArchiver.archivedData(withRootObject: action, requiringSecureCoding: true)) ?? Data()
    }
}

struct RemoveAction: Sendable {
    var id: String
    var name: String
}

struct AddParticleEmitter: Sendable {
    var id: String
    var name: String
    var duration: Double
    private var colorStruct: ColorStruct
    var color: Color {
        return colorStruct.color
    }
    
    init(id: String, name: String, duration: Double, color: Color) {
        self.id = id
        self.name = name
        self.duration = duration
        colorStruct = ColorStruct(newColor: color)
    }
}

struct RemoveAllActions: Sendable {
    var id: String
}

struct RunAnimation: Sendable {
    var id: String
    var animation: String
    var duration: Double
    var numberOfTimes: Int
}

struct RunCustomAnimation: Sendable {
    var id: String
    var animationSequence: [String]
    var duration: Double
    var numberOfTimes: Int
}

struct ApplyImpulse: Sendable {
    var id: String
    var vector: CGVector
}

struct ApplyForce: Sendable {
    var id: String
    var vector: CGVector
    var duration: Double
}

struct UseOverlay: Sendable {
    private var raw: Int
    var overlay: Overlay {
        return Overlay(rawValue: raw)!
    }
    
    init(inOverlay: Overlay) {
        raw = inOverlay.rawValue
    }
}

struct SetAllowsTouchInteraction: Sendable {
    var id: String
    var allowsTouchInteraction: Bool
}

struct SetDisablesOnDisconnect: Sendable {
    var id: String
    var disablesOnDisconnect: Bool
}

struct Glow: Sendable {
    var id: String
    var radius: Double
    var period: Double
    var count: Int
}

struct SetTintColor: Sendable {
    var id: String
    private var colorStruct: ColorStruct
    var color: Color? {
        return colorStruct.color
    }
    var blend: Double
    
    init(inId: String, color: Color?, inBlend: Double) {
        id = inId
        colorStruct = ColorStruct(newColor: color != nil ? color! : Color.clear)
        blend = inBlend
    }
}

struct AddAudio: Sendable {
    var id: String
    var sound: Sound
    var positional: Bool
    var looping: Bool
    var volume: Double
}

struct RemoveAudio: Sendable {
    var id: String
}

struct PlayAudio: Sendable {
    var id: String
}

struct StopAudio: Sendable {
    var id: String
}

struct SetIsAudioPositional: Sendable {
    var id: String
    var isAudioPositional: Bool
}

struct GraphicStruct: Codable {
    var id: String
    var graphicTypeVal: String
    var graphicType: GraphicType {
        get {
            return GraphicType(rawValue: graphicTypeVal)!
        }
        set {
            graphicTypeVal = newValue.rawValue
        }
    }
    var positionX: Double
    var positionY: Double
    var rotationRadians: CGFloat
    var xScale: Double
    var yScale: Double
    var text: String
    var alpha: Double
    var name: String
}

struct ColorStruct: Codable {
    private var red: Double
    private var green: Double
    private var blue: Double
    private var alpha: Double
    var color: UIColor {
        get {
            return UIColor(red: red, green: green, blue: blue, alpha: alpha)
        }
    }
    public init(newColor: Color) {
        red = newColor.redComponent
        blue = newColor.blueComponent
        green = newColor.greenComponent
        alpha = newColor.alpha
    }
}

struct SpriteStruct: Codable {
    var isDynamic: Bool
    var allowsRotation: Bool
    var isAffectedByGravity: Bool
    
    var bounciness: Double
    var friction: Double
    var density: Double
    var drag: Double
    var rotationalDrag: Double
    
    var velocity: Vector
    var rotationalVelocity: Double
    
    var interactionCategory: InteractionCategory
    var collisionNotificationCategories: InteractionCategory
    var collisionCategories: InteractionCategory
    
    private var backingGraphic: GraphicStruct
    public var sprite: Sprite {
        get {
            let newSprite = Sprite(id: backingGraphic.id, graphicType: .sprite)
            newSprite.suppressMessageSending = true
            
            newSprite.allowsRotation = allowsRotation
            newSprite.isDynamic = isDynamic
            newSprite.isAffectedByGravity = isAffectedByGravity
            
            newSprite.bounciness = bounciness
            newSprite.friction = friction
            newSprite.density = density
            newSprite.drag = drag
            newSprite.rotationalDrag = rotationalDrag
            
            newSprite.velocity = velocity
            newSprite.rotationalVelocity = rotationalVelocity
            
            newSprite.interactionCategory = interactionCategory
            newSprite.collisionNotificationCategories = collisionNotificationCategories
            newSprite.collisionCategories = collisionCategories
            
            newSprite.position = Point(x: backingGraphic.positionX, y: backingGraphic.positionY)
            newSprite.rotationRadians = backingGraphic.rotationRadians
            newSprite.xScale = backingGraphic.xScale
            newSprite.yScale = backingGraphic.yScale
            newSprite.text = backingGraphic.text
            newSprite.alpha = backingGraphic.alpha
            newSprite.name = backingGraphic.name
            
            newSprite.suppressMessageSending = false
            
            return newSprite
        }
    }
    
    public init(sprite: Sprite) {
        isDynamic = sprite.isDynamic
        allowsRotation = sprite.allowsRotation
        isAffectedByGravity = sprite.isAffectedByGravity
        
        bounciness = sprite.bounciness
        friction = sprite.friction
        density = sprite.density
        drag = sprite.drag
        rotationalDrag = sprite.rotationalDrag
        
        velocity = sprite.velocity
        rotationalVelocity = sprite.rotationalVelocity
        
        interactionCategory = sprite.interactionCategory
        collisionNotificationCategories = sprite.collisionNotificationCategories
        collisionCategories = sprite.collisionCategories
        
        backingGraphic = GraphicStruct(id: sprite.id, graphicTypeVal: sprite.graphicType.rawValue, positionX: sprite.position.x, positionY: sprite.position.y,
                                       rotationRadians: sprite.rotationRadians, xScale: sprite.xScale, yScale: sprite.yScale, text: sprite.text, alpha: sprite.alpha, name: sprite.name)
    }
}

struct SetLightSensorImage: Sendable {
    private var imageData: Data?
    var image: UIImage? {
        if let _ = imageData {
            return UIImage(data: imageData!)
        }
        return nil
    }
    
    init(inImage: UIImage?) {
        if let unwrappedImage = inImage {
            imageData = unwrappedImage.pngData()
        }
        else {
            imageData = nil
        }
    }
}

struct PlaceRelativeGraphic: Sendable {
    var graphic: String
    var relativeTo: String
    var xOffset: Double
    var yOffset: Double
}
