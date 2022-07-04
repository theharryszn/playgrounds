//
//  Sound.swift
//  
//  Copyright © 2020 Apple Inc. All rights reserved.
//

import Foundation

/// The base protocol for sound support.
///
/// - localizationKey: Sound
public typealias Sound = String

/// The base protocol for Music support.
///
/// - localizationKey: Music
public typealias Music = String

public extension String {
    var url : URL? {
        var resourceURL = Bundle.main.url(forResource: self, withExtension: "m4a")
        
        #if DEBUG
        if resourceURL == nil {
            for framework in Bundle.allFrameworks {
                resourceURL = framework.url(forResource: self, withExtension: "m4a")
                
                if resourceURL != nil {
                    break
                }
            }
        }
        #endif
        
        return resourceURL
    }
}
