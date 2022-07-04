//
//  LiveViewScene.swift
//  
//  Copyright © 2020 Apple Inc. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit
import Dispatch
import PlaygroundSupport
import AVFoundation
import SPCCore
import SPCAudio
import SPCAccessibility
import SPCAssessment
import SPCIPC
import SPCLiveView

private let sceneSize = CGSize(width:1000, height: 1000)

private class BackgroundContainerNode : SKSpriteNode {
    var transparencyNode : SKTileMapNode?
    var gridNode : SKSpriteNode?
    var userBackgroundNode : SKSpriteNode?
    var overlayNode = SKSpriteNode()
    
    private let axisLabelSize = CGSize(width: 100, height: 25)
    
    var backgroundColor : UIColor? {
        didSet {
            if let color = backgroundColor {
                self.color = color
                transparencyNode?.isHidden = true
            }
            else {
                self.color = UIColor.clear
                transparencyNode?.isHidden = (backgroundImage == nil)
            }
            update()
        }
    }
    
    var backgroundImage : Image? {
        didSet {
            if let image = backgroundImage {
                if transparencyNode == nil {
                    transparencyNode = self.transparentTileNode()
                    insertChild(transparencyNode!, at: 0)
                }

                if userBackgroundNode == nil  {
                    userBackgroundNode = SKSpriteNode()
                    insertChild(userBackgroundNode!, at: 1)
                }
                
                guard let texture = LiveViewGraphic.texture(for: image, type: .background) else { return }
                // When changing the texture on an SKSpriteNode, one must always reset the scale back to 1.0 first. Otherwise, strange additive scaling effects can occur.
                userBackgroundNode?.xScale = 1.0
                userBackgroundNode?.yScale = 1.0
                userBackgroundNode?.texture = texture
                userBackgroundNode?.size = texture.size()
                
                let wRatio = sceneSize.width / texture.size().width
                let hRatio = sceneSize.height / texture.size().height
                
                // Aspect fit the image if needed
                if (wRatio < 1.0 || hRatio < 1.0) {
                    let ratio = min(wRatio, hRatio)
                    userBackgroundNode?.xScale = ratio
                    userBackgroundNode?.yScale = ratio
                }

                transparencyNode?.isHidden = (backgroundColor != nil)
                userBackgroundNode?.isHidden = false
            }
            else {
                // Cleared the image
                userBackgroundNode?.isHidden = true
                transparencyNode?.isHidden = true
            }
            update()
        }
    }
    
    var overlayImage : Image? {
        didSet {
            if let image = overlayImage {
                guard let texture = LiveViewGraphic.texture(for: image, type: .background) else { return }
                overlayNode.texture = texture
                overlayNode.size = texture.size()
            }
            update()
        }
    }
    
    var isGridOverlayVisible: Bool = false {
        didSet {
            gridNode?.removeFromParent()
            if isGridOverlayVisible {
                if gridNode == nil  {
                    gridNode = SKSpriteNode(texture: SKTexture(imageNamed: "gridLayout"), color: Color.clear, size: sceneSize)
                }
                addChild(gridNode!)
            } else {
                if let gridNode = gridNode {
                    removeChildren(in: [gridNode])
                    
                    self.gridNode = nil
                }
            }
            
            update()
        }
    }

    func update() {
        self.isHidden = (backgroundColor == nil && backgroundImage == nil && overlayImage == nil && isGridOverlayVisible == false)
    }
    
    init() {
        super.init(texture: nil, color: Color.clear, size: sceneSize)
        addChild(overlayNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func transparentTileNode() -> SKTileMapNode {
        let texture = SKTexture(imageNamed: "transparent_background")
        let tileDefinition = SKTileDefinition(texture: texture)
        let tileGroup = SKTileGroup(tileDefinition: tileDefinition)
        let tileSet = SKTileSet(tileGroups: [tileGroup], tileSetType: .grid)
        let tileMapNode = SKTileMapNode(tileSet: tileSet, columns: Int(CGFloat(sceneSize.width) / tileDefinition.size.width) + 1,
                                        rows: Int(CGFloat(sceneSize.height) / tileDefinition.size.height) + 1, tileSize: texture.size(), fillWith: tileGroup)
        tileMapNode.name = "transparentBackgroundNode"
        
        return tileMapNode
    }
}

public class LiveViewScene: SKScene, UIGestureRecognizerDelegate, SKPhysicsContactDelegate, GraphicAccessibilityElementDelegate, BackgroundAccessibilityElementDelegate {
    static let initialPrintPosition = CGPoint(x: 0, y: 400)
    static var printPosition = initialPrintPosition
    
    public static let didCreateGraphic = NSNotification.Name("LiveViewSceneDidCreateGraphic")
    public static let collisionOccurred = NSNotification.Name("LiveViewSceneCollisionOccurred")
    public static let firstGraphicKey = "LiveViewSceneFirstGraphic"
    public static let secondGraphicKey = "LiveViewSceneSecondGraphic"

    let containerNode = SKNode()
    var capturedGraphic: Graphic? = nil
    
    let nc = NotificationCenter.default
    var enterBackgroundObserver: Any?
    var willEnterForegroundObserver: Any?
    
    var blockLightSensorImage = false
    
    private var graphicAccessibilityElementGroupsByID = Dictionary<String, GraphicAccessibilityElement>()
    
    var executionMode: PlaygroundPage.ExecutionMode? = nil {
        didSet {
            updateState(forExecutionMode: executionMode)
        }
    }
    
    private var steppingEnabled : Bool {
        get {
            return executionMode == .step || executionMode == .stepSlowly
        }
    }
    
    private var addedToView = false
    private let backgroundNode = BackgroundContainerNode()
    private var loadscreenNode = SKSpriteNode()
    private var connectedToUserProcess : Bool = false {
        didSet {
            // Only do this if we’re turning it off, not just initializing it
            if !connectedToUserProcess && oldValue == true {
                accessibilityAllowsDirectInteraction = false
                
                setNeedsUpdateAccessibility(notify: false)
            }
        }
    }
    
    // To track when we’ve received the last touch we sent to the user process
    private var lastSentTouch : Touch?

    private var shouldHandleTouches: Bool {
        return connectedToUserProcess /* && selectedTool != nil */
    }
    
    private var graphicsPositionUpdateTimer:Timer? = nil
    
    var graphicsInfo = [String : LiveViewGraphic]() { // keyed by id
        didSet {
            setNeedsUpdateAccessibility(notify: false)
        }
    }
    
    public func graphicsInfo(forName name: String) -> [LiveViewGraphic] {
        return graphicsInfo
        .filter { pair -> Bool in
            let (_, graphic) = pair
            return graphic.name == name
        }
        .map { pair -> LiveViewGraphic in
            let (_, graphic) = pair
            return graphic
        }
    }
    
    public func graphicsInfo(nameStartsWith prefix: String) -> [LiveViewGraphic] {
        return graphicsInfo
        .filter { pair -> Bool in
            let (_, graphic) = pair
            return graphic.name.starts(with: prefix)
        }
        .map { pair -> LiveViewGraphic in
            let (_, graphic) = pair
            return graphic
        }
    }
    
    var joints = [String: SKPhysicsJoint]() // Keyed by Joint ID.
    
    var axElements = [UIAccessibilityElement]()
    
    private var instruments = [Instrument.Kind: Instrument]()
    private var instrumentsEngine: AudioPlayerEngine = {
        let audioPlayerEngine = AudioPlayerEngine()
        audioPlayerEngine.start()
        return audioPlayerEngine
    }()
        
    func updateState(forExecutionMode: PlaygroundPage.ExecutionMode?) {
        guard let executionMode = executionMode else { return }
        switch executionMode {
        case .step, .stepSlowly:
            Message.shouldWaitForTouchAcknowledgement = true
            
        default:
            Message.shouldWaitForTouchAcknowledgement = false
        }
    }
    
    public var backgroundImage: Image? {
        didSet {
            // If the image is not exactly our expected edge-to-edge size, assume the learner has placed an image of their own.
            if let liveView = LiveViewController.current {
                if let bgImage = backgroundImage {
                    blockLightSensorImage = true
                    
                    let image = Image(imageLiteralResourceName: bgImage.path)
                    
                    if image.uiImage.size.width >= TextureType.backgroundMaxSize.width && image.uiImage.size.height >= TextureType.backgroundMaxSize.height {
                        backgroundNode.backgroundImage = nil
                        
                        liveView.backgroundImage = image.uiImage
                    }
                    else {
                        // Learner image
                        backgroundNode.backgroundImage = bgImage
                        
                        liveView.backgroundImage = nil
                    }
                }
                else {
                    // Background image cleared
                    backgroundNode.backgroundImage = nil
                    
                    liveView.backgroundImage = nil
                }
            }
        }
    }
    
    public var lightSensorImage: UIImage? {
        // Interface orientation was deprecated in 8.0 but it's the only way to properly orient the image. Wrapping the entire didSet in an availability macro quiets the warning.
        @available(iOS, deprecated: 8.0)
        didSet {
            if let liveView = LiveViewController.current, !blockLightSensorImage {
                if var lsImage = lightSensorImage {
                    let vcOrientation = liveView.interfaceOrientation
                    
                    if vcOrientation != .landscapeRight, let cgImage = lsImage.cgImage {
                        var orientation = UIImage.Orientation.up
                        
                        // rotate image if necessary
                        if vcOrientation == .portrait {
                            orientation = .left
                        } else if vcOrientation == .landscapeLeft {
                            orientation = .down
                        } else if vcOrientation == .portraitUpsideDown {
                            orientation = .right
                        }
                        
                        lsImage = UIImage(cgImage: cgImage, scale: 1.0, orientation: orientation)
                    }
                    
                    liveView.backgroundImage = lsImage
                    liveView.backgroundImageView.contentMode = .scaleAspectFit
                } else {
                    // Background image cleared
                    liveView.backgroundImage = nil
                }
            }
        }
    }
        
    public let skView = SKView(frame: .zero)
    
    public override init() {
        super.init()
        
        size = sceneSize
        
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        // The SKView hosting this scene is always sized appropriately so fit/fill really doesn’t matter here.
        scaleMode = .aspectFit
        isUserInteractionEnabled = true
        backgroundColor = UIColor.clear
        updateState(forExecutionMode: PlaygroundPage.current.executionMode)
        NotificationCenter.default.addObserver(forName: Notification.Name(rawValue:"PlaygroundPageExecutionModeDidChange"), object: nil, queue: OperationQueue.main) { (notification) in
            self.executionMode = PlaygroundPage.current.executionMode
        }
        
        SceneProxy.registerToRecieveDecodedMessage(as: self)
        AccessibilityProxy.registerToRecieveDecodedMessage(as: self)
        AudioProxy.registerToRecieveDecodedMessage(as: self)
        
        // If user code and live view are running in the same process, then the connection is already established.
        if Message.isLiveViewOnly {
            connectedToUserProcess = true
        }
        
        skView.allowsTransparency = true
        skView.presentScene(self)
    }
    
    public override init(size: CGSize) {
        super.init(size: size)
        commonInit()
    }

    private func configureLoadscreenNode() {
        let name = "loadscreen\(arc4random_uniform(8) + 1)"
        if let img = UIImage(named: name) {
            loadscreenNode.texture = SKTexture(image: img)
            loadscreenNode.size = loadscreenNode.texture!.size()
            loadscreenNode.position = self.center
        }
    }
    
    public override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        if !addedToView {
            physicsWorld.contactDelegate = self
            physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
            
            configureLoadscreenNode()
            
            AudioSession.current.delegate = self
            AudioSession.current.configureEnvironment()
            
            addChild(backgroundNode)
            addChild(loadscreenNode)
            addChild(containerNode)
            containerNode.name = "container"
            backgroundNode.name = "background"
            
            addedToView = true
        }
    }
    
    public override func didChangeSize(_ oldSize: CGSize) {
        backgroundNode.position = center
        containerNode.position = center
    }
    
    public func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node, let nodeB = contact.bodyB.node else { return }
        guard let idA = nodeA.name, let idB = nodeB.name else { return }
        
        guard let liveGraphicA = graphicsInfo[idA] else { return }
        guard let liveGraphicB = graphicsInfo[idB] else { return }
        
        nc.post(name: LiveViewScene.collisionOccurred, object: self, userInfo: [LiveViewScene.firstGraphicKey: liveGraphicA,
                                                                                LiveViewScene.secondGraphicKey: liveGraphicB])
        
        let sortedGraphics = [liveGraphicA, liveGraphicB].sorted()
        
        let collidedSpriteA = Sprite(liveViewGraphic: sortedGraphics[0])
        let collidedSpriteB = Sprite(liveViewGraphic: sortedGraphics[1])
        var isOverLapping: Bool = false
        
        if let pos = contact.bodyB.node?.position, let overlap = contact.bodyA.node?.contains(pos), overlap {
            isOverLapping = true
        }
        
        
        
        var normalizedDirection: CGVector = CGVector()
        if liveGraphicA.name == sortedGraphics[0].name {
            normalizedDirection = contact.contactNormal
        } else {
            normalizedDirection = CGVector(dx: -contact.contactNormal.dx, dy: -contact.contactNormal.dy)
        }

        handleCollision(spriteA: collidedSpriteA, spriteB: collidedSpriteB, angle: normalizedDirection, force: Double(contact.collisionImpulse), isOverlapping: isOverLapping)
    }

    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard shouldHandleTouches else { return }
        
