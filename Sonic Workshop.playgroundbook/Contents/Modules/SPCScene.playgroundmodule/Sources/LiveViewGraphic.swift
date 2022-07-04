//
//  LiveViewGraphic.swift
//  
//  Copyright © 2020 Apple Inc. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit
import PlaygroundSupport
import SPCCore
import SPCAccessibility
import SPCAudio

enum TextureType {
    
    case background
    case graphic
    
    var maximumSize: CGSize {
        switch self {
        case .background:
            return CGSize(width: 1400, height: 1400)
            
        case .graphic:
            return CGSize(width: 500, height: 500)
        }
    }
    
    static var backgroundMaxSize = CGSize(width: 1366, height: 1366)
    static var graphicMaxSize = CGSize(width: 500, height: 500)
}

/*
    The LiveViewGraphic structure implements the live view process’s implementation of the Graphic Protocol.
    It is what actually carries out the animations and UI driven actions from the user process.
*/

public class LiveViewGraphic: Equatable, Comparable {
    
    static var cachedTextures = [Image : SKTexture]()
    static var cachedDisabledTextures = [Image : SKTexture]()
    static var cachedPaths = [Image : CGPath]()
    static var cachedSizes = [Image: CGSize]()
    
    public static func <(lhs: LiveViewGraphic, rhs: LiveViewGraphic) -> Bool {
        if lhs.name != rhs.name {
            return lhs.name < rhs.name
        } else {
            return lhs.id < rhs.id
        }
    }
    
    static var graphicsPaths: [String: [String]] = {
        guard let graphicsPathsURL = Bundle(for: LiveViewGraphic.self).url(forResource: "GraphicsPaths", withExtension: "plist"),
            let plist = NSDictionary(contentsOf: graphicsPathsURL) as? [String: [String]] else {
                NSLog("Failed to find GraphicsPaths.plist")
                return [:]
        }
        
        return plist
    }()
    
    static var tileSizes: [String: String] = {
        guard let tileSizesURL = Bundle(for: LiveViewGraphic.self).url(forResource: "TileSizes", withExtension: "plist"),
            let plist = NSDictionary(contentsOf: tileSizesURL) as? [String: String] else {
                NSLog("Failed to find TileSizes.plist")
                return [:]
        }
        return plist
    }()
    
    var buttonHighlightTexture: SKTexture?
    
    public let id: String
    public let graphicType: GraphicType
    public var name: String

    var fontName: String? = nil {
        
        didSet {
            updateTextImage()
        }
    }
    
    var fontSize: Int? = nil {
        
        didSet {
            updateTextImage()
        }
    }
    
    var textColor: UIColor? = nil {
        
        didSet {
            updateTextImage()
        }
    }

    var text: String? = nil {

        didSet {
            updateTextImage()
        }
    }
    
    var shape: BasicShape? = nil {
        didSet {
            updateShapeImage()
        }
    }
    
    public var backingNode = SKSpriteNode()
    


    public var alpha: CGFloat {
        get {
            return backingNode.alpha
        }
        
        set {
            backingNode.alpha = newValue
        }
    }
    
    public var isAffectedByGravity: Bool {
        
        didSet {
            if let physicsBody = backingNode.physicsBody {
                physicsBody.affectedByGravity = isAffectedByGravity
            } else {

            }
        }
    }
    
    public var bounciness: CGFloat {
        didSet {
            if let physicsBody = backingNode.physicsBody {
                physicsBody.restitution = bounciness
            }
        }
    }
    
    public var friction: CGFloat {
        didSet {
            if let physicsBody = backingNode.physicsBody {
                physicsBody.friction = friction
            }
        }
    }
    
    public var density: CGFloat {
        didSet {
            if let physicsBody = backingNode.physicsBody {
                physicsBody.density = density
            }
        }
    }
    
    public var drag: CGFloat {
        didSet {
            if let physicsBody = backingNode.physicsBody {
                physicsBody.linearDamping = drag
            }
        }
    }
    
