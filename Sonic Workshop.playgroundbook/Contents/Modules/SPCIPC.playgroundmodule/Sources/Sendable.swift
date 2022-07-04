//
//  Sendable.swift
//  
//  Copyright © 2020 Apple Inc. All rights reserved.
//

import Foundation
import UIKit

public protocol Sendable: Codable {
    func encodePayload() -> Data
}

extension Sendable {
    public func encodePayload() -> Data {
        let encoder = JSONEncoder()
        return try! encoder.encode(self)
    }
}