        // reenable direct interaction
        if accessibilityAllowsDirectInteraction, let firstTouch = touches.first, firstTouch.tapCount == 2 {
            accessibilityAllowsDirectInteraction = false
            
            return
        }
        
        AssessmentUserCodeProxy().trigger(trigger: .start(context: .tool))
        
        let skTouchPosition = touches[touches.startIndex].location(in: containerNode)
        // Get all visible nodes at the touch position.
        let intersectingNodes = containerNode.nodes(at: skTouchPosition)
        // Search visible nodes for the topmost graphic that allows touch interaction.
        for node in intersectingNodes {
            if let id = node.name, let liveGraphic = graphicsInfo[id], liveGraphic.allowsTouchInteraction {
                capturedGraphic = liveGraphic.graphic
                break
            }
        }
        
        let doubleTouch = touches.first?.tapCount == 2
        
        handleTouch(at: skTouchPosition, firstTouch: true, doubleTouch: doubleTouch)
    }

    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard shouldHandleTouches else { return }

        let skTouchPosition = touches[touches.startIndex].location(in: containerNode)
        handleTouch(at: skTouchPosition)
    }

    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard shouldHandleTouches else { return }
        
        commonTouchEndingCleanup()
        
        let skTouchPosition = touches[touches.startIndex].location(in: containerNode)
        handleTouch(at: skTouchPosition, lastTouch: true)
    }

    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard shouldHandleTouches else { return }
        commonTouchEndingCleanup()
        
        let skTouchPosition = touches[touches.startIndex].location(in: containerNode)
        handleTouch(at: skTouchPosition, lastTouch: true)
    }

    func commonTouchEndingCleanup() {
        capturedGraphic = nil
        AssessmentUserCodeProxy().trigger(trigger: .stop)
        AssessmentUserCodeProxy().trigger(trigger: .evaluate)
    }
    
    func handleTouch(at: CGPoint, firstTouch: Bool = false, ignoreNode: Bool = false, doubleTouch: Bool = false, lastTouch: Bool = false) {
        var touch = Touch(position: Point(at), previousPlaceDistance: 0, firstTouch: firstTouch, touchedGraphic: nil, capturedGraphicID: capturedGraphic?.id ?? "")
        
        touch.lastTouch = lastTouch
        
        if !ignoreNode {
            var node: SKNode?
            // Get all visible nodes at the touch position.
            let hitNodes = containerNode.nodes(at: at)
            // Search visible nodes for the topmost graphic that allows touch interaction.
            for hitNode in hitNodes {
                if let id = hitNode.name, let graphic = graphicsInfo[id], graphic.allowsTouchInteraction {
                    node = graphic.backingNode
                    break
                }
            }
            
            if let node = node, node.name != containerNode.name,
                node.name != backgroundNode.name,
                let id = node.name,
                let liveGraphic = graphicsInfo[id] {
                
                if node is SKTileMapNode {
                    // Touched a tile map node directly.
                    touch.touchedGraphic = liveGraphic.graphic
                    
                } else {
                    if let nodeName = node.name, node.childNode(withName: nodeName) is SKTileMapNode {
                        // Touched a node that contains a tile map node, but outside the tile map node itself.
                        // This can occur when the tile map node is rotated within the backing node.
                        // => Ignore touch.
                    } else {
                        // Touched a node.
                        touch.touchedGraphic = liveGraphic.graphic
                    }
                }
            }
        }
        
        touch.doubleTouch = doubleTouch
        touch.lastTouchInGraphic = lastTouch
        touch.firstTouchInGraphic = firstTouch
        
        if !firstTouch, let lastSentTouch = lastSentTouch, lastSentTouch.touchedGraphic != touch.touchedGraphic {
            var bonusTouch = Touch(position: lastSentTouch.position, previousPlaceDistance: 0, firstTouch: false, touchedGraphic: lastSentTouch.touchedGraphic, capturedGraphicID: lastSentTouch.capturedGraphicID)
            
            bonusTouch.lastTouchInGraphic = true
            
            SceneUserCodeProxy().sceneTouchEvent(touch: bonusTouch)
        }
        
        if let touchedGraphic = touch.touchedGraphic, let lastSentTouch = lastSentTouch, let lastTouchedGraphic = lastSentTouch.touchedGraphic {
            touch.firstTouchInGraphic = touch.firstTouchInGraphic || (touchedGraphic.id != lastTouchedGraphic.id)
        }
        
        SceneUserCodeProxy().sceneTouchEvent(touch: touch)
        lastSentTouch = touch
    }
    
    func handleCollision(spriteA: Sprite, spriteB: Sprite, angle: CGVector, force: Double, isOverlapping: Bool) {
        let collision = Collision(spriteA: spriteA, spriteB: spriteB, angle: Vector(angle), force: force, isOverlapping: isOverlapping)
        
        SceneUserCodeProxy().sceneCollisionEvent(collision: collision)
    }
    
    private func disableGraphics() {
        for graphic in graphicsInfo.values.filter({ $0.disablesOnDisconnect }) {
            graphic.setDisabledAppearance(true)
        }
    }
    
    internal func setupPositionTimer() {
        if self.graphicsPositionUpdateTimer == nil {
            self.graphicsPositionUpdateTimer = Timer.scheduledTimer(withTimeInterval:1.0/20.0, repeats: true, block: { (t : Timer) in
                var positions = [String:CGPoint]()
                var velocities = [String:CGVector]()
                var rotationalVelocities = [String:CGFloat]()
                var sizes = [String:CGSize]()
                
                for id in self.graphicsInfo.keys {
                    if let graphic = self.graphicsInfo[id] {
                        let backingNode = graphic.backingNode
                        
                        if let physicsBody = backingNode.physicsBody {
                            if physicsBody.isDynamic {
                                positions[id] = backingNode.position
                                velocities[id] = physicsBody.velocity
                                rotationalVelocities[id] = physicsBody.angularVelocity
                            }
                        }
                        
                        sizes[id] = backingNode.size
                    }
                }
                
                if positions.count > 0 || sizes.count > 0 {
                    SceneUserCodeProxy().updateGraphicAttributes(positions: positions, velocities: velocities, rotationalVelocities: rotationalVelocities, sizes: sizes)
                }
            })
        }
    }
    


    func addSceneObservers() {
        enterBackgroundObserver = nc.addObserver(forName: .NSExtensionHostDidEnterBackground, object: nil, queue: .main) { _ in
            self.graphicsPositionUpdateTimer?.invalidate()
            self.graphicsPositionUpdateTimer = nil
        }
        
        
        willEnterForegroundObserver = nc.addObserver(forName: .NSExtensionHostWillEnterForeground, object: nil, queue: .main) { _ in
            self.setupPositionTimer()
        }
    }
    
    func removeSceneObservers() {
        if let observer = self.enterBackgroundObserver {
            self.nc.removeObserver(observer)
        }
        
        if let observer = self.willEnterForegroundObserver {
            self.nc.removeObserver(observer)
        }
    }
    
    private func createInstrument(_ kind: Instrument.Kind) -> Instrument {
        let instrument = Instrument(kind: kind)
        instrument.connect(instrumentsEngine)
        instrument.defaultVelocity = 64
        return instrument
    }
    
    public func setLightSensorImage(image: UIImage?) {
        DispatchQueue.main.async {
            self.lightSensorImage = image
        }
    }
    
    // MARK: Accessibility
        
    private var accessibilityAllowsDirectInteraction: Bool = false {
        didSet {
            let note : String
            
            if accessibilityAllowsDirectInteraction {
                note = NSLocalizedString("Direct interaction enabled", tableName: "SPCScene", comment: "AX description when direct interaction is enabled")
            }
            else {
                note = NSLocalizedString("Direct interaction disabled", tableName: "SPCScene", comment: "AX description when direct interaction is disabled")
            }
            
            UIAccessibility.post(notification: .layoutChanged, argument: note)
        }
    }
    
    public override var isAccessibilityElement: Bool {
        set { }
        get {
            return accessibilityAllowsDirectInteraction
        }
    }
    
    public override var accessibilityLabel: String? {
        set { }
        get {
            let label : String
            
            if accessibilityAllowsDirectInteraction {
                label = NSLocalizedString("Scene, direct interaction enabled", tableName: "SPCScene", comment: "AX description describing the scene itself when direct interaction is enabled")
            }
            else {
                label = NSLocalizedString("Scene, direct interaction disabled", tableName: "SPCScene", comment: "AX description describing the scene itself when direct interaction is disabled")
            }
            
            return label
        }
    }
    
    public override var accessibilityTraits: UIAccessibilityTraits {
        set { }
        get {
            if accessibilityAllowsDirectInteraction {
                return .allowsDirectInteraction
            }
            
            return .none
        }
    }
    
    private func findGraphics() -> [(String, LiveViewGraphic)] {
        // Sort the graphics vertically.
        let orderedGraphicsInfo = graphicsInfo.tupleContents.sorted { lhs, rhs in
            return lhs.1.position.y > rhs.1.position.y
        }
        
        return orderedGraphicsInfo.filter { element in
            let graphic = element.1
            guard graphic.backingNode.parent == containerNode else { return false }
            return true
        }
    }
    
    public override var accessibilityElements: [Any]? {
        set { /* Should not need to set */ }
        get {
            guard !accessibilityAllowsDirectInteraction else { return nil }
            
            // VO will ask for accessible elements pretty frequently. We should only update our list of items when the number of graphics we’re tracking changes.
            guard axElements.isEmpty else { return axElements }
            
            // Add accessibility elements
            var sceneLabel = NSLocalizedString("Scene, ", tableName: "SPCScene", comment: "AX label")
            if let backgroundImage = backgroundImage {
                sceneLabel += String(format: NSLocalizedString("background image: %@, ", tableName: "SPCScene", comment: "AX label: background image description."), backgroundImage.description)
            }
            
            // Describe the color even if there is an image (it’s possible the image does not cover the entire scene).
            if let backgroundColor = backgroundNode.backgroundColor {
                sceneLabel += String(format: NSLocalizedString("background color: %@.", tableName: "SPCScene", comment: "AX label: scene background color description."), backgroundColor.accessibleDescription)
            }
            
            _addBGElement(frame: view!.bounds, label: sceneLabel, elementCount: findGraphics().count)
            
            let graphics = findGraphics()
            
            graphicAccessibilityElementGroupsByID.removeAll()
            
            // Add the individual graphics in order based on the quadrant.
            for (id, graphic) in graphics {
                if let hints = graphic.accessibilityHints {
                    if hints.makeAccessibilityElement {
                        if let groupID = hints.groupID {
                            var element: GraphicAccessibilityElement? = graphicAccessibilityElementGroupsByID[groupID]
                            
                            if element == nil {
                                element = GraphicAccessibilityElement(delegate: self, identifier: groupID, accessibilityHints: hints)
                                
                                axElements.append(element!)
                                
                                graphicAccessibilityElementGroupsByID[groupID] = element
                            }
                            
                            if let element = element {
                                element.graphics.append(graphic.graphic)
                            }
                        } else {
                            let element = GraphicAccessibilityElement(delegate: self, identifier: id, accessibilityHints: hints)
                            
                            element.graphics = [graphic.graphic]
                            
                            axElements.append(element)
                        }
                    }
                }
            }
            
            return axElements
        }
    }
    
    private func _addBGElement(frame: CGRect, label: String, elementCount: Int) {
        let element = BackgroundAccessibilityElement(delegate: self)
        
        var axFrame = UIAccessibility.convertToScreenCoordinates(frame, in: view!)
        if let window = view!.window {
            // Constrain AX frame to visible part of the view (as determined by its window).
            let windowAXFrame = UIAccessibility.convertToScreenCoordinates(window.bounds, in: window)
            axFrame = axFrame.intersection(windowAXFrame)
        }
        element.accessibilityFrame = axFrame
        
        var label = label
        if elementCount > 0 {
            if (elementCount == 1) {
                label = String(format: NSLocalizedString("%@, %d graphic found.", tableName: "SPCScene", comment: "AX label: count of graphics (singular)."), label, elementCount)
            }
            else {
                label = String(format: NSLocalizedString("%@, %d graphics found.", tableName: "SPCScene", comment: "AX label: count of graphics (plural)."), label, elementCount)
            }
        }
        
        element.accessibilityLabel = label
        if connectedToUserProcess {
            element.accessibilityHint = NSLocalizedString("Double-press to toggle direct interaction", tableName: "SPCScene", comment: "AX label")
        }
        element.accessibilityIdentifier = "LiveViewScene.main"
        axElements.append(element)
    }
    
    // MARK: GraphicAccessibilityElementDelegate
    
    private func graphicDescription(for graphic: LiveViewGraphic) -> String {
        let label: String
        let imageDescription: String
        let graphicRole: String
        var updatedValueDescription: String? = nil

        if let accLabel = graphic.accessibilityHints?.accessibilityLabel {
            imageDescription = accLabel
        } else if let text = graphic.text {
            imageDescription = text
        } else if !graphic.name.isEmpty {
            imageDescription = graphic.name
        } else if let image = graphic.image {
            imageDescription = image.description
        } else {
            imageDescription = ""
        }
        
        if graphic.accessibilityHints?.needsUpdatedValue == true {
            switch graphic.graphicType {
            case .label:
                updatedValueDescription = graphic.text
            default:
                break
            }
        }
        
        switch graphic.graphicType {
        case .button:
            graphicRole = NSLocalizedString("button", tableName: "SPCScene", comment: "graphic type")
        case .character:
            graphicRole = NSLocalizedString("character", tableName: "SPCScene", comment: "graphic type")
        case .graphic:
            graphicRole = NSLocalizedString("graphic", tableName: "SPCScene", comment: "graphic type")
        case .label:
            graphicRole = NSLocalizedString("label", tableName: "SPCScene", comment: "graphic type")
        case .sprite:
            graphicRole = NSLocalizedString("sprite", tableName: "SPCScene", comment: "graphic type")
        }
        
        if let updatedValueDescription = updatedValueDescription {
            label = String(format: NSLocalizedString("%@, %@, %@, at x %d, y %d", tableName: "SPCScene", comment: "AX label: description of an image, its value, and its position in the scene."), imageDescription, updatedValueDescription, graphicRole, Int(graphic.position.x), Int(graphic.position.y))
        } else {
            label = String(format: NSLocalizedString("%@, %@, at x %d, y %d", tableName: "SPCScene", comment: "AX label: description of an image and its position in the scene."), imageDescription, graphicRole, Int(graphic.position.x), Int(graphic.position.y))
        }
        
        
        return label
    }
    
    fileprivate func accessibilityLabel(element: GraphicAccessibilityElement) -> String {
        var label = ""
        if let liveViewGraphic = graphicsInfo[element.identifier] {
            label = graphicDescription(for: liveViewGraphic)
        }
        return label
    }
    
    fileprivate func accessibilityFrame(element: GraphicAccessibilityElement) -> CGRect {
        var frame = CGRect.zero
        
        if let liveViewGraphic = graphicsInfo[element.identifier], let hints = liveViewGraphic.accessibilityHints {
            if let groupID = hints.groupID, let element = graphicAccessibilityElementGroupsByID[groupID] {
                for graphic in element.graphics {
                    if let graphic = graphicsInfo[graphic.id] {
                        if frame == CGRect.zero {
                            frame = graphic.backingNode.accessibilityFrame
                        } else {
                            frame = frame.union(graphic.backingNode.accessibilityFrame)
                        }
                    }
                }
            } else {
                frame = liveViewGraphic.backingNode.accessibilityFrame
            }
            
            frame = frame.insetBy(dx: -10, dy: -10)
        }
            
        return frame
    }
    
    fileprivate func accessibilityTraits(element: GraphicAccessibilityElement) -> UIAccessibilityTraits {
        if let liveViewGraphic = graphicsInfo[element.identifier] {
            switch liveViewGraphic.graphicType {
            case .sprite:
                return .image
            case .button:
                return .button
            case .label:
                return .staticText
            default:
                return .none
            }
        }
        
        return .none
    }
    
    fileprivate func accessibilitySimulateTouch(at point: CGPoint, firstTouch: Bool = false, lastTouch: Bool = false) {
        let viewTouchPosition = UIScreen.main.coordinateSpace.convert(point, to: view!)
        var skTouchPosition = convertPoint(fromView: viewTouchPosition)
        
        skTouchPosition.x += 500.0
        skTouchPosition.y -= 500.0
        
        handleTouch(at: skTouchPosition, firstTouch: firstTouch, lastTouch: lastTouch)
    }
    
    fileprivate func accessibilityActivate(element: BackgroundAccessibilityElement) -> Bool {
        if (connectedToUserProcess) {
            accessibilityAllowsDirectInteraction = !accessibilityAllowsDirectInteraction
        }
        return true
    }
    
    public override var accessibilityCustomActions : [UIAccessibilityCustomAction]? {
        set { }
        get {
            let summary = UIAccessibilityCustomAction(name: NSLocalizedString("Scene summary.", tableName: "SPCScene", comment: "AX action name"), target: self, selector: #selector(sceneSummaryAXAction))
            let sceneDetails = UIAccessibilityCustomAction(name: NSLocalizedString("Image details for scene.", tableName: "SPCScene", comment: "AX action name"), target: self, selector: #selector(imageDetailsForScene))

            
            return [summary, sceneDetails]
        }
    }
    
    @objc func sceneSummaryAXAction() {
        var imageListDescription = ""
        
        let count = findGraphics().count
        if count > 0 {
            if (count == 1) {
                imageListDescription += String(format: NSLocalizedString("%d graphic found.", tableName: "SPCScene", comment: "AX label: count of graphics (singular)."), count)
            }
            else {
                imageListDescription += String(format: NSLocalizedString("%d graphics found.", tableName: "SPCScene", comment: "AX label: count of graphics (plural)."), count)
            }
        }
        
        UIAccessibility.post(notification: .announcement, argument: imageListDescription)
    }
    
    @objc func imageDetailsForScene() {
        let graphics = findGraphics()
        var imageListDescription = ""
        switch graphics.count {
        case 0:
            imageListDescription += NSLocalizedString("Zero graphics found in scene.", tableName: "SPCScene", comment: "AX label, count of graphics (none found)")
        case 1:
            imageListDescription += String(format: NSLocalizedString("%d graphic found.", tableName: "SPCScene", comment: "AX label: count of graphics (singular)."), graphics.count)
        default:
            imageListDescription += String(format: NSLocalizedString("%d graphics found.", tableName: "SPCScene", comment: "AX label: count of graphics (plural)."), graphics.count)
        }
        
        for (_, liveViewGraphic) in graphics {
            imageListDescription += graphicDescription(for: liveViewGraphic)
            imageListDescription += ", "
        }
        
        UIAccessibility.post(notification: .announcement, argument: imageListDescription)
    }
    
    func addAccessibleGraphic(_ graphic: LiveViewGraphic) {
        if UIAccessibility.isVoiceOverRunning {
            self.graphicPlacedAudioPlayer?.play()
        }
    }
    
    func setNeedsUpdateAccessibility(notify: Bool) {
        self.axElements.removeAll(keepingCapacity: true)
        
        if notify {
            UIAccessibility.post(notification: .screenChanged, argument: self.accessibilityElements?.first)
        }
    }
    
    private lazy var graphicPlacedAudioPlayer: AVAudioPlayer? = {
        guard let url = Bundle(for: LiveViewScene.self).url(forResource: "GraphicPlaced", withExtension: "aifc") else { return nil }
        var audioPlayer: AVAudioPlayer?
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.volume = 0.5
        } catch {}
        return audioPlayer
    }()
}