    public var rotationalDrag: CGFloat {
        didSet {
            if let physicsBody = backingNode.physicsBody {
                physicsBody.angularDamping = rotationalDrag
            }
        }
    }
    
    public var interactionCategory: InteractionCategory {
        didSet {
            if let physicsBody = backingNode.physicsBody {
                physicsBody.categoryBitMask = interactionCategory.rawValue
            }
        }
    }
    
    public var collisionCategories: InteractionCategory {
        didSet {
            if let physicsBody = backingNode.physicsBody {
                physicsBody.collisionBitMask = collisionCategories.rawValue
            }
        }
    }
    
    public var contactCategories: InteractionCategory {
        didSet {
            if let physicsBody = backingNode.physicsBody {
                physicsBody.contactTestBitMask = contactCategories.rawValue
            }
        }
    }
    
    public var isDynamic: Bool {
        didSet {
            if let physicsBody = backingNode.physicsBody {
                physicsBody.isDynamic = isDynamic
            } else {
                
            }
        }
    }
    
    public var allowsRotation: Bool {
        didSet {
            if let physicsBody = backingNode.physicsBody {
                physicsBody.allowsRotation = allowsRotation
            } else {
                
            }
        }
    }
    
    public var allowsTouchInteraction: Bool = true

    // Defaults to no rotation applied. Implied zero.
    public var rotation: CGFloat {
        get {
            return backingNode.zRotation
        }
        
        set {
            backingNode.zRotation = newValue

        }
        
    }
    
    public var isHidden: Bool {
        get {
            return backingNode.isHidden
        }
        
        set {
            backingNode.isHidden = newValue
        }
    }
    
    public var position: CGPoint {
        get {
            return backingNode.position
        }
        
        set {
            backingNode.position = newValue
        }
    }
    
    public var xScale: Double {
        get {
            return Double(backingNode.xScale)
        }
    }
    
    public var yScale: Double {
        get {
            return Double(backingNode.yScale)
        }
    }
    
    public var columns: Int = 1
    public var rows: Int = 1
    
    public var isTiled: Bool {
        guard (columns > 0) && (rows > 0) else { return false }
        return (columns > 1) || (rows > 1)
    }
    
    public var velocity: CGVector? {
        get {
            return backingNode.physicsBody?.velocity
        }
        
        set {
            guard let physicsBody = backingNode.physicsBody, let vel = newValue else { return }
            physicsBody.velocity = vel
        }
    }
    
    public var rotationalVelocity: CGFloat? {
        get {
            return backingNode.physicsBody?.angularVelocity
        }
        
        set {
            guard let physicsBody = backingNode.physicsBody, let vel = newValue else { return }
            physicsBody.angularVelocity = vel
        }
    }
    
    private var _glowNode: SKEffectNode?
    public var glowNode: SKEffectNode? {
        get {
            if _glowNode == nil {
                let view = SKView()
                let texture = view.texture(from: backingNode)
                let newGlowNode = SKEffectNode()
                
                newGlowNode.shouldRasterize = true
                newGlowNode.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius":glowRadius])
                newGlowNode.addChild(SKSpriteNode(texture: texture))
                newGlowNode.alpha = 0.0
                
                backingNode.addChild(newGlowNode)
                
                _glowNode = newGlowNode
            }
            
            // adjust for changes to the parent node
            _glowNode?.xScale = 1.5/backingNode.xScale
            _glowNode?.yScale = 1.5/backingNode.yScale
            _glowNode?.zRotation = -backingNode.zRotation
            
            return _glowNode
        }
        set {
            if newValue == nil, let oldGlowNode = _glowNode {
                backingNode.removeChildren(in: [oldGlowNode])
                
                _glowNode = nil
            }
        }
    }
    
    public var glowRadius: Double = 0.0 {
        didSet {
            glowNode = nil
        }
    }
    
