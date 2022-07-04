//
//  Scene.swift
//  
//  Copyright © 2020 Apple Inc. All rights reserved.
//

import Foundation
import UIKit
import PlaygroundSupport
import SPCCore
import SPCAssessment
import SPCIPC

/// The Scene is the container for all nodes and graphics created.
///
/// - localizationKey: Scene
public class Scene /*: PlaygroundRemoteLiveViewProxyDelegate*/ {
    
    private var activeCollisions = Set<CollisionPair>()
    
    public static let sceneSize = CGSize(width: 1024, height: 1024)
    
    var runLoopRunning = false {
        didSet {
            guard !Message.isLiveViewOnly else { return }
            
            if runLoopRunning {
                CFRunLoopRun()
            }
            else {
                CFRunLoopStop(CFRunLoopGetMain())
            }
        }
    }
    
    /// A dictionary of the graphics that have been placed on the Scene, using each graphic’s id property as keys.
    ///
    /// - localizationKey: Scene.placedGraphics
    public var placedGraphics = [String: Graphic]()
    
    private var backingGraphics: [Graphic] = []
    
    /// The collection of graphics on the Scene.
    ///
    /// - localizationKey: Scene.graphics
    public var graphics: [Graphic] {
        get {
            SceneProxy().getGraphics()
            runLoopRunning = true
            
            defer {
                backingGraphics.removeAll()
            }
            
            return backingGraphics
        }
    }
    
    
    /// Determines whether a graphic on the scene, if touched first, will capture all subsequent touches delivered to the scene. If set to `true`, a first touch delivered to a graphic or the scene will only activate the touchMoved handlers for that graphic or the scene. Set to `false` by default.
    ///
    /// - localizationKey: Scene.capturesTouches
    public var capturesTouches = false
    
    /// Returns the graphics on the Scene with the specified name.
    ///
    /// - Parameter name: A name you have given to a graphic or set of graphics.
    ///
    /// - localizationKey: Scene.getGraphics(named:)
    public func getGraphics(named name: String) ->  [Graphic] {
        return graphics.filter( { $0.name == name })
    }
    
    /// Returns the graphics on the Scene with a name containing the specified text.
    ///
    /// - Parameter text: The name you have given to a graphic or set of graphics.
    ///
    /// - localizationKey: Scene.getGraphicsWithName(containing:)
    public func getGraphicsWithName(containing text: String) -> [Graphic] {
        return graphics.filter( { $0.name.contains(text) })
    }
    
    /// Removes all of the graphics with a certain name from the Scene.
    ///
    /// - Parameter name: The name you have given to a graphic or set of graphics.
    ///
    /// - localizationKey: Scene.removeGraphics(named:)
    public func removeGraphics(named name: String) {
        for graphic in graphics.filter( { $0.name == name }) {
            graphic.remove()
        }
    }
    
    /// Removes all of the graphics on the Scene.
    ///
    /// - Parameter graphic: Type in the graphic you want to remove here.
    ///
    /// - localizationKey: Scene.remove(_:)
    public func remove(_ graphic: Graphic) {
        graphic.remove()
    }
    
    /// Gets all of the graphics in a certain area of the Scene.
    ///
    /// - Parameter point: The center point of the boundary you want to target.
    /// - Parameter bounds: The width and height of the area.
    ///
    /// - localizationKey: Scene.getGraphics(at:in:)
    public func getGraphics(at point: Point, in bounds: Size) -> [Graphic] {
        var graphicsInArea = [Graphic]()
        let bottomLeft = Point(x: point.x - bounds.width / 2, y: point.y - bounds.height / 2)
        let area = CGRect(origin: CGPoint(bottomLeft), size: CGSize(width: bounds.width, height: bounds.height))
        
        for graphic in graphics {
            if area.contains(CGPoint(graphic.position)) {
                graphicsInArea.append(graphic)
            }
        }
        return graphicsInArea
    }
    
