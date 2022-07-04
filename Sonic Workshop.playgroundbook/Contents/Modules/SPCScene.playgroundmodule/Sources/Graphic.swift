//
//  Graphic.swift
//  
//  Copyright © 2020 Apple Inc. All rights reserved.
//

import Foundation
import UIKit
import PlaygroundSupport
import SpriteKit
import SPCIPC
import SPCCore
import SPCAccessibility
import SPCAssessment
import SPCAudio

/// An enumeration of the types of Graphics, including: graphic, sprite, character, button, and label.
///
/// - localizationKey: GraphicType
public enum GraphicType: String {
    case graphic
    case sprite
    case character
    case button
    case label
}

/// An enumeration of the types of basic shapes, including: circle, rectangle, polygon, and star.
///
/// - localizationKey: BasicShape
public enum BasicShape {
    case circle(radius: Int, color: Color, gradientColor: Color)
    case rectangle(width: Int, height: Int, cornerRadius: Double, color: Color, gradientColor: Color)
    case polygon(radius: Int, sides: Int, color: Color, gradientColor: Color)
    case star(radius: Int, points: Int, sharpness: Double, color: Color, gradientColor: Color)
    
    public var size: CGSize {
        switch self {
        case let .circle(radius, _, _):
            return CGSize(width: radius * 2, height: radius * 2)
        case let .rectangle(width, height, _, _, _):
            return CGSize(width: width, height: height)
        case let .polygon(radius, _, _, _):
            return CGSize(width: radius * 2, height: radius * 2)
        case let .star(radius, _, _, _, _):
            return CGSize(width: radius * 2, height: radius * 2)
        }
    }
    
    private var color: Color {
        switch self {
        case let .circle(_, color, _):
            return color
        case let .rectangle(_, _, _, color, _):
            return color
        case let .polygon(_, _, color, _):
            return color
        case let .star(_, _, _, color, _):
            return color
        }
    }
    
    private var gradientColor: Color {
        switch self {
        case let .circle(_, _, gradientColor):
            return gradientColor
        case let .rectangle(_, _, _, _, gradientColor):
            return gradientColor
        case let .polygon(_, _, _, gradientColor):
            return gradientColor
        case let .star(_, _, _, _, gradientColor):
            return gradientColor
        }
    }
    
    private var path: CGPath {
        let origin = CGPoint(x: 0, y: 0)
        switch self {
        case .circle:
            return UIBezierPath(ovalIn: CGRect(origin: origin, size: size)).cgPath
        case let .rectangle(_, _, cornerRadius, _, _):
            return UIBezierPath(roundedRect: CGRect(origin: origin, size: size), cornerRadius: CGFloat(cornerRadius)).cgPath
        case let .polygon(_, sides, _, _):
            return UIBezierPath(polygonIn: CGRect(origin: origin, size: size), sides: sides).cgPath
        case let .star(_, points, sharpness, _, _):
            return UIBezierPath(starIn: CGRect(origin: origin, size: size), points: points, sharpness: CGFloat(sharpness)).cgPath
        }
    }
    
    var image: UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.saveGState()
        
        ctx.beginPath()
        ctx.addPath(path)
        ctx.clip()
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colors = [color.cgColor, gradientColor.cgColor] as CFArray
        
        let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: nil)!
        ctx.drawLinearGradient(gradient, start: CGPoint(x: 0, y: 0), end: CGPoint(x: 0, y: size.height), options: [])
        
        ctx.restoreGState()
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return img ?? UIImage()
    }
    
    enum ShapeType: String, RawRepresentable {
        case circle
        case rectangle
        case polygon
        case star
    }
    
    var type: ShapeType {
        switch self {
        case .circle:
            return .circle
        case .polygon:
            return .polygon
        case .rectangle:
            return .rectangle
        case .star:
            return .star
        }
    }
}

/// An enumeration of the types of basic shapes, including: circle, rectangle, polygon and star.
///
/// - localizationKey: Shape
public enum Shape {
    case circle(radius: Int)
    case rectangle(width: Int, height: Int, cornerRadius: Double)
    case polygon(radius: Int, sides: Int)
    case star(radius: Int, points: Int, sharpness: Double)
}

/*
    The Graphic class implements the user process’s implementation of the Graphic protocol.
    It works by sending messages to the live view when appropriate, where the real actions are enacted.
    It is a proxy, that causes its remote counterpart to invoke actions that affect the live view.
 */

