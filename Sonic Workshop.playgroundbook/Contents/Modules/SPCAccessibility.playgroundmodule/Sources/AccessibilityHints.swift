//
//  AccessibilityHints.swift
//  
//  Copyright © 2020 Apple Inc. All rights reserved.
//

/// An enumeration of types of accessibility actions, including: touch, doubleTouch, drag, or no action.
///
/// - localizationKey: AccessibilityAction
public enum AccessibilityAction : Int, Codable {
    case touch
    case doubleTouch
    case drag
    case noAction
}

/// Accessibility attributes associated with a specifc graphic (or graphics).
///
/// - localizationKey: AccessibilityHints
public struct AccessibilityHints : Codable {
    /// Indicates whether a graphic should be treated as a UIAccessibilityElement by VoiceOver.
    ///
    /// - localizationKey: AccessibilityHints.makeAccessibilityElement
    public var makeAccessibilityElement: Bool = false
    
    /// Label spoken by VoiceOver for the accessible graphic (a localized character name).
    ///
    /// - localizationKey: AccessibilityHints.accessibilityLabel
    public var accessibilityLabel: String?
    
    /// The set of VoiceOver rotor actions associated with the accessibility element.
    ///
    /// - localizationKey: AccessibilityHints.actions
    public var actions: [AccessibilityAction] = [.noAction]
    
    /// Indicates that the live view should select the graphic in VoiceOver immediately when placed in the scene.
    ///
    /// - localizationKey: AccessibilityHints.selectImmediately
    public var selectImmediately: Bool = false
    
    /// The accessibility element has a value which updates over time (a countdown clock).
    ///
    /// - localizationKey: AccessibilityHints.needsUpdatedValue
    public var needsUpdatedValue: Bool = false
    
    /// Identifier indicating a set of graphics to be represented as a single accessible element.
    ///
    /// - localizationKey: AccessibilityHints.groupID
    public var groupID: String?
    
    public init(makeAccessibilityElement: Bool = false,
                accessibilityLabel: String? = nil,
                actions: [AccessibilityAction] = [.noAction],
                selectImmediately: Bool = false,
                needsUpdatedValue: Bool = false,
                groupID:String? = nil) {
        self.makeAccessibilityElement = makeAccessibilityElement
        self.accessibilityLabel = accessibilityLabel
        self.actions = actions
        self.selectImmediately = selectImmediately
        self.needsUpdatedValue = needsUpdatedValue
        self.groupID = groupID
    }
}
