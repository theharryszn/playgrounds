//
//  Difficulty.swift
//  
//  Copyright © 2020 Apple Inc. All rights reserved.
//

import Foundation

/// The difficulty level of the scene, if applicable.
///
/// - localizationKey: Difficulty
public enum Difficulty {
    case lessChallenge
    case medium
    case moreChallenge
}

public var pageDifficulty: Difficulty = Difficulty.medium