    private var lastPlacePosition: Point = Point(x: Double.greatestFiniteMagnitude, y: Double.greatestFiniteMagnitude)
    private var graphicsPlacedDuringCurrentInteraction = Set<Graphic>()
    
    /// Initialize a Scene.
    ///
    /// - localizationKey: Scene()
    public init() {
        //  The user process must remain alive to receive touch event messages from the live view process.
        let page = PlaygroundPage.current
        page.needsIndefiniteExecution = true
        
        clear()
        
        SceneUserCodeProxy.registerToReceiveDecodedMessage(as: self)
        
        NotificationCenter.default.addObserver(forName: UIAccessibility.voiceOverStatusDidChangeNotification, object: nil, queue: .main) { [unowned self] notification in
            self.onVoiceOverStatusChanged?(UIAccessibility.isVoiceOverRunning)
        }
    }
    
    public func remoteLiveViewProxyConnectionClosed(_ remoteLiveViewProxy: PlaygroundRemoteLiveViewProxy) {
        clearInteractionState()
    }
    
    func clearInteractionState() {
        graphicsPlacedDuringCurrentInteraction.removeAll()
        lastPlacePosition = Point(x: Double.greatestFiniteMagnitude, y: Double.greatestFiniteMagnitude)
    }
    
    /// The Scene’s background image.
    ///
    /// - localizationKey: Scene.backgroundImage
    public var backgroundImage: Image? = nil {
        didSet {
            SceneProxy().setSceneBackgroundImage(image: backgroundImage)
        }
    }
    
    /// The vertical gravity; the default is `-9.8`.
    ///
    /// - localizationKey: Scene.verticalGravity
    public var verticalGravity: Double = -9.8 {
        didSet {
            SceneProxy().setSceneGravity(vector: CGVector(dx: horizontalGravity, dy: verticalGravity))
        }
    }
    
    /// The horizontal gravity; the default is `0`.
    ///
    /// - localizationKey: Scene.horizontalGravity
    public var horizontalGravity: Double = 0 {
        didSet {
            SceneProxy().setSceneGravity(vector: CGVector(dx: horizontalGravity, dy: verticalGravity))
        }
    }
    
    /// Set to `true` to show a 50 x 50 pixel grid over the background. This can be helpful when deciding where to place things on the Scene.
    ///
    /// - localizationKey: Scene.isGridVisible
    public var isGridVisible: Bool = false {
        didSet {
            SceneProxy().setSceneGridVisible(isVisible: isGridVisible)
        }
    }
    
    /// Set to `true` to have graphics bounce back into the Scene when they hit a border.
    ///
    /// - localizationKey: Scene.hasCollisionBorder
    public var hasCollisionBorder: Bool = true {
        didSet {
            SceneProxy().setBorderPhysics(hasCollisionBorder: hasCollisionBorder)
        }
    }
    
    /// The Scene’s background color.
    ///
    /// - localizationKey: Scene.backgroundColor
    public var backgroundColor: Color  = .white {
        didSet {
            SceneProxy().setSceneBackgroundColor(color: backgroundColor)
        }
    }
    
    /// Whether VoiceOver is running.
    ///
    /// - localizationKey: Scene.isVoiceOverRunning
    public static var isVoiceOverRunning: Bool {
        return UIAccessibility.isVoiceOverRunning
    }
    
    /// The list of active joints in the scene.
    ///
    /// - localizationKey: Scene.joints
    public private(set) var joints: Set<Joint> = []
    
    // MARK: Public Event Handlers
    
    /// The function that’s called when your touch moves across the scene.
    ///
    /// - localizationKey: Scene.onTouchMovedHandler
    public var onTouchMovedHandler: ((Touch) -> Void)?
    
    // Favoring setting an onTouched handler for individual graphics instead of this more generalized method - no longer exposing to learner.
    var onGraphicTouchedHandler: ((Graphic) -> Void)?
    
    /// The function that’s called when two things collide onscreen.
    ///
    /// The `collision` parameter passed to the handler contains information about the collision.
    ///
    /// - localizationKey: Scene.onCollisionHandler
    public var onCollisionHandler: ((Collision) -> Void)?
    