/// A Graphic object, made from an image or string, that can be placed on the scene.
///
/// - localizationKey: Graphic
open class Graphic: MessageControl {
    
    fileprivate static var defaultNameCount = 1
    
    /// An id, used to identify a Graphic. Read-only.
    ///
    /// - localizationKey: Graphic.id
    public let id: String
        
    /// The name of the graphic.
    ///
    /// - localizationKey: Graphic.name
    public var name: String
    
    var graphicType: GraphicType = .graphic
    
    let defaultAnimationTime = 0.5
    
    public var suppressMessageSending: Bool = false
    
    public var onTouchHandler: (() -> Void)?
    
    public var onTouchMovedHandler: ((Touch) -> Void)?
    
    /// The function that gets called when you touch a Graphic.
    ///
    /// - localizationKey: Graphic.setOnTouchHandler(_:)
    public func setOnTouchHandler(_ handler: @escaping (() -> Void)) {
        onTouchHandler = handler
    }
    
    /// The function to be called whenever the touch data is updated over this graphic, i.e. when you touch and drag over the graphic.
    ///
    /// - localizationKey: Graphic.setOnTouchMovedHandler(_:)
    public func setOnTouchMovedHandler(_ handler: @escaping ((Touch) -> Void)) {
        onTouchMovedHandler = handler
    }
    
    var font: Font = .SystemFontRegular {
       
        didSet {
            guard !suppressMessageSending else { return }
            SceneProxy().setFontName(id: id, name: font.rawValue)
        }
    }
    
    var fontSize: Double = 32  {
       
        didSet {
            guard !suppressMessageSending else { return }
            SceneProxy().setFontSize(id: id, size: Int(fontSize))
        }
    }
    
    var text: String = "" {
       
        didSet {
            guard !suppressMessageSending else { return }
            SceneProxy().setText(id: id, text: text)
        }
    }
    
    public var zPosition: Double = 1.0 {
        didSet {
            guard !suppressMessageSending else { return }
            SceneProxy().setZPosition(id: id, position: zPosition)
        }
    }

    var textColor: Color = .black {
      
        didSet {
            guard !suppressMessageSending else { return }
            let color = textColor
            SceneProxy().setTextColor(id: id, color: color)
        }
    }
    
    /**
    Controls whether a graphic will respond to touch events.

    If this value is `false`, the graphic will ignore touch events. Handlers such as `onTouchHandler` won't be able to run.
     
    This value is `true` by default.

     - localizationKey: Graphic.allowsTouchInteraction
    */
    public var allowsTouchInteraction: Bool = true {
        didSet {
            guard !suppressMessageSending else { return }
            SceneProxy().setAllowsTouchInteraction(id: id, allowsTouchInteraction: allowsTouchInteraction)
        }
    }
    
    public var accessibilityHints: AccessibilityHints?  {
        
        didSet {
            guard !suppressMessageSending else { return }
            
            if let accessibilityHints = accessibilityHints {
                AccessibilityProxy().setAccessibilityHints(id: id, hints: accessibilityHints)
            }
        }
    }
    
    public init(graphicType: GraphicType = .graphic, name: String = "") {
        self.id = UUID().uuidString
        self.graphicType = graphicType
        self.name = name
        SceneProxy().createNode(id: id, graphicName: name, graphicType: graphicType)
    }
    
    /// Creates a Graphic with the given identifier; for example, reconstructing a graphic.
    ///
    /// - Parameter id: The identifier associated with the Graphic.
    /// - Parameter graphicType: The graphic type associated with the Graphic.
    /// - Parameter name: The name associated with the Graphic.
    ///
    /// - localizationKey: Graphic(id:name:graphicType:)
    public init(id: String, graphicType: GraphicType = .graphic, name: String = "") {
        self.id = id
        self.name = name
        self.graphicType = graphicType
    }
    
        
    /// Creates a Graphic from a given image and name.
    ///
    /// - Parameter image: The image you choose to create the Graphic.
    /// - Parameter name: The name you give to the Graphic.
    ///
    /// - localizationKey: Graphic(image:name:)
    public convenience init(image: Image, name: String = "") {
        if name == "" {
            self.init(graphicType: .graphic, name: "graphic" + String(Graphic.defaultNameCount))
            Graphic.defaultNameCount += 1
        } else {
            self.init(graphicType: .graphic, name: name)
        }
        
        self.image = image
        
        updateSize()
        
        /*
            Manually sending a message here, as setting a property on a struct
            from within one of its own initializers won’t trigger the didSet property.
        */
        SceneProxy().setImage(id: id, image: image)
    }
    