private protocol GraphicAccessibilityElementDelegate {
    func accessibilityLabel(element: GraphicAccessibilityElement) -> String
    func accessibilityFrame(element: GraphicAccessibilityElement) -> CGRect
    func accessibilityTraits(element: GraphicAccessibilityElement) -> UIAccessibilityTraits
    
    func accessibilitySimulateTouch(at point: CGPoint, firstTouch: Bool, lastTouch: Bool)
}

private class GraphicAccessibilityElement : UIAccessibilityElement {
    let identifier: String
    let delegate: GraphicAccessibilityElementDelegate
    let accessibilityHints: AccessibilityHints
    
    var graphics = [Graphic]()
    
    init(delegate: GraphicAccessibilityElementDelegate, identifier: String, accessibilityHints: AccessibilityHints) {
        self.identifier = identifier
        self.delegate = delegate
        self.accessibilityHints = accessibilityHints
        
        super.init(accessibilityContainer: delegate)
        
        accessibilityIdentifier = identifier
    }
    
    public override var accessibilityLabel: String? {
        set {
            // no-op
        }
        get {
            return delegate.accessibilityLabel(element: self)
        }
    }
    
    public override var accessibilityFrame: CGRect {
        set {
            // no-op
        }
        get {
            return delegate.accessibilityFrame(element: self)
        }
    }
    
