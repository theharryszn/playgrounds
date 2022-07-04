//
//  Messagable.swift
//  
//  Copyright © 2020 Apple Inc. All rights reserved.
//

import Foundation

public protocol Messagable: Codable {
    static func decode(data: Data, withId id: String)
}
