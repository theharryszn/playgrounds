//
//  Button.swift
//  
//  Copyright © 2020 Apple Inc. All rights reserved.
//

import Foundation
import SPCCore

/// An enumeration of the different button shapes: red or green.
///
/// - localizationKey: ButtonType
public enum ButtonType {
    
    /// Red is one of the buttons you can choose from.
    ///
    /// - localizationKey: ButtonType.red
    case red
    
    /// Green is one of the buttons you can choose from.
    ///
    /// - localizationKey: ButtonType.green
    case green
    
    /// A red rectangle is one of the buttons you can choose from.
    ///
    /// - localizationKey: ButtonType.rectangularRed
    case rectangularRed
}

/// A button is a type of graphic. A button can be made from an image or string, and can be placed on the scene.
///
/// - localizationKey: Button
public class Button: Graphic {
    
    fileprivate static var defaultNameCount: Int = 1
    
    /// buttonType is an attribute of Button that identifies the type of button: red or green.
    ///
    /// - localizationKey: buttonType
    public var buttonType: ButtonType = .green
    
    /// The function that gets called when you press a button.
    ///
    /// - localizationKey: Graphic.setOnPressHandler(_:)
    public func setOnPressHandler(_ handler: @escaping (() -> Void)) {
        onTouchHandler = handler
    }
    
    /// Creates a Button with a ButtonType, text, and name.
    /// Example usage:
    ///
    /// `let restart = Button(type: .red, text: \"Try Again\", name: \"restart\")`
    ///
    /// - Parameter type: ButtonType, red or green.
    /// - Parameter text: Any text you want displayed on the button.
    /// - Parameter name: A name associated with the button.
    ///
    /// - localizationKey: Button(type:text:name:)
    public convenience init(type: ButtonType, text: String = "", name: String = "") {
        
        var image: Image = Image(imageLiteralResourceName: "button")
        
        switch type {
        case .red:
                image = Image(imageLiteralResourceName: "button_red")
        case .green:
                image = Image(imageLiteralResourceName: "button_green")
        case .rectangularRed:
            image = Image(imageLiteralResourceName: "button_redRectangular")
        }
    
        if name == "" {
            self.init(graphicType: .button, name: "button" + String(Button.defaultNameCount))
            Button.defaultNameCount += 1
        } else {
            self.init(graphicType: .button, name: name)
        }
        self.image = image
        self.buttonType = type
        self.text = text
        
        SceneProxy().setFontSize(id: id, size: Int(fontSize))
        SceneProxy().setFontName(id: id, name: font.rawValue)
        SceneProxy().setTextColor(id: id, color: textColor)
        SceneProxy().setText(id: id, text: text)
    }
    
    // Provide overrides for Graphic properties relating to text
    
    /// The font used to render the text.
    ///
    /// - localizationKey: Button.font
    public override var font: Font {
        get { return super.font }
        set { super.font = newValue }
    }
    
    /// How big the text is.
    ///
    /// - localizationKey: Button.fontSize
    public override var fontSize: Double {
        get { return super.fontSize }
        set { super.fontSize = newValue }
    }
    
    /// The text (if any) that’s displayed by the Graphic. Setting a new text updates the display.
    ///
    /// - localizationKey: Button.text
    public override var text: String {
        get { return super.text }
        set { super.text = newValue }
    }
    
    /// The color for the text of the Graphic.
    ///
    /// - localizationKey: Button.textColor
    public override var textColor: Color {
        get { return super.textColor }
        set { super.textColor = newValue }
    }
    
    // Make certain initializers unavailable
    
    @available(*, unavailable, message: "Buttons may not be initialized with the `shape:color:gradientColor:name:` initializer.") public convenience init(shape: Shape, color: Color, gradientColor: Color? = nil, name: String = "") {
        // Do nothing
        self.init(graphicType: .graphic, name: name)
    }
    
@available(*, unavailable, message: "setOnTouchHandler is replaced by setOnPressHandler for the Button type.") public override func setOnTouchHandler(_ handler: @escaping (() -> Void)) {
        // Do nothing
    }
    
    @available(*, unavailable, message: "Buttons may not be initialized with the `image:name:` initializer.") public convenience init(image: Image, name: String = "") {
        // Do nothing
        self.init(graphicType: .graphic, name: name)
    }
    
}