    public override var accessibilityTraits: UIAccessibilityTraits {
        set { }
        get {
            return delegate.accessibilityTraits(element: self)
        }
    }
    
    public override var accessibilityCustomActions : [UIAccessibilityCustomAction]? {
        set { }
        get {
            var actions: [UIAccessibilityCustomAction]? = nil
            
            if accessibilityHints.actions.contains(.drag) {
                actions = [UIAccessibilityCustomAction(name: NSLocalizedString("Graphic drag.", tableName: "SPCScene", comment: "AX action name"), target: self, selector: #selector(graphicDragAXAction))]
            }
            
            return actions
        }
    }
    
    @objc func graphicDragAXAction() {
        if graphics.count > 0 {
            let total = 50
            var count = 0
            let frame = accessibilityFrame
            
            _ = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
                if count == total {
                    timer.invalidate()
                }
                
                
                let x = Double(frame.origin.x) + Double(frame.size.width) * (Double(count) / Double(total))
                let y = Double(frame.origin.y + frame.size.height) - Double(frame.size.height) * (Double(count) / Double(total))
                
                self.delegate.accessibilitySimulateTouch(at: CGPoint(x: x, y: y), firstTouch: count == 0, lastTouch: count == total)
                
                count += 1
            }
        }
    }
}

private protocol BackgroundAccessibilityElementDelegate {
    func accessibilityActivate(element: BackgroundAccessibilityElement) -> Bool
}

private class BackgroundAccessibilityElement : UIAccessibilityElement {
    let delegate: BackgroundAccessibilityElementDelegate
    init(delegate: BackgroundAccessibilityElementDelegate) {
        self.delegate = delegate
        super.init(accessibilityContainer: delegate)
    }
    public override func accessibilityActivate() -> Bool {
        return delegate.accessibilityActivate(element: self)
    }
}

extension Dictionary {
    fileprivate var tupleContents: [(Key, Value)] {
        return self.map { ($0.key, $0.value) }
    }
}

extension LiveViewScene: LiveViewLifeCycleProtocol {
    public func liveViewMessageConnectionOpened() {
        DispatchQueue.main.async {
            self.connectedToUserProcess = true
            self.loadscreenNode.removeFromParent()
            self.backgroundNode.backgroundColor = nil
            
            self.skView.preferredFramesPerSecond = 60
            
            self.addSceneObservers()
        }
    }
    
    public func liveViewMessageConnectionClosed() {
        DispatchQueue.main.async {
            self.connectedToUserProcess = false
            
            self.removeSceneObservers()
            
            self.graphicsPositionUpdateTimer?.invalidate()
            self.graphicsPositionUpdateTimer = nil
            
            self.skView.preferredFramesPerSecond = 0
            
            self.disableGraphics()
        }
    }
    
    public func liveViewDidUpdateLayout() {
        setNeedsUpdateAccessibility(notify: false)
    }
}

extension LiveViewScene: AudioPlaybackDelegate {
    // MARK: AudioPlaybackDelegate
    public func audioSession(_ session: AudioSession, isPlaybackBlocked: Bool) {
        
        if isPlaybackBlocked {
            // Pause background audio if the audio session is blocked, for example, by the app going into the background.
            audioController.pauseBackgroundAudioLoop()
            audioController.stopAllPlayersExceptBackgroundAudio()
        } else {
            // Resume if audio session is unblocked, assuming audio is enabled.
            if audioController.isBackgroundAudioEnabled {
                audioController.resumeBackgroundAudioLoop()
            }
        }
    }
}

extension LiveViewScene: SceneProxyProtocol {
    
    // MARK: SceneProxyProtocol
    public func setBorderPhysics(hasCollisionBorder: Bool) {
        DispatchQueue.main.async {
            if hasCollisionBorder {
                let borderBody = SKPhysicsBody(edgeLoopFrom: self.frame)
                self.physicsBody = borderBody
                
            } else {
                self.physicsBody = nil
            }
        }
    }
    
    public func setSceneBackgroundColor(color: Color) {
        DispatchQueue.main.async { [unowned self] in
            self.backgroundNode.backgroundColor = color
            
            self.blockLightSensorImage = true
            
            if let liveView = LiveViewController.current {
                liveView.backgroundImage = nil
            }
            
            self.setNeedsUpdateAccessibility(notify: true)
        }
    }
    
    public func setSceneBackgroundImage(image: Image?) {
        DispatchQueue.main.async {
            self.backgroundImage = image
            
            self.setNeedsUpdateAccessibility(notify: true)
        }
    }
    
    public func setSceneGridVisible(isVisible: Bool) {
        DispatchQueue.main.async {
            self.backgroundNode.isGridOverlayVisible = isVisible
        }
    }
    
    public func clearScene() {
        DispatchQueue.main.async {
            self.graphicsPositionUpdateTimer?.invalidate()
            self.graphicsPositionUpdateTimer = nil
            self.containerNode.removeAllChildren()
            self.graphicsInfo.removeAll()
            type(of: self).printPosition = type(of:self).initialPrintPosition
            
            self.setNeedsUpdateAccessibility(notify: false)
            
            self.blockLightSensorImage = false
        }
    }
    
    public func placeGraphic(id: String, position: CGPoint, isPrintable: Bool, anchorPoint: AnchorPoint) {
        DispatchQueue.main.async {
            if let graphic = self.graphicsInfo[id] {
                if graphic.backingNode.parent == nil {
                    self.containerNode.addChild(graphic.backingNode)
                }
                
                // Compute center position from anchor point and size.
                // NOTE: anchor point is ignored after initial placement.
                var centerPosition = CGPoint.zero
                switch anchorPoint {
                case .center:
                    centerPosition = position
                case .left:
                    centerPosition = CGPoint(x: position.x + (graphic.backingNode.size.width / 2), y: position.y)
                case .top:
                    centerPosition = CGPoint(x: position.x, y: position.y - (graphic.backingNode.size.height / 2))
                case .right:
                    centerPosition = CGPoint(x: position.x - (graphic.backingNode.size.width / 2), y: position.y)
                case .bottom:
                    centerPosition = CGPoint(x: position.x, y: position.y + (graphic.backingNode.size.height / 2))
                }
                
                graphic.backingNode.position = isPrintable ? LiveViewScene.printPosition : centerPosition
                
                if isPrintable {
                    LiveViewScene.printPosition.y -= graphic.backingNode.size.height
                }
                
                self.setupPositionTimer()
                
                self.addAccessibleGraphic(graphic)
            }
        }
    }
    
    public func placeRelativeGraphic(graphic: String, relativeTo: String, xOffset: Double, yOffset: Double) {
        DispatchQueue.main.async {
            if let placed = self.graphicsInfo[graphic] {
                if placed.backingNode.parent == nil {
                    self.containerNode.addChild(placed.backingNode)
                }
                
                if let relative = self.graphicsInfo[relativeTo] {
                    placed.position.x = relative.position.x + CGFloat(xOffset)
                    placed.position.y = relative.position.y + CGFloat(yOffset)
                }
                
                self.setupPositionTimer()
                
                self.addAccessibleGraphic(placed)
            }
        }
    }
    