    /// Creates a Graphic with a specified shape, color, gradient, and name.
    /// Example usage:
    /// ````
    /// let pentagon = Graphic(shape: .polygon(radius: 50, sides: 5), color: .red, gradientColor: .yellow, name: \"pentagon\")
    /// ````
    /// - Parameter shape: One of the Graphic shapes.
    /// - Parameter color: A fill color for the Graphic.
    /// - Parameter gradientColor: A secondary color for the gradient.
    /// - Parameter name: An optional name you can give to the shape. You can choose to leave the name blank.
    ///
    /// - localizationKey: Graphic(shape:color:gradientColor:name:)
    public convenience init(shape: Shape, color: Color, gradientColor: Color? = nil, name: String = "") {
        if name == "" {
            self.init(graphicType: .graphic, name: "graphic" + String(Graphic.defaultNameCount))
            Graphic.defaultNameCount += 1
        } else {
            self.init(graphicType: .graphic, name: name)
        }
        
        updateShape(shape: shape, color: color, gradientColor: gradientColor ?? color)
        
        updateSize()
    }
    
    public func updateShape(shape: Shape, color: Color, gradientColor: Color) {
        let basicShape: BasicShape
        switch shape {
        case .circle(let radius):
            basicShape = .circle(radius: radius, color: color, gradientColor: gradientColor)
        case .rectangle(let width, let height, let cornerRadius):
            basicShape = .rectangle(width: width, height: height, cornerRadius: cornerRadius, color: color, gradientColor: gradientColor)
        case .polygon(let radius, let sides):
            basicShape = .polygon(radius: radius, sides: sides, color: color, gradientColor: gradientColor)
        case .star(let radius, let points, let sharpness):
            basicShape = .star(radius: radius, points: points, sharpness: sharpness, color: color, gradientColor: gradientColor)
        }
        
        self.shape = basicShape
        /*
         Manually sending a message here, as setting a property on a struct
         from within one of its own initializers won’t trigger the didSet property.
         */
        SceneProxy().setShape(id: id, shape: basicShape)
    }
    
    public func updateSize() {
        var baseSize = CGSize.zero
        
        if let image = image {
            baseSize = image.size
        } else if let shape = shape {
            baseSize = shape.size
        }
        
        size = Size(width: Double(baseSize.width) * xScale, height: Double(baseSize.height) * yScale)
    }
    
    convenience init(named: String) {
        self.init(image: Image(imageLiteralResourceName: named), name: "graphic") // We  need an id generated
    }
    
       
    func send(_ action: SKAction, withKey: String? = nil) {
       
        guard !suppressMessageSending else { return }
        SceneProxy().runAction(id: id, action: action, name: withKey)
    }
    
    public var isHidden: Bool = false {
      
        didSet {
            
            guard !suppressMessageSending else { return }
            if isHidden {
                send(.hide(), withKey: "hide")
            }
            else {
                send(.unhide(), withKey: "unhide")
            }
        }
    }
    
    public var disablesOnDisconnect: Bool = false {
        didSet {
            guard !suppressMessageSending else { return }
            SceneProxy().setDisablesOnDisconnect(id: id, disablesOnDisconnect: disablesOnDisconnect)
        }
        
    }
    
    /// Whether the graphic has a sound attached.
    ///
    /// - localizationKey: Graphic.hasAudio
    public private(set) var hasAudio: Bool = false
    
    /// Set to `true` to make the audio attached to this graphic positional. The default is `true`.
    ///
    /// - localizationKey: Graphic.isAudioPositional
    public var isAudioPositional: Bool = true {
        didSet {
            guard !suppressMessageSending else { return }
            SceneProxy().setIsAudioPositional(id: id, isAudioPositional: isAudioPositional)
        }
        
    }
    