    /// Sets the function that’s called when graphics collide in a Scene.
    /// - parameter handler: The function to be called whenever a collision occurs.
    ///
    /// - localizationKey: Scene.setOnCollisionHandler(_:)
    public func setOnCollisionHandler(_ handler: @escaping ((Collision) -> Void)) {
        onCollisionHandler = handler
    }
    
    /// Sets the function that’s called when your touch moves across the Scene.
    ///
    /// - Parameter handler: The function to be called whenever the touch data is updated i.e. when your touch has moved.
    ///
    /// - localizationKey: Scene.setOnTouchMovedHandler(_:)
    public func setOnTouchMovedHandler(_ handler: ((Touch) -> Void)?) {
        onTouchMovedHandler = handler
    }

    
    // Favoring setting an onTouched handler for individual graphics instead of this more generalized method - no longer exposing to learner.
    func setOnGraphicTouchedHandler(_ handler: ((Graphic) -> Void)?) {
        onGraphicTouchedHandler = handler
    }
    
    /// The function that’s called when VoiceOver status changes.
    ///
    /// - localizationKey: Scene.onVoiceOverStatusChanged
    public var onVoiceOverStatusChanged: ((Bool) -> Void)?
    
    // MARK: Public Methods
    
    /// Removes all of the graphics from the Scene.
    ///
    /// - localizationKey: Scene.clear()
    public func clear() {
        placedGraphics.removeAll()
        SceneProxy().clearScene()
    }
    
    /// Creates a Sprite with an image and a name.
    ///
    /// - Parameter from: An image you choose to use as the Sprite.
    /// - Parameter named: A name you give the Sprite.
    ///
    /// - localizationKey: Scene.createSprites(from:named:)
    public func createSprites(from images: [Image], named: String) -> [Sprite] {
        var groupOfSprites = [Sprite]()
        
        for image in images {
            let sprite = Sprite(image: image, name: named)
            groupOfSprites.append(sprite)
        }
        return groupOfSprites
    }
    
    /// Places a graphic at a point on the Scene.
    ///
    /// - Parameter graphic: The graphic to be placed on the Scene.
    /// - Parameter at: The point at which the graphic is placed.
    /// - Parameter anchoredTo: The anchor point within the graphic from which the graphic is initially placed. Defaults to the center.
    ///
    /// - localizationKey: Scene.add(_:at:anchoredTo:)
    public func place(_ graphic: Graphic, at: Point, anchoredTo: AnchorPoint = .center) {
        SceneProxy().placeGraphic(id: graphic.id, position: CGPoint(at), isPrintable: false, anchorPoint: anchoredTo)
        graphicsPlacedDuringCurrentInteraction.insert(graphic)
        placedGraphics[graphic.id] = graphic
        lastPlacePosition = at
        
        graphic.suppressMessageSending = true
        graphic.position = at
        graphic.suppressMessageSending = false
    }
    
    /// Places a graphic center, and on top of, a specific graphic.
    ///
    /// - Parameter graphic: The graphic to be placed on the Scene.
    /// - Parameter relativeTo: The graphic on which graphic will be placed.
    /// - Parameter xOffset: the number of points to the left or right graphic should be placed.
    /// - Parameter yOffset: the number of points to up or down the graphic should be placed.
    ///
    /// - localizationKey: Scene.place(_:relativeTo:xOffset:yOffset:)
    public func place(_ graphic: Graphic, relativeTo: Graphic, xOffset: Double, yOffset: Double) {
        SceneProxy().placeRelativeGraphic(graphic: graphic.id, relativeTo: relativeTo.id, xOffset: xOffset, yOffset: yOffset)
    }
    
