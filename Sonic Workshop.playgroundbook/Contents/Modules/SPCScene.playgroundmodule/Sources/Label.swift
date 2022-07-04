//
//  Label.swift
//  
//  Copyright © 2020 Apple Inc. All rights reserved.
//

import Foundation
import SPCCore

/// A Label is a type of Graphic that displays text. The Label’s color, name, font, and size can be customized.
///
/// Example usage:
/// ```
/// var scoreLabel = Label(text:\"SCORE: 0\", color: .black, name: \"score\", font: Font.Menlo, size: 70)
/// ```
/// - localizationKey: Label
open class Label: Graphic {
    
    fileprivate static var defaultNameCount = 1
    
    /// Creates a Label with a specified text, color, name, font, and size.
    /// Example usage:
    /// ```
    /// var scoreLabel = Label(text:\"SCORE: 0\", color: .black, name: \"score\", font: Font.Menlo, size: 70)
    /// ```
    /// - Parameter text: The text displayed on the label.
    /// - Parameter color: The color of the text.
    /// - Parameter name: A name you give to the label.
    /// - Parameter font: The font you choose for the text.
    /// - Parameter size: The size of the text.
    ///
    /// - localizationKey: Label(text:color:name:font:size:)
    public convenience init(text: String, color: Color, font: Font = Font.SystemFontRegular, size: Int = 30, name: String = "") {
        
        if name == "" {
            self.init(graphicType: .label, name: "label" + String(Label.defaultNameCount))
            Label.defaultNameCount += 1
        } else {
            self.init(graphicType: .label, name: name)
        }
        textColor = color
        self.text = text
        SceneProxy().setFontSize(id: id, size: size)
        SceneProxy().setFontName(id: id, name: font.rawValue)
        SceneProxy().setTextColor(id: id, color: textColor)
        SceneProxy().setText(id: id, text: text)
    }
    
    // Provide overrides for Graphic properties relating to text
    
    /// The font used to render the text.
    ///
    /// - localizationKey: Graphic.font
    public override var font: Font {
        get { return super.font }
        set { super.font = newValue }
    }
    
    /// How big the text is.
    ///
    /// - localizationKey: Graphic.fontSize
    public override var fontSize: Double {
        get { return super.fontSize }
        set { super.fontSize = newValue }
    }
    
    /// The text (if any) that’s displayed by the Graphic. Setting a new text updates the display.
    ///
    /// - localizationKey: Graphic.text
    public override var text: String {
        get { return super.text }
        set { super.text = newValue }
    }
    
    /// The color for the text of the Graphic.
    ///
    /// - localizationKey: Graphic.textColor
    public override var textColor: Color {
        get { return super.textColor }
        set { super.textColor = newValue }
    }
    
    // Make certain initializers unavailable
    
    @available(*, unavailable, message: "Labels may not be initialized with the `shape:color:gradientColor:name:` initializer.") public convenience init(shape: Shape, color: Color, gradientColor: Color? = nil, name: String = "") {
        // Do nothing
        self.init(graphicType: .graphic, name: name)
    }
    
    @available(*, unavailable, message: "Labels may not be initialized with the `image:name:` initializer.") public convenience init(image: Image, name: String = "") {
        // Do nothing
        self.init(graphicType: .graphic, name: name)
    }
}