    private var tintTexture: SKTexture? {
        guard let image = self.image else { return nil }
        var tintTexture: SKTexture? = nil
        
        if let tintColor = tintColor, let uiImage = UIImage(named: image.path), let tintImage = uiImage.colorize(color: tintColor, blend: CGFloat(tintColorBlend)) {
            tintTexture = SKTexture(image: tintImage)
        }
        
        return tintTexture
    }
    
    private var tintColor: UIColor? = nil
    private var tintColorBlend: Double = 0.5
    func setTintColor(_ color: UIColor?, blend: Double) {
        tintColor = color
        tintColorBlend = blend
        
        if blend > 0.0 && tintColor != nil {
            guard let tintTexture = tintTexture else { return }
            
            backingNode.texture = tintTexture
        } else {
            applyImage()
        }
    }
    
    // Returns the attached audio node, if there is on.
    public var audioNode: SKAudioNode? {
        return backingNode.children.filter({$0 is SKAudioNode}).first as? SKAudioNode
    }
    
    public var image: Image? {
        didSet {
            applyImage()
        }
    }
    
    var disablesOnDisconnect: Bool = false
    
    private var disabledTexture: SKTexture? {
        guard let image = self.image else { return nil }
        
        if let texture = LiveViewGraphic.cachedDisabledTextures[image] {
            return texture
        }
        
        if let uiImage = UIImage(named: image.path), let monoImage = uiImage.disabledImage(alpha: 0.5) {
            let disabledTexture = SKTexture(image: monoImage)
            LiveViewGraphic.cachedDisabledTextures[image] = disabledTexture
            return disabledTexture
        }
        
        return nil
    }
    
    func setDisabledAppearance(_ disabled: Bool) {
        if disabled {
            if let physicsBody = backingNode.physicsBody {
                physicsBody.velocity = CGVector(dx: 0, dy: 0)
                physicsBody.angularVelocity = 0
            }
            backingNode.removeAllActions()
            
            // Stop playing any audio.
            audioNode?.run(SKAction.stop())
            
            // If the audio is looped, remove the node entirely.
            if let audionode = audioNode, audionode.autoplayLooped {
                audionode.removeFromParent()
            }
            
            guard let disabledTexture = disabledTexture else { return }
            backingNode.texture = disabledTexture
            updateTextImage(useDisabled: true)
        } else {
            applyImage()
        }
    }
    
    func applyImage() {
        guard
            let image = image,
            let texture = LiveViewGraphic.texture(for: image) else {
                backingNode.texture = nil
                return
        }
        updateBackingNode(texture: texture)
    }
    
    public var accessibilityHints: AccessibilityHints?
    
