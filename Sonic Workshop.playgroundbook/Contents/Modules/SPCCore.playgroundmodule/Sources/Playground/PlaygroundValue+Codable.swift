//
//  PlaygroundValue+Codable.swift
//  
//  Copyright © 2020 Apple Inc. All rights reserved.
//

import Foundation
import PlaygroundSupport

extension PlaygroundValue: Codable {
    
    public enum CodingKeys: String, CodingKey {
        case array, dictionary, string, data, date, integer, floatingPoint, boolean
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self = .integer(0)
        if container.contains(CodingKeys.array) {
            self = .array(try container.decode([PlaygroundValue].self, forKey: CodingKeys.array))
        } else if container.contains(CodingKeys.dictionary) {
            self = .dictionary(try container.decode([String : PlaygroundValue].self, forKey: CodingKeys.dictionary))
        } else if container.contains(CodingKeys.string) {
            self = .string(try container.decode(String.self, forKey: CodingKeys.string))
        } else if container.contains(CodingKeys.data) {
            self = .data(try container.decode(Data.self, forKey: CodingKeys.data))
        } else if container.contains(CodingKeys.date) {
            self = .date(try container.decode(Date.self, forKey: CodingKeys.date))
        } else if container.contains(CodingKeys.integer) {
            self = .integer(try container.decode(Int.self, forKey: CodingKeys.integer))
        } else if container.contains(CodingKeys.floatingPoint) {
            self = .floatingPoint(try container.decode(Double.self, forKey: CodingKeys.floatingPoint))
        } else if container.contains(CodingKeys.boolean) {
            self = .boolean(try container.decode(Bool.self, forKey: CodingKeys.boolean))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .array(array):
            try container.encode(array, forKey: CodingKeys.array)
        case let .dictionary(dictionary):
            try container.encode(dictionary, forKey: CodingKeys.dictionary)
        case let .string(string):
            try container.encode(string, forKey: CodingKeys.string)
        case let .data(data):
            try container.encode(data, forKey: CodingKeys.data)
        case let .date(date):
            try container.encode(date, forKey: CodingKeys.date)
        case let .integer(integerValue):
            try container.encode(integerValue, forKey: CodingKeys.integer)
        case let .floatingPoint(floatingPointValue):
            try container.encode(floatingPointValue, forKey: CodingKeys.floatingPoint)
        case let .boolean(booleanValue):
            try container.encode(booleanValue, forKey: CodingKeys.boolean)
        }
    }
}