    /// How transparent the graphic is—from 0.0 (totally transparent) to 1.0 (totally opaque).
    ///
    /// - localizationKey: Graphic.alpha
    public var alpha: Double = 1.0 {
       
        didSet {
            guard !suppressMessageSending else { return }
            send(.fadeAlpha(to: CGFloat(alpha), duration: 0), withKey: "fadeAlpha")
        }
    }
    
    
    /// The angle, in degrees, to rotate the graphic. Changing the angle rotates the graphic counterclockwise around its center. A value of `0.0` (the default) means no rotation. A value of `180.0` rotates the object 180 degrees.
    ///
    /// - localizationKey: Graphic.rotation
    public var rotation: Double {
        get {
            return Double(rotationRadians / CGFloat.pi) * 180.0
        }
        set(newRotation) {
            rotationRadians = (CGFloat(newRotation) / 180.0) * CGFloat.pi
        }
    }
    
    // Internal only representation of the rotation in radians.
    var rotationRadians: CGFloat = 0 {
       
        didSet {
            
            guard !suppressMessageSending else { return }
            send(.rotate(toAngle: rotationRadians, duration: 0, shortestUnitArc: false), withKey: "rotateTo")
        }
    }
    
    /// Position is the *x* and *y* coordinate of the center of a graphic.
    ///
    /// - localizationKey: Graphic.position
    public var position: Point = Point(x: 0, y: 0) {
        
        didSet {
            
            guard !suppressMessageSending else { return }
            send(.move(to: CGPoint(position), duration: 0), withKey: "moveTo")
        }
    }
    
    /// Placing the center of the Graphic at a certain point.
    ///
    /// - Parameter at: a point on the scene, Point(x:y:)
    ///
    /// - localizationKey: Graphic.place(at:)
    public func place(at: Point) {
        SceneProxy().placeGraphic(id: id, position: CGPoint(at), isPrintable: false, anchorPoint: .center)
    }
    
    /// Size of the Graphic, respecting scale.
    ///
    /// - localizationKey: Graphic.size
    public internal(set) var size: Size = Size(width: 0.0, height: 0.0)
    
    /// The scale of the Graphic’s size, where `1.0` is normal, `0.5` is half the normal size, and `2.0` is twice the normal size.
    ///
    /// - localizationKey: Graphic.scale
    public var scale: Double  = 1.0 {
        
        didSet {
            xScale = scale
            yScale = scale
            
            updateSize()
            
            guard !suppressMessageSending else { return }
            send(SKAction.scale(to: CGFloat(scale), duration: 0))
        }
    }
    
    /// A value for scaling only the *x* value of a Graphic. The default is `1.0`.
    ///
    /// - localizationKey: Graphic.xScale
    public var xScale: Double = 1.0 {
        didSet {
            updateSize()
            
            guard !suppressMessageSending else { return }
            SceneProxy().setXScale(id: id, scale: xScale)
            
        }
    }
    
    /// A value for scaling only the *y* value of a Graphic. The default is `1.0`.
    ///
    /// - localizationKey: Graphic.yScale
    public var yScale: Double = 1.0 {
        didSet {
            updateSize()
            
            guard !suppressMessageSending else { return }
            SceneProxy().setYScale(id: id, scale: yScale)
        }
    }
    
    /// The image displayed by the Graphic.
    ///
    /// - localizationKey: Graphic.image
    public var image: Image? = nil {
        didSet {
            updateSize()
            
            guard !suppressMessageSending else { return }
            SceneProxy().setImage(id: id, image: image)
        }
    }
    
    var shape: BasicShape? = nil {
        didSet {
            updateSize()
            
            guard !suppressMessageSending else { return }
            SceneProxy().setShape(id: id, shape: shape)
        }
    }
    
    /// Sets the Graphic tint color.
    ///
    /// - Parameter color: The color with which the Graphic is tinted.
    /// - Parameter blend: The degree to which the color is blended with the Graphic image from 0.0 to 1.0. The default is '0.5'.
    ///
    /// - localizationKey: Graphic.setTintColor(color:blend:)
    public func setTintColor(_ color: UIColor?, blend: Double = 0.5) {
        SceneProxy().setTintColor(id: id, color: color, blend: blend)
    }
    
    /// The Graphic’s distance from the given point.
    ///
    /// - Parameter from: The point from which to measure distance.
    ///
    /// - localizationKey: Graphic.distance(from:)
    public func distance(from: Point) -> Double {
        
        return position.distance(from: from)
        
    }
    