    public func removeGraphic(id: String) {
        DispatchQueue.main.async {
            if let spriteNode = self.containerNode.childNode(withName: id) as? SKSpriteNode {
                spriteNode.removeFromParent()
                if self.graphicsInfo[id] != nil {
                    self.graphicsInfo.removeValue(forKey: id)
                    SceneUserCodeProxy().removedGraphic(id: id)
                }
                
                self.setNeedsUpdateAccessibility(notify: false)
                
                if self.graphicsInfo.count == 0 {
                    self.graphicsPositionUpdateTimer?.invalidate()
                    self.graphicsPositionUpdateTimer = nil
                }
            }
        }
    }
    
    public func setSceneGravity(vector: CGVector) {
        DispatchQueue.main.async {
            self.physicsWorld.gravity = vector
        }
    }
    
    public func setScenePositionalAudioListener(id: String) {
        DispatchQueue.main.async {
            guard let graphic = self.graphicsInfo[id] else { return }
            self.listener = graphic.backingNode
        }
    }
    
    public func createNode(id: String, graphicName: String, graphicType: GraphicType) {
        DispatchQueue.main.async {
            let graphic = LiveViewGraphic(id: id, name: graphicName, graphicType: graphicType)
            self.graphicsInfo[id] = graphic
            graphic.backingNode.name = id
            self.nc.post(name: LiveViewScene.didCreateGraphic, object: self)
        }
    }
        
    public func getGraphics() {
        var returnGraphics = [Graphic]()
        
        for liveViewGraphic in graphicsInfo.values {
            returnGraphics.append(liveViewGraphic.graphic)
        }
        
        SceneUserCodeProxy().getGraphicsReply(graphics: returnGraphics)
    }
    
    public func setImage(id: String, image: Image?) {
        DispatchQueue.main.async { [unowned self] in
            guard let graphic = self.graphicsInfo[id] else { return }
            graphic.columns = 1
            graphic.rows = 1
            graphic.image = image
        }
    }
    
    public func setTiledImage(id: String, image: Image?, columns: Int?, rows: Int?, isDynamic: Bool?) {
        DispatchQueue.main.async { [unowned self] in
            guard let graphic = self.graphicsInfo[id] else { return }
            graphic.columns = columns ?? 1
            graphic.rows = rows ?? 1
            graphic.image = image
            if let isDynamic = isDynamic {
                graphic.isDynamic = isDynamic
            }
        }
    }
    
    public func setShape(id: String, shape: BasicShape?) {
        DispatchQueue.main.async { [unowned self] in
            guard let graphic = self.graphicsInfo[id] else { return }
            graphic.shape = shape
        }
    }
    
    public func setText(id: String, text: String?) {
        DispatchQueue.main.async {
            guard let graphic = self.graphicsInfo[id] else { return }
            graphic.text = text
        }
    }
    
    public func setTextColor(id: String, color: Color) {
        DispatchQueue.main.async {
            guard let graphic = self.graphicsInfo[id] else { return }
            graphic.textColor = color
        }
    }
    
    public func setFontName(id: String, name: String) {
        DispatchQueue.main.async {
            guard let graphic = self.graphicsInfo[id] else { return }
            graphic.fontName = name
        }
    }
    
    public func setFontSize(id: String, size: Int) {
        DispatchQueue.main.async {
            guard let graphic = self.graphicsInfo[id] else { return }
            graphic.fontSize = size
        }
    }
    
    public func setZPosition(id: String, position: Double) {
        DispatchQueue.main.async {
            guard let graphic = self.graphicsInfo[id] else { return }
            graphic.backingNode.zPosition = CGFloat(position)
        }
    }
    
    public func setAffectedByGravity(id: String, gravity: Bool) {
        DispatchQueue.main.async { [unowned self] in
            guard let graphic = self.graphicsInfo[id] else { return }
            graphic.isAffectedByGravity = gravity
        }
    }
    
    public func setIsDynamic(id: String, dynamic isDynamic: Bool) {
        DispatchQueue.main.async { [unowned self] in
            guard let graphic = self.graphicsInfo[id] else { return }
            graphic.isDynamic = isDynamic
        }
    }
    
    public func setAllowsRotation(id: String, rotation allowsRotation: Bool) {
        DispatchQueue.main.async { [unowned self] in
            guard let graphic = self.graphicsInfo[id] else { return }
            graphic.allowsRotation = allowsRotation
        }
    }
    
    public func setXScale(id: String, scale xScale: Double) {
        DispatchQueue.main.async { [unowned self] in
            guard let graphic = self.graphicsInfo[id] else { return }
            graphic.backingNode.xScale = CGFloat(xScale)
        }
    }
    
    public func setYScale(id: String, scale yScale: Double) {
        DispatchQueue.main.async { [unowned self] in
            guard let graphic = self.graphicsInfo[id] else { return }
            graphic.backingNode.yScale = CGFloat(yScale)
        }
    }
    
    public func setVelocity(id: String, velocity: CGVector) {
        DispatchQueue.main.async { [unowned self] in
            guard let graphic = self.graphicsInfo[id] else { return }
            guard let physicsBody = graphic.backingNode.physicsBody  else { return }
            physicsBody.velocity = velocity
        }
    }
    
    public func setRotationalVelocity(id: String, rotationalVelocity: Double) {
        DispatchQueue.main.async { [unowned self] in
            guard let graphic = self.graphicsInfo[id] else { return }
            guard let physicsBody = graphic.backingNode.physicsBody  else { return }
            physicsBody.angularVelocity = CGFloat(rotationalVelocity)
        }
    }
    
    public func setBounciness(id: String, bounciness: Double) {
        DispatchQueue.main.async { [unowned self] in
            guard let graphic = self.graphicsInfo[id] else { return }
            graphic.bounciness = CGFloat(bounciness)
        }
    }
    
    public func setFriction(id: String, friction: Double) {
        DispatchQueue.main.async { [unowned self] in
            guard let graphic = self.graphicsInfo[id] else { return }
            graphic.friction = CGFloat(friction)
        }
    }
    
    public func setDensity(id: String, density: Double) {
        DispatchQueue.main.async { [unowned self] in
            guard let graphic = self.graphicsInfo[id] else { return }
            graphic.density = CGFloat(density)
        }
    }
    
    public func setDrag(id: String, drag: Double) {
        DispatchQueue.main.async { [unowned self] in
            guard let graphic = self.graphicsInfo[id] else { return }
            graphic.drag = CGFloat(drag)
        }
    }
    
    public func setRotationalDrag(id: String, drag: Double) {
        DispatchQueue.main.async { [unowned self] in
            guard let graphic = self.graphicsInfo[id] else { return }
            graphic.rotationalDrag = CGFloat(drag)
        }
    }
    
    public func setInteractionCategory(id: String, interactionCategory: InteractionCategory) {
        DispatchQueue.main.async { [unowned self] in
            guard let graphic = self.graphicsInfo[id] else { return }
            graphic.interactionCategory = interactionCategory
        }
    }
    
    public func setCollisionCategories(id: String, collisionCategories: InteractionCategory) {
        DispatchQueue.main.async { [unowned self] in
            guard let graphic = self.graphicsInfo[id] else { return }
            graphic.collisionCategories = collisionCategories
        }
    }
    
    public func setContactCategories(id: String, contactCategories: InteractionCategory) {
        DispatchQueue.main.async { [unowned self] in
            guard let graphic = self.graphicsInfo[id] else { return }
            graphic.contactCategories = contactCategories
        }
    }
    
    // MARK: Joints
    
    public func createFixedJoint(jointID: String, from firstSpriteID: String, to secondSpriteID: String?, at anchor: Point) {
        DispatchQueue.main.async { [unowned self] in
            // Get the first physics body
            guard let physicsBodyA = (self.containerNode.childNode(withName: firstSpriteID) as? SKSpriteNode)?.physicsBody else {
                PBLog("No physics body found for spriteA.")
                return
            }
            
            // Get the second physics body. Use the scene’s edge loop if the second body is nil.
            let bodyB: SKPhysicsBody?
                        
            if let secondSpriteID = secondSpriteID {
                bodyB = (self.containerNode.childNode(withName: secondSpriteID) as? SKSpriteNode)?.physicsBody
            }
            else {
                assert(self.physicsBody != nil, "You must either provide a second sprite, or enable border physics.")
                bodyB = self.physicsBody
            }
            
            guard let physicsBodyB = bodyB else {
                PBLog("No physics body found for spriteB.")
                return
            }
            
            // Convert the anchor to the scene’s coordinate system.
            var position = anchor.cgPoint
            if let scene = self.scene {
                position = scene.convert(position, from: self.containerNode)
            }
            
            // Create the joint.
            let joint = SKPhysicsJointFixed.joint(withBodyA: physicsBodyA,
                                                  bodyB: physicsBodyB,
                                                  anchor: position)
            
            // Add to the joints dictionary.
            self.joints[jointID] = joint
        }
    }
    
    public func createLimitJoint(jointID: String, from firstSpriteID: String, at firstAnchor: Point, to secondSpriteID: String?, at secondAnchor: Point) {
        DispatchQueue.main.async { [unowned self] in
            // Get the first physics body
            guard let physicsBodyA = (self.containerNode.childNode(withName: firstSpriteID) as? SKSpriteNode)?.physicsBody else {
                PBLog("No physics body found for spriteA.")
                return
            }
            
            // Get the second physics body. Use the scene’s edge loop if the second body is nil.
            let bodyB: SKPhysicsBody?
            if let secondSpriteID = secondSpriteID {
                bodyB = (self.containerNode.childNode(withName: secondSpriteID) as? SKSpriteNode)?.physicsBody
            }
            else {
                assert(self.physicsBody != nil, "You must either provide a second sprite, or enable border physics.")
                bodyB = self.physicsBody
            }
            
            guard let physicsBodyB = bodyB else {
                PBLog("No physics body found for spriteB.")
                return
            }
            
            // Convert the anchors to the scene’s coordinate system.
            var positionA = firstAnchor.cgPoint
            var positionB = secondAnchor.cgPoint
            if let scene = self.scene {
                positionA = scene.convert(positionA, from: self.containerNode)
                positionB = scene.convert(positionB, from: self.containerNode)
            }
            
            // Create the joint.
            let joint = SKPhysicsJointLimit.joint(withBodyA: physicsBodyA,
                                                  bodyB: physicsBodyB,
                                                  anchorA: positionA,
                                                  anchorB: positionB)
            
            // Add to the joints dictionary.
            self.joints[jointID] = joint
        }
    }
    