    private func updateBackingNode(texture: SKTexture) {
        if isTiled {
            backingNode.children.forEach { $0.removeFromParent() }  // Remove any previous tile map node.
            
            let tileDefinition = SKTileDefinition(texture: texture)
            let tileGroup = SKTileGroup(tileDefinition: tileDefinition)
            let tileSet = SKTileSet(tileGroups: [tileGroup], tileSetType: .grid)
            let tileSize: CGSize
            if let image = image, let size = size(for: image) {
                tileSize = size
            } else {
                tileSize = tileSet.defaultTileSize // Texture size
            }
            let tileMapNode = SKTileMapNode(tileSet: tileSet, columns: columns, rows: rows, tileSize: tileSize)
            tileMapNode.fill(with: tileGroup)
            tileMapNode.name = backingNode.name
            backingNode.addChild(tileMapNode)
            backingNode.size = tileMapNode.mapSize
        } else {
            backingNode.texture = texture
            let textureSize = texture.size()
            backingNode.size = CGSize(width: textureSize.width * CGFloat(xScale), height: textureSize.height * CGFloat(yScale))
        }
        
        guard graphicType == .sprite || graphicType == .character else { return }
        
        // Sprite => set up physics body.
        let physicsBody: SKPhysicsBody
        if isTiled {
            physicsBody = SKPhysicsBody(rectangleOf: backingNode.size)
            physicsBody.isDynamic = self.isDynamic
        } else if let image = image, let polygonPath = path(for: image) {
            physicsBody = SKPhysicsBody(polygonFrom: polygonPath)
        } else if let shape = shape {
            switch shape {
            case let .circle(radius, _, _):
                physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(radius))
            case let .rectangle(width, height, cornerRadius, _, _):
                let rect = CGRect(x: 0, y: 0, width: width, height: height)
                let roundedRectanglePoints = UIBezierPath(roundedRect: rect, cornerRadius: CGFloat(cornerRadius)).cgPath.points()
                physicsBody = SKPhysicsBody(polygonFrom: createOffsetPath(from: roundedRectanglePoints))
            case let .polygon(radius, sides, _, _):
                let rect = CGRect(x: 0, y: 0, width: radius * 2, height: radius * 2)
                let polygonPoints = UIBezierPath(polygonIn: rect, sides: sides).cgPath.points()
                physicsBody = SKPhysicsBody(polygonFrom: createOffsetPath(from: polygonPoints))
            case .star:
                physicsBody = SKPhysicsBody(texture: texture, alphaThreshold: 0.75, size: texture.size())
            }
        } else {
            physicsBody = SKPhysicsBody(circleOfRadius: max(backingNode.size.width / 2, backingNode.size.height / 2))
        }
        
        // We reset the scale here so that the new physics body will scale with the sprite.
        let currentXScale = backingNode.xScale
        let currentYScale = backingNode.yScale
        backingNode.yScale = 1
        backingNode.xScale = 1
        
        if let body = self.backingNode.physicsBody {
            // Existing physics body => replicate its properties.
            physicsBody.affectedByGravity = body.affectedByGravity
            physicsBody.allowsRotation = body.allowsRotation
            physicsBody.contactTestBitMask = body.contactTestBitMask
            physicsBody.collisionBitMask = body.collisionBitMask
            physicsBody.categoryBitMask = body.categoryBitMask
            physicsBody.isDynamic = body.isDynamic
            physicsBody.friction = body.friction
            physicsBody.angularDamping = body.angularDamping
            physicsBody.restitution = body.restitution
            physicsBody.angularVelocity = body.angularVelocity
            physicsBody.velocity = body.velocity
            
        } else {
            // New physics body.
            physicsBody.affectedByGravity = false
            physicsBody.allowsRotation = false
            physicsBody.contactTestBitMask = 0xFFFFFFFF
        }
            
        physicsBody.usesPreciseCollisionDetection = true
        