    /// Runs an Action with an associated key on a Graphic.
    ///
    /// - Parameter action: The Action for the Graphic to run.
    /// - Parameter key: A String used to identify the Action.
    ///
    /// - localizationKey: Graphic.run(_:key:)
    public func run(_ action: SKAction, key: String? = nil) {
        SceneProxy().runAction(id: id, action: action, name: key)
    }
    
    /// Removes an Action from the Graphic.
    ///
    /// - Parameter key: A String used to identify the Action.
    ///
    /// - localizationKey: Graphic.removeAction(forKey:)
    public func removeAction(forKey key: String) {
        SceneProxy().removeAction(id: id, name: key)
    }
    
    /// Removes all Actions from the Graphic.
    ///
    /// - localizationKey: Graphic.removeAllActions()
    public func removeAllActions() {
        SceneProxy().removeAllActions(id: id)
    }

    /// Removes the Graphic from the scene.
    ///
    /// - localizationKey: Graphic.remove()
    public func remove() {
        SceneProxy().removeGraphic(id: id)
    }
    
    /// Moves the Graphic by *x* and/or *y*, animated over a duration in seconds.
    ///
    /// - Parameter x: The distance to move along the x-axis.
    /// - Parameter y: The distance to move along the y-axis.
    /// - Parameter duration: The time over which the Graphic moves.
    ///
    /// - localizationKey: Graphic.moveBy(x:y:duration:)
    public func moveBy(x: Double, y: Double, duration: Double) {
        
        let vector = CGVector(dx: CGFloat(x), dy: CGFloat(y))
        let moveAction = SKAction.move(by: vector, duration: duration)
        moveAction.timingMode = .linear
        send(moveAction, withKey: "moveBy")
    }
    
    /// Moves the Graphic to a position, animated over a duration in seconds.
    ///
    /// - Parameter to: The point on the *x* and *y* axis where the Graphic moves to.
    /// - Parameter duration: The time over which the Graphic moves.
    ///
    /// - localizationKey: Graphic.move(to:duration:)
    public func move(to: Point, duration: Double) {
        
        let moveAction = SKAction.move(to: CGPoint(to), duration: duration)
        moveAction.timingMode = .linear
        send(moveAction, withKey: "moveTo")
    }
    
    /// Rotates the Graphic by a specified angle over a duration in seconds.
    ///
    /// - Parameter angle: The angle in which to rotate.
    /// - Parameter duration: The time over which to rotate.
    ///
    /// - localizationKey: Graphic.rotate(byAngle:duration:)
    public func rotate(byAngle angle: Double, duration: Double) {
        let rotateAction = SKAction.rotate(byAngle: CGFloat(angle * Double.pi / 180), duration: duration)
        send(rotateAction, withKey: "rotateBy")
    }
    
    /// Rotates the Graphic to a specified angle over a duration in seconds.
    ///
    /// - Parameter angle: The angle in which to rotate.
    /// - Parameter duration: The time over which to rotate.
    ///
    /// - localizationKey: Graphic.rotate(toAngle:duration:)
    public func rotate(toAngle angle: Double, duration: Double) {
        let rotateAction = SKAction.rotate(toAngle: CGFloat(angle * Double.pi / 180), duration: duration)
        send(rotateAction)
    }
    
    /// Scales the Graphic to a specified value over a given number of seconds.
    ///
    /// - Parameter to: The scale that the Graphic changes to.
    /// - Parameter duration: The time over which the Graphic scales.
    ///
    /// - localizationKey: Graphic.scale(to:duration:)
    public func scale(to: Double, duration: Double) {
        
        guard !suppressMessageSending else { return }
        let scaleAction = SKAction.scale(to: CGFloat(to), duration: duration)
        scaleAction.timingMode = .easeInEaseOut
        send(scaleAction, withKey: "scaleTo")
    }
    
    /// Scales the graphic by a relative value over a given number of seconds.
    ///
    /// - Parameter value: The amount to add to the Graphic’s *x* and *y* scale values.
    /// - Parameter duration: The time over which the Graphic scales.
    ///
    /// - localizationKey: Graphic.scale(by:duration:)
    public func scale(by value: Double, duration: Double) {
        guard !suppressMessageSending else { return }
        let scaleAction = SKAction.scale(by: CGFloat(value), duration: duration)
        send(scaleAction, withKey: "scaleBy")
    }
    