    /// Returns an array of count points on a circle around the center point.
    ///
    /// - Parameter radius: The radius of the circle.
    /// - Parameter count: The number of points to return.
    ///
    /// - localizationKey: Scene.circlePoints(radius:count:)
    public func circlePoints(radius: Double, count: Int) -> [Point] {
        
        var points = [Point]()
        
        let slice = 2 * Double.pi / Double(count)
        
        let center = Point(x: 0, y: 0)
        
        for i in 0..<count {
            let angle = slice * Double(i)
            let x = center.x + (radius * cos(angle))
            let y = center.y + (radius * sin(angle))
            points.append(Point(x: x, y: y))
        }
        
        return points
    }
    
    /// Returns an array of count points in a square box around the center point.
    ///
    /// - Parameter width: The width of each side of the box.
    /// - Parameter count: The number of points to return.
    ///
    /// - localizationKey: Scene.squarePoints(width:count:)
    public func squarePoints(width: Double, count: Int) -> [Point] {
        
        var points = [Point]()
        
        guard count > 4 else { return points }
        
        let n = count / 4
        
        let sparePoints = count - (n * 4)
        
        let delta = width / Double(n)
        
        var point = Point(x: -width/2, y: -width/2)
        points.append(point)
        for _ in 0..<(n - 1) {
            point.y += delta
            points.append(point)
        }
        point = Point(x: -width/2, y: width/2)
        points.append(point)
        for _ in 0..<(n - 1) {
            point.x += delta
            points.append(point)
        }
        point = Point(x: width/2, y: width/2)
        points.append(point)
        for _ in 0..<(n - 1) {
            point.y -= delta
            points.append(point)
        }
        point = Point(x: width/2, y: -width/2)
        points.append(point)
        for _ in 0..<(n - 1) {
            point.x -= delta
            points.append(point)
        }
        
        // Duplicate remainder points at the end
        for _ in 0..<sparePoints {
            points.append(point)
        }
        
        return points
    }
    
    func rotatePoints(points: [Point], angle: Double) -> [Point] {
        
        var rotatedPoints = [Point]()
        
        let angleRadians = (angle / 360.0) * (2.0 * Double.pi)
        
        for point in points {
            let x = point.x * cos(angleRadians) - point.y * sin(angleRadians)
            let y = point.y * cos(angleRadians) + point.x * sin(angleRadians)
            rotatedPoints.append(Point(x: x, y: y))
        }
        return rotatedPoints
    }
    
    /// Returns an array of count points in a square grid of the given size, rotated by angle (in degrees).
    ///
    /// - Parameter size: The size of each side of the grid.
    /// - Parameter count: The number of points to return.
    /// - Parameter angle: The angle of rotation in degrees.
    ///
    /// - localizationKey: Scene.gridPoints(size:count:angle:)
    public func gridPoints(size: Double, count: Int, angle: Double = 0) -> [Point] {
        
        var points = [Point]()
        
        // Get closest value for n that fits an n * n grid inside count.
        let n = Int(floor(sqrt(Double(count))))
        
        if n <= 1 {
            return [Point(x: 0, y: 0)]
        }
        
        let surplusPoints = count - (n * n)
        
        let delta = size / Double(n - 1)
        
        let startX = -(size / 2.0)
        let startY = -(size / 2.0)
        
        var x = startX
        var y = startY
        
        for _ in 0..<n {
            for _ in 0..<n {
                points.append(Point(x: x, y: y))
                x += delta
            }
            y += delta
            x = startX
        }
        
        // Duplicate and overlay any surplus points after the n * n grid has been added.
        for i in 0..<surplusPoints {
            points.append(points[i])
        }
        
        if angle != 0 {
            points = rotatePoints(points: points, angle: angle)
        }
        
        return points
    }
    
    public func useOverlay(overlay: Overlay) {
        SceneProxy().useOverlay(overlay: overlay)
    }
    
    /// Sets the graphic that will be the Scene’s positional audio listener.
    ///
    /// - localizationKey: Scene.setPositionalAudioListener(_:)
    public func setPositionalAudioListener(_ graphic: Graphic) {
        SceneProxy().setScenePositionalAudioListener(id: graphic.id)
    }
}

