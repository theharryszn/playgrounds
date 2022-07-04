//
//  AccessibilityProxy.swift
//  
//  Copyright © 2020 Apple Inc. All rights reserved.
//

import Foundation
import SPCCore
import SPCIPC

public protocol AccessibilityProxyProtocol {
    func setAccessibilityHints(id: String, hints: AccessibilityHints?)
}

public class AccessibilityProxy: AccessibilityProxyProtocol, Messagable, LiveViewRegistering {
    static var receivers = [AccessibilityProxyProtocol]()
    
    public static func registerToRecieveDecodedMessage(as object: AccessibilityProxyProtocol) {
        receivers.append(object)
    }
    
    public static func liveViewRegistration() {
        Message.registerToReceiveData(as: self)
    }
    
    public init() {}
    
    public func setAccessibilityHints(id: String, hints: AccessibilityHints?) {
        Message.send(SetAccessibilityHints(id: id, hints: hints), payload: type(of: SetAccessibilityHints.self), proxy: type(of: self))
    }
    
    enum MessageType: String {
        case SetAccessibilityHints
    }
    
    public static func decode(data: Data, withId id: String) {
        if let type = MessageType(rawValue: id) {
            switch type {
             case .SetAccessibilityHints:
                if let decoded = try? JSONDecoder().decode(SetAccessibilityHints.self, from: data) {
                    receivers.forEach({$0.setAccessibilityHints(id: decoded.id, hints: decoded.hints)})
                }
            }
        }
    }
}

struct SetAccessibilityHints: Sendable {
    var id: String
    var hints: AccessibilityHints?
}
