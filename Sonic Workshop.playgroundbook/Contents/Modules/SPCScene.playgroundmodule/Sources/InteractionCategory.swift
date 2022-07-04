//
//  InteractionCategory.swift
//  
//  Copyright © 2020 Apple Inc. All rights reserved.
//

import Foundation

/// An option set that defines the different categories of sprites.
/// Use these categories to specify which sprites can interact with each other in a scene.
///
/// To use the interaction categories, create an extension that defines the different
/// categories of items used in your app.
///
///`extension InteractionCategory {
///`static let ball = InteractionCategory(rawValue: 0b0001)
///`static let block = InteractionCategory(rawValue: 0b0010)
///`static let paddle = InteractionCategory(rawValue: 0b0100)
///`static let inactive = InteractionCategory(rawValue: 0b1000)
///`static let active: InteractionCategory = [ball, block, paddle]
///`}
///
/// - localizationKey: InteractionCategory
public struct InteractionCategory: OptionSet, Codable {
    public let rawValue: UInt32
    
    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
    
    /// A value that matches all possible categories.
    ///
    /// - localizationKey: InteractionCategory.all
    public static let all = InteractionCategory(rawValue: 0xFFFFFFFF)
    
}