    public func createPinJoint(jointID: String, from firstSpriteID: String, to secondSpriteID: String?, at anchor: Point) {
        DispatchQueue.main.async { [unowned self] in
            // Get the first physics body.
            guard let physicsBodyA = (self.containerNode.childNode(withName: firstSpriteID) as? SKSpriteNode)?.physicsBody else {
                PBLog("No physics body found for spriteA.")
                return
            }
            
            // Get the second physics body. Use the scene’s edge loop if the second body is nil.
            let bodyB: SKPhysicsBody?
            if let secondSpriteID = secondSpriteID {
                bodyB = (self.containerNode.childNode(withName: secondSpriteID) as? SKSpriteNode)?.physicsBody
            }
            else {
                assert(self.physicsBody != nil, "You must either provide a second sprite, or enable border physics.")
                bodyB = self.physicsBody
            }
            
            guard let physicsBodyB = bodyB else {
                PBLog("No physics body found for spriteB.")
                return
            }
            
            // Convert the anchor to the scene’s coordinate system.
            var position = anchor.cgPoint
            if let scene = self.scene {
                position = scene.convert(position, from: self.containerNode)
            }
            
            // Create the joint.
            let joint = SKPhysicsJointPin.joint(withBodyA: physicsBodyA,
                                                bodyB: physicsBodyB,
                                                anchor: position)
            
            // Add to the joints dictionary.
            self.joints[jointID] = joint
        }
    }
    
    public func createSlidingJoint(jointID: String, from firstSpriteID: String, to secondSpriteID: String?, at anchor: Point, axis: Vector) {
        DispatchQueue.main.async { [unowned self] in
            // Get the first physics body.
            guard let physicsBodyA = (self.containerNode.childNode(withName: firstSpriteID) as? SKSpriteNode)?.physicsBody else {
                PBLog("No physics body found for spriteA.")
                return
            }
            
            // Get the second physics body. Use the scene’s edge loop if the second body is nil.
            let bodyB: SKPhysicsBody?
            if let secondSpriteID = secondSpriteID {
                bodyB = (self.containerNode.childNode(withName: secondSpriteID) as? SKSpriteNode)?.physicsBody
            }
            else {
                assert(self.physicsBody != nil, "You must either provide a second sprite, or enable border physics.")
                bodyB = self.physicsBody
            }
            
            guard let physicsBodyB = bodyB else {
                PBLog("No physics body found for spriteB.")
                return
            }
            
            // Convert the anchor to the scene’s coordinate system.
            var position = anchor.cgPoint
            if let scene = self.scene {
                position = scene.convert(position, from: self.containerNode)
            }
            
            // Create the joint.
            let joint = SKPhysicsJointSliding.joint(withBodyA: physicsBodyA,
                                                    bodyB: physicsBodyB,
                                                    anchor: position,
                                                    axis: CGVector(dx: axis.dx, dy: axis.dy))
            
            // Add to the joints dictionary.
            self.joints[jointID] = joint
        }
    }
    
    public func createSpringJoint(jointID: String, from firstSpriteID: String, at firstAnchor: Point, to secondSpriteID: String?, at secondAnchor: Point) {
        DispatchQueue.main.async { [unowned self] in
            // Get the first physics body.
            guard let physicsBodyA = (self.containerNode.childNode(withName: firstSpriteID) as? SKSpriteNode)?.physicsBody else {
                PBLog("No physics body found for spriteA.")
                return
            }
            
            // Get the second physics body. Use the scene’s edge loop if the second body is nil.
            let bodyB: SKPhysicsBody?
            if let secondSpriteID = secondSpriteID {
                bodyB = (self.containerNode.childNode(withName: secondSpriteID) as? SKSpriteNode)?.physicsBody
            }
            else {
                assert(self.physicsBody != nil, "You must either provide a second sprite, or enable border physics.")
                bodyB = self.physicsBody
            }
            
            guard let physicsBodyB = bodyB else {
                PBLog("No physics body found for spriteB.")
                return
            }
            
            // Convert the anchors to the scene’s coordinate system.
            var positionA = firstAnchor.cgPoint
            var positionB = secondAnchor.cgPoint
            
            if let scene = self.scene {
                positionA = scene.convert(positionA, from: self.containerNode)
                positionB = scene.convert(positionB, from: self.containerNode)
            }
            
            // Create the joint.
            let joint = SKPhysicsJointSpring.joint(withBodyA: physicsBodyA,
                                                   bodyB: physicsBodyB,
                                                   anchorA: positionA,
                                                   anchorB: positionB)
            
            // Add to the joints dictionary.
            self.joints[jointID] = joint
        }
    }
    
    public func addJoint(jointID: String) {
        DispatchQueue.main.async { [unowned self] in
            guard let joint = self.joints[jointID] else {
                PBLog("No joint found.")
                return
            }
            self.physicsWorld.add(joint)
        }
    }
    
    public func addParticleEmitter(id: String, name: String, duration: Double, color: Color) {
        DispatchQueue.main.async {
            guard let emitter = SKEmitterNode(fileNamed: name) else { return }
                
            let emitterNode = SKNode()
            emitterNode.addChild(emitter)
                
            var addEmitter = SKAction()
            let wait = SKAction.wait(forDuration: TimeInterval(duration))
            let removeEmitter = SKAction.run { emitterNode.removeFromParent() }

            // Setting a particle emitter on a Graphic
            if let graphic = self.graphicsInfo[id] {
                
                emitter.particleZPosition = 4
                emitter.particleColorSequence = nil
                emitter.particleColor = color
                
                addEmitter = SKAction.run {
                    if name == "Explode" {
                        emitterNode.position = graphic.position
                        self.containerNode.addChild(emitterNode)
                    } else {
                        graphic.backingNode.addChild(emitterNode)
                        emitter.targetNode = self.containerNode
                    }
                }
                
                if name == "Explode" {
                    emitter.particlePositionRange = CGVector(dx: graphic.backingNode.size.width, dy: graphic.backingNode.size.height)
                    emitter.numParticlesToEmit = 200
                }
                
                if name == "Tracer" {
                    if let image = graphic.image, let uiImage = UIImage(named: image.path) {
                        emitter.particleTexture = SKTexture(image: uiImage)
                        emitter.particleScale = CGFloat(graphic.xScale)
                    }
                }
                
                if name == "Spark" {
                    emitter.particlePositionRange = CGVector(dx: graphic.backingNode.size.width / 4, dy: graphic.backingNode.size.height / 4)
                    emitter.particleBirthRate = ((graphic.backingNode.size.width + graphic.backingNode.size.height) / 2) * 25
                    emitter.particleZPosition = -1
                }
                
                if name == "Sparkles" {
                    emitter.particlePositionRange = CGVector(dx: graphic.backingNode.size.width * 1.0, dy: graphic.backingNode.size.height * 1.5)
                    let adjustedScale = ((graphic.backingNode.size.width + graphic.backingNode.size.height) / 2) * 0.0041
                    emitter.particleScale = adjustedScale
                    emitter.particleBirthRate = ((graphic.backingNode.size.width + graphic.backingNode.size.height) / 2) * 2.75

                }
            } else if id == "scene" { // NOTE: If you want to add particle effects to the scene the id MUST be "scene".
                if color.alpha > 0.05 {
                    emitter.particleColorSequence = nil
                    emitter.particleColor = color
                }
                // Particle emitter is on the scene
                addEmitter = SKAction.run {
                    self.containerNode.addChild(emitterNode)
                }
            }
            
            let sequence = SKAction.sequence([addEmitter, wait, removeEmitter])
            self.run(sequence)
        }
    }

    public func removeJoint(jointID: String) {
        DispatchQueue.main.async { [unowned self] in
            guard let joint = self.joints[jointID] else {
                PBLog("No joint found.")
                return
            }
            self.physicsWorld.remove(joint)
        }
    }
    
    public func deleteJoint(jointID: String) {
        DispatchQueue.main.async { [unowned self] in
            assert(self.joints[jointID] != nil)
            self.joints[jointID] = nil
        }
    }
    
    public func setLimitJointMaxLength(id: String, maxLength: Double) {
        DispatchQueue.main.async { [unowned self] in
            guard let joint: AnyObject = self.joints[id] else { PBLog("No joint found matching \(id)"); return }
            guard type(of: joint) == type(of: SKPhysicsJointLimit()) else { PBLog("Invalid Joint Type"); return }
            let actual = unsafeBitCast(joint, to: SKPhysicsJointLimit.self)
            actual.maxLength = CGFloat(maxLength)
        }
    }
    
    public func setPinJointRotationSpeed(id: String, speed: Double) {
        DispatchQueue.main.async { [unowned self] in
            guard let joint: AnyObject = self.joints[id] else { PBLog("No joint found matching \(id)"); return }
            guard type(of: joint) == type(of: SKPhysicsJointPin()) else { PBLog("Invalid Joint Type"); return }
            let actual = unsafeBitCast(joint, to: SKPhysicsJointPin.self)
            actual.rotationSpeed = CGFloat(speed)
        }
    }
    
    public func setPinJointEnableAngleLimits(id: String, enableLimits: Bool) {
        DispatchQueue.main.async { [unowned self] in
            guard let joint: AnyObject = self.joints[id] else { PBLog("No joint found matching \(id)"); return }
            guard type(of: joint) == type(of: SKPhysicsJointPin()) else { PBLog("Invalid Joint Type"); return }
            let actual = unsafeBitCast(joint, to: SKPhysicsJointPin.self)
            actual.shouldEnableLimits = enableLimits
        }
    }
    
    public func setPinJointLowerAngleLimit(id: String, lowerAngleLimit: Double) {
        DispatchQueue.main.async { [unowned self] in
            guard let joint: AnyObject = self.joints[id] else { PBLog("No joint found matching \(id)"); return }
            guard type(of: joint) == type(of: SKPhysicsJointPin()) else { PBLog("Invalid Joint Type"); return }
            let actual = unsafeBitCast(joint, to: SKPhysicsJointPin.self)
            actual.lowerAngleLimit = CGFloat(lowerAngleLimit)
        }
    }
    