        // Set the scale to what it was before creating the new physics body.
        backingNode.physicsBody = physicsBody
        backingNode.xScale = currentXScale
        backingNode.yScale = currentYScale
    }
    
    private func createOffsetPath(from points: [CGPoint]) -> CGPath {
        let offsetX = backingNode.size.width * backingNode.anchorPoint.x
        let offsetY = backingNode.size.height * backingNode.anchorPoint.y
        
        let path = CGMutablePath()
        for (index, oldPoint) in points.enumerated() {
            var newPoint = oldPoint
            newPoint.x -= offsetX
            newPoint.y -= offsetY
            if index == 0 {
                path.move(to: newPoint)
            } else {
                path.addLine(to: newPoint)
            }
        }
        path.closeSubpath()
        return path
    }
    
    private func path(for image: Image) -> CGPath? {
        if let path = LiveViewGraphic.cachedPaths[image] { return path }
        guard let stringPoints = LiveViewGraphic.graphicsPaths[image.description] else {
            return nil
        }
        
        let points = stringPoints.map(NSCoder.cgPoint)
        let path = createOffsetPath(from: points)
        
        LiveViewGraphic.cachedPaths[image] = path
        return path
    }
    
    private func size(for image: Image) -> CGSize? {
        if let size = LiveViewGraphic.cachedSizes[image] { return size }
        guard let stringSize = LiveViewGraphic.tileSizes[image.description] else {
            return nil
        }
        
        let size = NSCoder.cgSize(for: stringSize)
        
        LiveViewGraphic.cachedSizes[image] = size
        return size
    }
    
    class func texture(for image: Image, type: TextureType = .graphic) -> SKTexture? {
        
        if let texture = LiveViewGraphic.cachedTextures[image] {
            return texture
        }
        
        var uiImage = image.uiImage
        
        // clamp image to maxTextureSize
        let maxSize = type.maximumSize
        if (uiImage.size.width > maxSize.width ||
            uiImage.size.height  > maxSize.height) {
            uiImage = uiImage.resized(to: uiImage.size.fit(within: maxSize))
        }
        
        let texture = SKTexture(image: uiImage)
        LiveViewGraphic.cachedTextures[image] = texture
        
        return texture
    }
    
    var graphic: Graphic {
        
        let _graphic = Graphic(id: id, name: name)
        _graphic.suppressMessageSending = true
        _graphic.text = text ?? ""
        _graphic.alpha = Double(alpha)
        _graphic.position = Point(position)
        _graphic.isHidden = isHidden
        _graphic.rotationRadians = rotation
        _graphic.xScale = xScale
        _graphic.yScale = yScale
        _graphic.image = image
        _graphic.name = name
        _graphic.size = Size(backingNode.size)
        
        if let color = textColor {
            _graphic.textColor = color
        }
        
        if let name = fontName, let liveGraphicFontName = Font(rawValue: name) {
            _graphic.font = liveGraphicFontName
        }
        
        return _graphic
    }


    public required init(id: String, name: String, graphicType: GraphicType) {
        self.id = id
        self.isAffectedByGravity = false
        self.bounciness = 0.2
        self.friction = 0.2
        self.density = 1.0
        self.drag = 0.1
        self.rotationalDrag = 0.1
        self.interactionCategory = .all
        self.collisionCategories = .all
        self.contactCategories = []
        self.isDynamic = true
        self.allowsRotation = false
        self.graphicType = graphicType
        self.name = name
    }
    
    func updateShapeImage() {
        guard let shape = shape else { return }
        
        let texture = SKTexture(image: shape.image)
        updateBackingNode(texture: texture)
    }
    
    func updateTextImage(useDisabled: Bool = false) {
        guard let textImage = createTextImage() else { return }
        
        var compositeImage = textImage
        
        if graphicType == .button {
            guard let image = image else {
                return
            }
            
            var uiImage = Image(imageLiteralResourceName: image.path).uiImage
            let maxSize = TextureType.graphic.maximumSize
            if (uiImage.size.width > maxSize.width ||
                uiImage.size.height  > maxSize.height) {
                uiImage = uiImage.resized(to: uiImage.size.fit(within: maxSize))
            }
            
            if useDisabled {
                let monoImage = uiImage.disabledImage(alpha: 1.0) ?? uiImage
                compositeImage = LiveViewGraphic.compositeImage(from: textImage, overlaidOn: monoImage)
            } else {
                compositeImage = LiveViewGraphic.compositeImage(from: textImage, overlaidOn: uiImage)
                updateButtonHighlight(image: image, textImage: textImage)
            }
        }
        
        let texture = SKTexture(image: compositeImage)
        backingNode.texture = texture
        let textureSize = texture.size()
        backingNode.size = CGSize(width: textureSize.width * CGFloat(xScale), height: textureSize.height * CGFloat(yScale))
    }
    
    func updateButtonHighlight(image: Image, textImage: UIImage) {
        let highlightImagePath = "\(image.path)_down"
        if let highlightImage = UIImage(named: highlightImagePath) {
            let highlightCompositeImage = LiveViewGraphic.compositeImage(from: textImage, overlaidOn: highlightImage)
            buttonHighlightTexture = SKTexture(image: highlightCompositeImage)
        }
    }
    
    func createTextImage() -> UIImage? {
        guard
            let text = text,
            let textColor = textColor,
            let fontName = fontName,
            let fontSize = fontSize
            else { return nil }
        
        var font: UIFont
        if fontName.starts(with: "System") {
            let weightString = fontName.replacingOccurrences(of: "System", with: "", options: .literal, range: nil)
            if weightString == "Italic" {
                font = UIFont.italicSystemFont(ofSize: CGFloat(fontSize))
            } else if weightString == "BoldItalic" {
                font = UIFont.systemFont(ofSize: CGFloat(fontSize), weight: UIFont.Weight.regular).boldItalic
            } else if weightString == "HeavyItalic" {
                font = UIFont.systemFont(ofSize: CGFloat(fontSize), weight: UIFont.Weight.heavy).italic
            } else {
                if let weight = Double(weightString) {
                    font = UIFont.systemFont(ofSize: CGFloat(fontSize), weight: UIFont.Weight(rawValue: CGFloat(weight)))
                } else {
                    font = UIFont.systemFont(ofSize: CGFloat(fontSize), weight: UIFont.Weight.regular)
                }
            }
            
        } else {
            if let unwrappeFont = UIFont(name: fontName, size: CGFloat(fontSize)) {
                font = unwrappeFont
            } else {
                font = UIFont.systemFont(ofSize: CGFloat(fontSize), weight: UIFont.Weight.regular)
            }
        }
        
        return LiveViewGraphic.image(from: text, textColor: textColor, font: font)
    }

    
    class func compositeImage(from textImage: UIImage, overlaidOn backgroundImage: UIImage) -> UIImage {
        var compositeImage = backgroundImage
        
        // Create an image with a small resizable center.
        let insetH = (backgroundImage.size.width / 2)
        let insetV = (backgroundImage.size.height / 2)
        let insets = UIEdgeInsets(top: insetV - 1, left: insetH - 1, bottom: insetV, right: insetH)
        compositeImage = backgroundImage.resizableImage(withCapInsets: insets)
        
        // Resize image so that it has some padding around textImage.
        let imageSize = CGSize(width: textImage.size.width + 40, height: textImage.size.height + 30)
        compositeImage = compositeImage.resized(to: imageSize)
        
        // Overlay textImage on top (in the center).
        return compositeImage.overlaid(with: textImage, offsetBy: CGPoint(x: 0, y: 0))
    }

    class func image(from text: String, textColor: UIColor, font: UIFont) -> UIImage? {
        let text = text as NSString
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        let attributes: [NSAttributedString.Key: Any] = [
            .font : font,
            .foregroundColor: textColor,
            .paragraphStyle: style
        ]
        let constrainedSize = CGSize(width: Scene.sceneSize.width / 2, height: Scene.sceneSize.height)
        let textBounds = text.boundingRect(with: constrainedSize,
                                            options: .usesLineFragmentOrigin,
                                            attributes: attributes,
                                            context: nil)
        let textSize = textBounds.size
        guard textSize.width > 1 && textSize.height > 1 else { return nil }
        
        UIGraphicsBeginImageContextWithOptions(textSize, false, 0.0)
        
        text.draw(in: CGRect(x:0, y:0, width:textSize.width,  height:textSize.height), withAttributes: attributes)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

    
    // Equatable Conformance
    public static func ==(lhs: LiveViewGraphic, rhs: LiveViewGraphic) -> Bool {
        return lhs.backingNode === rhs.backingNode // Intentionally testing for object identity
    }
    
    public class func didReceiveMemoryWarning() {
        // When we receive memory pressure, drop the texture caches as they can get a bit unwieldy (45272896).
        LiveViewGraphic.cachedTextures.removeAll()
        LiveViewGraphic.cachedDisabledTextures.removeAll()
    }
}