    /// Creates an action that adds relative values to the *x* and *y* scale values of a Graphic.
    ///
    /// - Parameter xScale: The amount to add to the Graphic’s *x* scale value.
    /// - Parameter yScale: The amount to add to the Graphic’s *y* scale value.
    /// - Parameter duration: The time over which the Graphic scales.
    ///
    /// - localizationKey: Graphic.scaleX(by:y:duration:)
    public func scaleX(by xScale: Double, y yScale: Double, duration: Double) {
        guard !suppressMessageSending else { return }
        let scaleAction = SKAction.scaleX(by: CGFloat(xScale), y: CGFloat(yScale), duration: duration)
        send(scaleAction)
    }
    
    /// Creates an action that changes the *x* and *y* scale values of a Graphic.
    ///
    /// - Parameter xScale: The new value for the Graphic’s *x* scale value.
    /// - Parameter yScale: The new value for the Graphic’s *y* scale value.
    /// - Parameter duration: The time over which the Graphic scales.
    ///
    /// - localizationKey: Graphic.scaleX(to:y:duration:)
    public func scaleX(to xScale: Double, y yScale: Double, duration: Double) {
        let scaleAction = SKAction.scaleX(to: CGFloat(xScale), y: CGFloat(yScale), duration: duration)
        send(scaleAction)
    }
    
    /// Animates the Graphic to fade out after a given number of seconds.
    ///
    /// - Parameter after: The time in seconds to fade out the Graphic.
    ///
    /// - localizationKey: Graphic.fadeOut(after:)
    public func fadeOut(after seconds: Double) {
        SceneProxy().runAction(id: id, action: .fadeOut(withDuration: seconds), name: "fadeOut")
        
    }
    
    /// Animates the Graphic to fade in over the given number of seconds.
    ///
    /// - Parameter after: The time in seconds to fade in the Graphic.
    ///
    /// - localizationKey: Graphic.fadeIn(after:)
    public func fadeIn(after seconds: Double) {
        SceneProxy().runAction(id: id, action: .fadeIn(withDuration: seconds), name: "fadeIn")
        
    }
    
    /// Creates an action that adjusts the alpha value of a Graphic to a new value.
    ///
    /// - Parameter value: The new value of the Graphic’s alpha.
    /// - Parameter duration: The duration of the animation.
    ///
    /// - localizationKey: Graphic.fadeAlpha(to:duration:)
    public func fadeAlpha(to value: Double, duration: Double) {
        let fadeAlphaAction = SKAction.fadeAlpha(to: CGFloat(value), duration: duration)
        SceneProxy().runAction(id: id, action: fadeAlphaAction, name: "fadeTo")
    }
    
    /// Creates an action that adjusts the alpha value of a Graphic by a certain value.
    ///
    /// - Parameter value: The new value of the Graphic’s alpha.
    /// - Parameter duration: The duration of the animation.
    ///
    /// - localizationKey: Graphic.fadeAlpha(by:duration:)
    public func fadeAlpha(by value: Double, duration: Double) {
        let fadeAlphaAction = SKAction.fadeAlpha(by: CGFloat(value) ,duration: duration)
        SceneProxy().runAction(id: id, action: fadeAlphaAction, name: "fadeTo")
    }
    
    /// Moves the Graphic around the center point in an elliptical orbit. The direction of rotation is chosen at random.
    ///
    /// - Parameter x: The distance of the orbital path from the center along the x-axis.
    /// - Parameter y: The distance of the orbital path from the center along the y-axis.
    /// - Parameter period: The period of the orbit in seconds.
    ///
    /// - localizationKey: Graphic.orbit(x:y:period:)
    public func orbit(x: Double, y: Double, period: Double = 4.0) {
        let orbitAction = SKAction.orbit(x: CGFloat(x), y: CGFloat(y), period: period)
        send(orbitAction, withKey: "orbit")

    }
    
    /// Rotates the Graphic continuously, with a given period of rotation.
    ///
    /// - Parameter period: The period of each rotation in seconds.
    ///
    /// - localizationKey: Graphic.spin(period:)
    public func spin(period: Double = 2.0) {
        
        SceneProxy().runAction(id: id, action: .spin(period: period), name: "spin")
    }
    