    public func setPinJointUpperAngleLimit(id: String, upperAngleLimit: Double) {
        DispatchQueue.main.async { [unowned self] in
            guard let joint: AnyObject = self.joints[id] else { PBLog("No joint found matching \(id)"); return }
            guard type(of: joint) == type(of: SKPhysicsJointPin()) else { PBLog("Invalid Joint Type"); return }
            let actual = unsafeBitCast(joint, to: SKPhysicsJointPin.self)
            actual.upperAngleLimit = CGFloat(upperAngleLimit)
        }
    }
    
    public func setPinJointAxleFriction(id: String, axleFriction: Double) {
        DispatchQueue.main.async { [unowned self] in
            guard let joint: AnyObject = self.joints[id] else { PBLog("No joint found matching \(id)"); return }
            guard type(of: joint) == type(of: SKPhysicsJointPin()) else { PBLog("Invalid Joint Type"); return }
            let actual = unsafeBitCast(joint, to: SKPhysicsJointPin.self)
            actual.frictionTorque = CGFloat(axleFriction)
        }
    }
    
    public func setSlidingJointEnableDistanceLimits(id: String, enableLimits: Bool) {
        DispatchQueue.main.async { [unowned self] in
            guard let joint: AnyObject = self.joints[id] else { PBLog("No joint found matching \(id)"); return }
            guard type(of: joint) == type(of: SKPhysicsJointSliding()) else { PBLog("Invalid Joint Type"); return }
            let actual = unsafeBitCast(joint, to: SKPhysicsJointSliding.self)
            actual.shouldEnableLimits = enableLimits
        }
    }
    
    public func setSlidingJointMinimumDistanceLimit(id: String, minimumDistanceLimit: Double) {
        DispatchQueue.main.async { [unowned self] in
            guard let joint: AnyObject = self.joints[id] else { PBLog("No joint found matching \(id)"); return }
            guard type(of: joint) == type(of: SKPhysicsJointSliding()) else { PBLog("Invalid Joint Type"); return }
            let actual = unsafeBitCast(joint, to: SKPhysicsJointSliding.self)
            actual.lowerDistanceLimit = CGFloat(minimumDistanceLimit)
        }
    }
    
    public func setSlidingJointMaximumDistanceLimit(id: String, maximumDistanceLimit: Double) {
        DispatchQueue.main.async { [unowned self] in
            guard let joint: AnyObject = self.joints[id] else { PBLog("No joint found matching \(id)"); return }
            guard type(of: joint) == type(of: SKPhysicsJointSliding()) else { PBLog("Invalid Joint Type"); return }
            let actual = unsafeBitCast(joint, to: SKPhysicsJointSliding.self)
            actual.upperDistanceLimit = CGFloat(maximumDistanceLimit)
        }
    }
    
    public func setSpringJointDamping(id: String, damping: Double) {
        DispatchQueue.main.async { [unowned self] in
            guard let joint: AnyObject = self.joints[id] else { PBLog("No joint found matching \(id)"); return }
            guard type(of: joint) == type(of: SKPhysicsJointSpring()) else { PBLog("Invalid Joint Type"); return }
            let actual = unsafeBitCast(joint, to: SKPhysicsJointSpring.self)
            actual.damping = CGFloat(damping)
        }
    }
    
    public func setSpringJointFrequency(id: String, frequency: Double) {
        DispatchQueue.main.async { [unowned self] in
            guard let joint: AnyObject = self.joints[id] else { PBLog("No joint found matching \(id)"); return }
            guard type(of: joint) == type(of: SKPhysicsJointSpring()) else { PBLog("Invalid Joint Type"); return }
            let actual = unsafeBitCast(joint, to: SKPhysicsJointSpring.self)
            actual.frequency = CGFloat(frequency)
        }
    }
    
    // MARK: Actions
    
    public func runAction(id: String, action: SKAction, name: String?) {
        DispatchQueue.main.async {
            guard let graphic = self.graphicsInfo[id] else { return }
            if let name = name {
                graphic.backingNode.run(action, withKey: name)
            }
            else {
                graphic.backingNode.run(action)
            }
        }
    }
    
    public func removeAction(id: String, name: String) {
        DispatchQueue.main.async {
            guard let graphic = self.graphicsInfo[id] else { return }
            graphic.backingNode.removeAction(forKey: name)
        }
    }
    
    public func removeAllActions(id: String) {
        DispatchQueue.main.async {
            guard let graphic = self.graphicsInfo[id] else { return }
            graphic.backingNode.removeAllActions()
        }
    }
    
    public func runAnimation(id: String, animation: String, duration: Double, numberOfTimes: Int) {
        DispatchQueue.main.async {
            guard let graphic = self.graphicsInfo[id] else { return }
            let characterMap: [String:String] = ["alien":"Character3",
                                                 "codeMachine":"Character1",
                                                 "giraffe":"animal3",
                                                 "elephant":"animal1",
                                                 "piranha":"animal2"]
            var resourceNames: [String] = []
            var animationCycle: SKAction = SKAction()
            
            func appendResource(name: String) {
                var localName = name
                
                #if DEBUG
                let pathSplit = localName.split(separator: "/")
                
                if pathSplit.count > 1 {
                    localName = String(pathSplit[1])
                }
                #endif
                
                resourceNames.append(localName)
            }
            
            if animation == "springExtend" {
                appendResource(name: "springUnloaded@2x")
                appendResource(name: "springLoaded@2x")
                animationCycle = SKAction.createAnimation(fromResourceURLs: resourceNames, timePerFrame: duration)
            } else if animation == "balloon1Pop" {
                for i in 0...5 {
                    appendResource(name: "balloonPOP/balloonPOP.0000" + String(i))
                }
                animationCycle = SKAction.createAnimation(fromResourceURLs: resourceNames, timePerFrame: duration)
            } else if animation == "balloon2Pop" {
                for i in 1...6 {
                    appendResource(name: "balloonPOP2/balloonPOP2.0000" + String(i))
                }
                animationCycle = SKAction.createAnimation(fromResourceURLs: resourceNames, timePerFrame: duration)
            } else if animation == "bombExplode" {
                for i in 0...8 {
                    appendResource(name: "bombEXPLODE/bombEXPLODE.0000" + String(i))
                }
                animationCycle = SKAction.createAnimation(fromResourceURLs: resourceNames, timePerFrame: duration)
                
            } else if animation == "bombIdle" {
                for i in 0...9 {
                    appendResource(name: "bombIDLE/bombIDLE.0000" + String(i))
                }
                appendResource(name: "bombIDLE/bombIDLE.00010")
                appendResource(name: "bombIDLE/bombIDLE.00011")
                animationCycle = SKAction.createAnimation(fromResourceURLs: resourceNames, timePerFrame: duration)
            } else if animation == "throwSwitchLeft" {
                appendResource(name: "switchMid@2x")
                appendResource(name: "switchLeft@2x")
                animationCycle = SKAction.createAnimation(fromResourceURLs: resourceNames, timePerFrame: duration)
            } else if animation == "throwSwitchRight" {
                appendResource(name: "switchMid@2x")
                appendResource(name: "switchRight@2x")
                animationCycle = SKAction.createAnimation(fromResourceURLs: resourceNames, timePerFrame: duration)
            } else if animation == "tree1Idle" {
                for i in 0...6 {
                    appendResource(name: "tree1WALK/tree1WALK.0000" + String(i))
                }
                appendResource(name: "tree1@2x")
                animationCycle = SKAction.createAnimation(fromResourceURLs: resourceNames, timePerFrame: duration)
            } else if animation == "tree2Idle" {
                for i in 0...6 {
                    appendResource(name: "tree2WALK/tree2WALK.0000" + String(i))
                }
                appendResource(name: "tree2@2x")
                animationCycle = SKAction.createAnimation(fromResourceURLs: resourceNames, timePerFrame: duration)
            }  else if animation == "greenButton" || animation == "redButton" || animation == "rectangularRedButton" {
                if let originalTexture = graphic.backingNode.texture,
                    let highlightTexture = graphic.buttonHighlightTexture {
                    let textures = [highlightTexture, originalTexture]
                    animationCycle = SKAction.animate(with: textures, timePerFrame: duration)
                }
            } else if animation.contains(".idle") {
                let characterName = animation.replacingOccurrences(of: ".idle", with: "", options: .literal, range: nil)
                let resourceName = characterMap[characterName]! + "IDLE"
                for i in 0...9 {
                    appendResource(name: "\(resourceName)/\(resourceName).0000" + String(i))
                }
                appendResource(name: "\(resourceName)/\(resourceName).00010")
                appendResource(name: "\(resourceName)/\(resourceName).00011")
                animationCycle = SKAction.createAnimation(fromResourceURLs: resourceNames, timePerFrame: duration)
            } else if animation.contains(".walk") {
                let characterName = animation.replacingOccurrences(of: ".walk", with: "", options: .literal, range: nil)
                let resourceName = characterMap[characterName]! + "WALK"
                for i in 0...5 {
                    appendResource(name: "\(resourceName)/\(resourceName).0000" + String(i))
                }
                animationCycle = SKAction.createAnimation(fromResourceURLs: resourceNames, timePerFrame: duration)
            } else if animation.contains(".jump") {
                let characterName = animation.replacingOccurrences(of: ".jump", with: "", options: .literal, range: nil)
                let resourceName = characterMap[characterName]! + "JUMP"
                let staticResourceName = characterMap[characterName]! + "STATIC"
                for i in 0...5 {
                    appendResource(name: "\(resourceName)/\(resourceName).0000" + String(i))
                }
                appendResource(name: "\(staticResourceName).00000@2x")
                animationCycle = SKAction.createAnimation(fromResourceURLs: resourceNames, timePerFrame: duration)
            } else if animation.contains(".duck") {
                let characterName = animation.replacingOccurrences(of: ".duck", with: "", options: .literal, range: nil)
                let resourceName = characterMap[characterName]! + "DUCK"
                let staticResourceName = characterMap[characterName]! + "STATIC"
                appendResource(name: "\(resourceName).00000")
                appendResource(name: "\(staticResourceName).00000")
                animationCycle = SKAction.createAnimation(fromResourceURLs: resourceNames, timePerFrame: duration)
            }
            
            var animationAction: SKAction?
            
            if numberOfTimes == 1 {
                animationAction = animationCycle
            } else if numberOfTimes == -1 {
                animationAction = SKAction.repeatForever(animationCycle)
            } else if numberOfTimes > 1 {
                animationAction = SKAction.repeat(animationCycle, count: numberOfTimes)
            }
            
            if let animationAction = animationAction {
                graphic.backingNode.run(animationAction)
            }
        }
    }
    