extension Scene: SceneUserCodeProxyProtocol {
    func updateGraphicAttributes(positions: [String : CGPoint], velocities: [String: CGVector], rotationalVelocities: [String: CGFloat], sizes: [String : CGSize]) {
        for id in positions.keys {
            if let graphic = placedGraphics[id],
                let position = positions[id] {
                
                graphic.suppressMessageSending = true
                graphic.position = Point(position)
                graphic.suppressMessageSending = false
            }
        }
        
        for id in velocities.keys {
            if let sprite = placedGraphics[id] as? Sprite,
                let velocity = velocities[id] {
                
                sprite.suppressMessageSending = true
                sprite.velocity = Vector(velocity)
                sprite.suppressMessageSending = false
            }
        }
        
        for id in rotationalVelocities.keys {
            if let sprite = placedGraphics[id] as? Sprite,
                let rotationalVelocity = rotationalVelocities[id] {
                
                sprite.suppressMessageSending = true
                sprite.rotationalVelocity = Double(rotationalVelocity)
                sprite.suppressMessageSending = false
            }
        }
        
        for id in sizes.keys {
            if let graphic = placedGraphics[id],
                let size = sizes[id] {
                
                graphic.suppressMessageSending = true
                graphic.size = Size(size)
                graphic.suppressMessageSending = false
            }
        }
    }
    
    public func getGraphicsReply(graphics: [Graphic]) {
        backingGraphics = graphics
        runLoopRunning = false
    }
    
    public func removedGraphic(id: String) {
        placedGraphics.removeValue(forKey: id)
    }
    
    // Handles all logic for touches that are passed through from LiveViewScene.
    public func sceneTouchEvent(touch: Touch) {
        var touch = touch
        var touchHandler: (() -> Void)?
        var touchMovedHandler: ((Touch) -> Void)?
        
        touch.previousPlaceDistance = lastPlacePosition.distance(from: touch.position)
        
        // If the scene allows touches to be captured, then all touch events will go to the first graphic that has been touched in the scene (the capturedGraphic).
        if capturesTouches {
            if let graphic = placedGraphics[touch.capturedGraphicID] {
                if touch.firstTouch {
                    touchHandler = graphic.onTouchHandler
                }
                touchMovedHandler = graphic.onTouchMovedHandler
                // If no capturedGraphic exists, give the touches to the scene.
            } else {
                onTouchMovedHandler?(touch)
            }
        } else {
            // Look to see if there was a touched graphic and if there are any touchHandlers or touchMovedHandlers assigned for that graphic. Assign those to a handler that will be called once all graphics have been examined.
            // Prevents graphics from intercepting touches if they do not have any handlers assigned to them.
            if let touchedGraphic = touch.touchedGraphic, let graphic = placedGraphics[touchedGraphic.id] {
                if touch.firstTouch {
                    touchHandler = graphic.onTouchHandler
                    if let button = graphic as? Button {
                        switch button.buttonType {
                        case .green:
                            SceneProxy().runAnimation(id: button.id, animation: "greenButton", duration: 0.1, numberOfTimes: 1)
                        case .red:
                            SceneProxy().runAnimation(id: button.id, animation: "redButton", duration: 0.1, numberOfTimes: 1)
                        case .rectangularRed:
                            SceneProxy().runAnimation(id: button.id, animation: "rectangularRedButton", duration: 0.1, numberOfTimes: 1)
                        }
                    }
                }
                touchMovedHandler = graphic.onTouchMovedHandler
            }
            // Call the onTouchMovedHandler for the scene if there is one.
            onTouchMovedHandler?(touch)
        }
        
        // Call the touchHandler if there is one.
        touchHandler?()
        
        // Call the touchMovedHandler that was assigned.
        touchMovedHandler?(touch)
        
        SceneProxy().touchEventAcknowledgement()
        
        Message.waitingForTouchAcknowledegment = true
    }
    