    /// Pulsates the Graphic by increasing and decreasing its scale a given number of times, or indefinitely.
    ///
    /// - Parameter period: The period of each pulsation in seconds.
    /// - Parameter count: The number of pulsations; the default (`-1`) is to pulsate indefinitely.
    ///
    /// - localizationKey: Graphic.pulsate(period:count:)
    public func pulsate(period: Double = 5.0, count: Int = -1) {
        send(.pulsate(period: period, count: count), withKey: "pulsate")
    }
    
    /// Animates the Graphic by shaking it for the given number of seconds.
    ///
    /// - Parameter duration: The time in seconds to shake the Graphic.
    ///
    /// - localizationKey: Graphic.shake(duration:)
    public func shake(duration: Double = 2.0) {

        SceneProxy().runAction(id: id, action: .shake(duration: duration), name: "shake")
    }
    
    
    /// Runs an animation on the given sprite, which consists of an array of images, and the animation’s time per frame.
    ///
    /// - Parameter images: An array of images that composes the animation sequence.
    /// - Parameter timePerFrame: The amount of time between images in the animation sequence.
    /// - Parameter numberOfTimes: The number of times to repeat the animation. Setting this value to `-1` repeats the animation indefinitely.
    ///
    /// - localizationKey: Graphic.runAnimation(images:timePerFrame:numberOfTimes:)
    func runAnimation(fromImages images: [Image], timePerFrame: Double, numberOfTimes: Int = 1) {
        var names: [String] = []
        for image in images {
            names.append(image.path)
        }
        SceneProxy().runCustomAnimation(id: id, animationSequence: names, duration: timePerFrame, numberOfTimes: numberOfTimes)
    }
    
    /// Runs an animation on the given graphic.
    ///
    /// - Parameter animation: An enum specifying the animation to run.
    /// - Parameter timePerFrame: The amount of time between images in the animation sequence.
    /// - Parameter numberOfTimes: The number of times to repeat the animation. Setting this value to `-1` will repeat the animation indefinitely.
    ///
    ///- localizationKey: Graphic.runAnimation(_:timePerFrame:numberOfTimes:)
    open func runAnimation(_ animation: String, timePerFrame: Double, numberOfTimes: Int = 1) {
        SceneProxy().runAnimation(id: id, animation: animation, duration: timePerFrame, numberOfTimes: numberOfTimes)
    }
    
    // MARK: Audio
    
    /// Adds a sound to the graphic.
    ///
    /// - Parameter sound: The sound to add.
    /// - Parameter positional: Whether the sound changes based on the position of the graphic. The default is `true`.
    /// - Parameter looping: Whether the sound should loop. The default is `true`.
    /// - Parameter volume: The volume at which the sound is played (ranging from `0` to `100`). The default is `100`: full volume.
    ///
    /// - localizationKey: Graphic.addAudio(_:positional:looping:volume:)
    public func addAudio(_ sound: Sound, positional: Bool = true, looping: Bool = true, volume: Double = 100) {
        hasAudio = true
        SceneProxy().addAudio(id: id, sound: sound, positional: positional, looping: looping, volume: volume)
    }
    
    /// Removes the sound from the graphic.
    ///
    /// - localizationKey: Graphic.removeAudio()
    public func removeAudio() {
        hasAudio = false
        SceneProxy().removeAudio(id: id)
    }
    
    /// Plays the graphic’s sound.
    ///
    /// - localizationKey: Graphic.playAudio()
    public func playAudio() {
        SceneProxy().playAudio(id: id)
    }
    
    /// Stops playing the graphic’s sound.
    ///
    /// - localizationKey: Graphic.stopAudio()
    public func stopAudio() {
        SceneProxy().stopAudio(id: id)
    }
    
    // MARK: Unavailable
    
    @available(*, unavailable, message: "You need to add the ‘text:’ label when creating a graphic with a string. For example:\n\nlet graphic = Graphic(text: \"My string\")")
    public convenience init(_ text: String) { self.init() }
    
    @available(*, unavailable, message: "You need to add the ‘image:’ label when creating a graphic with an image. For example:\n\nlet graphic = Graphic(image: myImage)")
    public convenience init(_ image: Image) { self.init() }
}


extension Graphic: Hashable, Equatable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }

    public static func ==(lhs: Graphic, rhs: Graphic) -> Bool {
        
        return lhs.id == rhs.id
    }
    
}