    public func runCustomAnimation(id: String, animationSequence: [String], duration: Double, numberOfTimes: Int) {
        DispatchQueue.main.async {
            guard let graphic = self.graphicsInfo[id] else { return }
            let animation = SKAction.createAnimation(fromResourceURLs: animationSequence, timePerFrame: duration)
            if numberOfTimes == 0 {
                return
            } else if numberOfTimes == 1 {
                graphic.backingNode.run(animation)
            } else if numberOfTimes == -1 {
                let runForever = SKAction.repeatForever(animation)
                graphic.backingNode.run(runForever)
            } else if numberOfTimes > 1 {
                let runMultiple = SKAction.repeat(animation, count: numberOfTimes)
                graphic.backingNode.run(runMultiple)
            } else {
                return
            }
            
        }
        
    }
    
    public func applyImpulse(id: String, vector: CGVector) {
        DispatchQueue.main.async {
            guard let graphic = self.graphicsInfo[id] else { return }
            
            if let physicsBody = graphic.backingNode.physicsBody {
                physicsBody.applyImpulse(CGVector(dx: (vector.dx) / 3, dy: (vector.dy) / 3))
            } else {
                return
            }
            
        }
    }
    
    public func applyForce(id: String, vector: CGVector, duration: Double) {
        DispatchQueue.main.async {
            guard let graphic = self.graphicsInfo[id] else { return }
            
            if let _ = graphic.backingNode.physicsBody {
                let forceAction = SKAction.applyForce(CGVector(dx: vector.dx, dy: vector.dy), duration: duration)
                graphic.backingNode.run(forceAction)
            } else {
                return
            }
        }
    }
    
    public func useOverlay(overlay: Overlay) {
        DispatchQueue.main.async {
            self.backgroundNode.overlayImage = overlay.image()
        }
    }
    
    public func setAllowsTouchInteraction(id: String, allowsTouchInteraction: Bool) {
        DispatchQueue.main.async { [unowned self] in
            guard let graphic = self.graphicsInfo[id] else { return }
            graphic.allowsTouchInteraction = allowsTouchInteraction
        }
    }
    
    public func setDisablesOnDisconnect(id: String, disablesOnDisconnect: Bool) {
        DispatchQueue.main.async { [unowned self] in
            guard let graphic = self.graphicsInfo[id] else { return }
            graphic.disablesOnDisconnect = disablesOnDisconnect
        }
    }
    
    public func glow(id: String, radius: Double = 30.0, period: Double = 0.5, count: Int = 1) {
        DispatchQueue.main.async { [unowned self] in
            guard let graphic = self.graphicsInfo[id] else { return }
            
            graphic.glowRadius = radius
            
            if let glowNode = graphic.glowNode {
                let glowIn = SKAction.fadeIn(withDuration: period / 2.0)
                let glowOut = SKAction.fadeOut(withDuration: period / 2.0)
                
                glowIn.timingMode = SKActionTimingMode.easeOut
                glowOut.timingMode = SKActionTimingMode.easeOut
                
                let sequence = SKAction.sequence([glowIn, glowOut])
                
                if count == -1 {
                    glowNode.run(.repeatForever(sequence))
                }
                else {
                    glowNode.run(.repeat(sequence, count: count))
                }
            }
        }
    }
    
    public func setTintColor(id: String, color: UIColor?, blend: Double) {
        DispatchQueue.main.async { [unowned self] in
            guard let graphic = self.graphicsInfo[id] else { return }
            
            graphic.setTintColor(color, blend: blend)
        }
    }
    
    // MARK: Audio Node
    
    public func addAudio(id: String, sound: Sound, positional: Bool, looping: Bool, volume: Double) {
        DispatchQueue.main.async { [unowned self] in
            guard let graphic = self.graphicsInfo[id] else { return }
            
            if let audioNode = graphic.audioNode {
                audioNode.removeFromParent()
            }
            
            let audioNode = SKAudioNode(fileNamed: sound)
            audioNode.autoplayLooped = looping
            audioNode.isPositional = positional
            graphic.backingNode.addChild(audioNode)
            if volume != 100.0 {
                let initialVolume = Float(volume/100)
                audioNode.run(SKAction.changeVolume(to: initialVolume, duration: 0))
            }
        }
    }
    
    public func removeAudio(id: String) {
        DispatchQueue.main.async { [unowned self] in
            guard let graphic = self.graphicsInfo[id] else { return }
            
            if let audioNode = graphic.audioNode {
                audioNode.removeFromParent()
            }
        }
    }
    
    public func playAudio(id: String) {
        DispatchQueue.main.async { [unowned self] in
            guard let graphic = self.graphicsInfo[id] else { return }
            
            if let audioNode = graphic.audioNode {
                audioNode.run(SKAction.play())
            }
        }
    }
    
    public func stopAudio(id: String) {
        DispatchQueue.main.async { [unowned self] in
            guard let graphic = self.graphicsInfo[id] else { return }
            
            if let audioNode = graphic.audioNode {
                audioNode.run(SKAction.stop())
            }
        }
    }
    
    public func setIsAudioPositional(id: String, isAudioPositional: Bool) {
        DispatchQueue.main.async { [unowned self] in
            guard let graphic = self.graphicsInfo[id] else { return }
            
            if let audioNode = graphic.audioNode {
                audioNode.isPositional = isAudioPositional
            }
        }
    }
    
    public func touchEventAcknowledgement() {
        DispatchQueue.main.async {
            guard Message.waitingForTouchAcknowledegment else { return }
            Message.waitingForTouchAcknowledegment = false
            var keepIterating = true
            repeat {
                if let tuple = Message.messagesAwaitingSend.popLast() {
                    let (message, payloadName) = tuple
                    if payloadName == "SceneTouchEvent" {
                        Message.waitingForTouchAcknowledegment = true
                        if Message.shouldWaitForTouchAcknowledgement {
                            keepIterating = false
                        }
                        message.playgroundSend()
                        continue
                    }
                    message.playgroundSend()
                }
            } while keepIterating && Message.messagesAwaitingSend.count > 0
        }
    }
}

extension LiveViewScene: AccessibilityProxyProtocol {
    // MARK: AccessibilityProxyProtocol
    public func setAccessibilityHints(id: String, hints: AccessibilityHints?) {
        DispatchQueue.main.async {
            guard let graphic = self.graphicsInfo[id] else { return }
            graphic.accessibilityHints = hints
            
            guard let hints = hints, hints.selectImmediately == true else { return }
            guard let accessibleElements = self.accessibilityElements else { return }
            
            for elem in accessibleElements {
                if let graphicAXElement = elem as? GraphicAccessibilityElement {
                    if id == graphicAXElement.identifier {
                        UIAccessibility.post(notification: .screenChanged, argument: graphicAXElement)
                        break
                    }
                }
            }
        }
    }
}

extension LiveViewScene: AudioProxyProtocol {
    
    // MARK: AudioProxyProtocol
    public func playSound(_ sound: Sound, volume: Int = 40) {
        if self.connectedToUserProcess {
            if let url = sound.url {
                do {
                    let audioPlayer = try AVAudioPlayer(contentsOf: url)
                    audioPlayer.volume = Float(max(min(volume, 100), 0)) / 100.0
                    audioController.register(audioPlayer)
                    audioPlayer.play()
                } catch {}
            }
        }
    }

    public func playMusic(_ music: Music, volume: Int = 40) {
        if !audioController.isBackgroundAudioLoopPlaying {
            audioController.playBackgroundAudioLoop(music, volume: volume)
        } else if let background = audioController.backgroundAudioMusic, music != background {
            audioController.playBackgroundAudioLoop(music, volume: volume)
        } else {
            audioController.adjustBackgroundAudioLoop(volume: volume)
        }
    }

    public func playInstrument(_ kind: Instrument.Kind, note: Double, volume: Int) {
        DispatchQueue.main.async {
            if self.instruments[kind] == nil {
                self.instruments[kind] = self.createInstrument(kind)
            }
            guard let instrument = self.instruments[kind] else { return }
            
            // Get corresponding MIDI note value.
            let noteIndex = min(max(Int(note), 0), instrument.availableNotes.count - 1)
            
            let velocity = Double(max(min(Int(volume), 100), 0)) / 100.0 * 127.0
            
            instrument.startPlaying(noteValue: instrument.availableNotes[noteIndex], withVelocity: UInt8(velocity), onChannel: 0)
        }
    }
}

extension Sprite {
    
    convenience init(liveViewGraphic: LiveViewGraphic) {
        self.init(id: liveViewGraphic.id, graphicType: .sprite, name: liveViewGraphic.name)
        
        self.suppressMessageSending = true
        
        self.allowsRotation = liveViewGraphic.allowsRotation
        self.isDynamic = liveViewGraphic.isDynamic
        self.isAffectedByGravity = liveViewGraphic.isAffectedByGravity
        
        self.bounciness = Double(liveViewGraphic.bounciness)
        self.friction = Double(liveViewGraphic.friction)
        self.density = Double(liveViewGraphic.density)
        self.drag = Double(liveViewGraphic.drag)
        self.rotationalDrag = Double(liveViewGraphic.rotationalDrag)
        
        if let velocity = liveViewGraphic.velocity {
            self.velocity = Vector(dx: Double(velocity.dx), dy: Double(velocity.dy))
        } else {
            self.velocity = Vector(dx: 0.0, dy: 0.0)
        }
        self.rotationalVelocity = Double(liveViewGraphic.rotationalVelocity ?? 0.0)
        
        self.interactionCategory = liveViewGraphic.interactionCategory
        self.collisionNotificationCategories = liveViewGraphic.contactCategories
        self.collisionCategories = liveViewGraphic.collisionCategories
        
        self.position = Point(x: liveViewGraphic.position.x, y: liveViewGraphic.position.y)
        self.rotationRadians = liveViewGraphic.rotation
        self.xScale = liveViewGraphic.xScale
        self.yScale = liveViewGraphic.yScale
        self.text = liveViewGraphic.text ?? ""
        self.alpha = Double(liveViewGraphic.alpha)
        self.name = liveViewGraphic.name
        
        self.suppressMessageSending = false
    }
}