    public func sceneCollisionEvent(collision: Collision) {
         
        // Ignore any additional collisions between the pair
        // until the first collision is completely resolved.
        
        let pair = CollisionPair(spriteA: collision.spriteA, spriteB: collision.spriteB)
        guard !activeCollisions.contains(pair) else { return }
        
        activeCollisions.insert(pair)
        defer {
            // Further debounce collisions.
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { [unowned self] (timer) in
                self.activeCollisions.remove(pair)
            }
        }
        
        // Get the placed sprites.
        guard let spriteA = placedGraphics[collision.spriteA.id] as? Sprite else {
            fatalError("*** Unable to find a sprite with the ID: \(collision.spriteA.id) ***")
        }
        
        guard let spriteB = placedGraphics[collision.spriteB.id] as? Sprite else {
            fatalError("*** Unable to find a sprite with the ID: \(collision.spriteB.id) ***")
        }
        
        // Update the placed sprites.
        spriteA.updateMotionState(from: collision.spriteA)
        spriteB.updateMotionState(from: collision.spriteB)
        
        
        // Call the scene’s collision handler, if there is one.
        if let sceneCollisionHandler = onCollisionHandler {
            // Replace the collision’s temporary sprites with the placed sprites.
            let actualCollision = Collision(spriteA: spriteA, spriteB: spriteB, angle: collision.angle, force: collision.force, isOverlapping: collision.isOverlapping)
            sceneCollisionHandler(actualCollision)
        }
        
        // Call spriteA’s collision handler, if there is one.
        if let spriteACollisionHandler = spriteA.onCollisionHandler {
            // If spriteA’s notification categories include spriteB’s interaction category, send the notification to spriteA.
            if !spriteA.collisionNotificationCategories.intersection(spriteB.interactionCategory).isEmpty {
                // Notify spriteA of a collision with spriteB.
                // The collision’s spriteA is the sprite that receives the notification i.e. itself.
                let collision = Collision(spriteA: spriteA, spriteB: spriteB, angle: collision.angle, force: collision.force, isOverlapping: collision.isOverlapping)
                spriteACollisionHandler(collision)
            }
        }
        
        // Call spriteB’s collision handler, if there is one.
        if let spriteBCollisionHandler = spriteB.onCollisionHandler {
            // If spriteB’s notification categories include spriteA’s interaction category, send the notification to spriteB.
            if !spriteB.collisionNotificationCategories.intersection(spriteA.interactionCategory).isEmpty {
                // Notify spriteB of a collision with spriteA.
                // The collision’s spriteA is the sprite that receives the notification i.e. itself.
                let collision = Collision(spriteA: spriteB, spriteB: spriteA, angle: collision.angle, force: collision.force, isOverlapping: collision.isOverlapping)
                spriteBCollisionHandler(collision)
            }
        }
    }
}

// MARK: Joint Support
extension Scene {
    
    /// Adds a joint to the scene.
    ///
    /// - Parameter joint: The joint to be added to the scene.
    ///
    /// - localizationKey: Scene.add(joint:)
    public func add(joint: Joint) {
        assert(!joints.contains(joint))
        
        // Add to the local cache
        joints.insert(joint)
        
        // Add to the scene proxy
        SceneProxy().addJoint(jointID: joint.id)
    }
    
    /// Removes a joint from the scene.
    ///
    /// - Parameter joint: The joint to be removed from the scene.
    ///
    /// - localizationKey: Scene.remove(joint:)
    public func remove(joint: Joint) {
        assert(joints.contains(joint))
        
        // Remove from the local cache
        joints.remove(joint)
        
        // Remove from the scene proxy
        SceneProxy().removeJoint(jointID: joint.id)
    }
    
    /// Removes all of the joints with the specified name from the scene.
    ///
    /// - Parameter name: The name you have given to a joint or set of joints.
    ///
    /// - localizationKey: Scene.removeJoints(named:)
    public func removeJoints(named name: String) {
        for joint in joints.filter( { $0.name == name } ) {
            remove(joint: joint)
        }
    }
}
