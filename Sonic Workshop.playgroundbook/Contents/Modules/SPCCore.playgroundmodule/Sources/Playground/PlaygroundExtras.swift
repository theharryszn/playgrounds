//
//  PlaygroundExtras.swift
//  
//  Copyright © 2020 Apple Inc. All rights reserved.
//

import Foundation
import os.log

public enum Environment: String, Codable {
    case live
    case user
}

public struct Process: Codable {
    public private(set) static var environment: Environment = .live
    
    public static var isLive: Bool { return environment == .live }
    public static func setIsLive() { environment = .live }
    public static var isUser: Bool { return environment == .user }
    public static func setIsUser() { environment = .user }
    
    public static var isLiveViewConnectionOpen = false
}

// MARK: Logging

private var logCounter = 0

public func PBLog(_ message: String = "", source: String = #file, caller: String = #function) {
    let processId = Process.isLive ? "LVP" : "UP"
    
    let fileName = URL(string: source)?.lastPathComponent ?? ""
    
    let prefixedString = "PBLog: <#\(logCounter): \(processId)>-\(fileName)-\(caller) " + message
    NSLog(prefixedString)
    
    logCounter += 1
}

// MARK: Signposts

public struct Signpost {
    
    public let name: StaticString
    public let id: OSSignpostID
    
    public static let liveViewFirstRunnableCode = Signpost("LiveViewFirstRunnableCode")
    public static let liveViewControllerInitialize = Signpost("LiveViewControllerInitialize")
    public static let liveViewControllerViewDidLoad = Signpost("LiveViewControllerViewDidLoad")
    public static let liveViewControllerViewWillAppear = Signpost("LiveViewControllerViewWillAppear")
    public static let liveViewUserConnectionOpened = Signpost("LiveViewUserConnectionOpened")
    public static let liveViewUserConnectionClosed = Signpost("LiveViewUserConnectionClosed")
    public static let liveViewMessageSent = Signpost("LiveViewMessageSent")
    public static let liveViewMessageReceived = Signpost("LiveViewMessageReceived")
    public static let liveViewLastRunnableCode = Signpost("LiveViewLastRunnableCode")
    
    public static let userProcessFirstRunnableCode = Signpost("UserProcessFirstRunnableCode")
    public static let userProcessMessageSent = Signpost("UserProcessMessageSent")
    public static let userProcessMessageReceived = Signpost("UserProcessMessageReceived")
    public static let userProcessLastRunnableCode = Signpost("UserProcessLastRunnableCode")
    
    private static let osLog = OSLog(subsystem: "com.apple.playgroundscontent", category: "SPCCore.Signpost")
    
    public init (_ inName: StaticString) {
        name = inName
        id = OSSignpostID(log: Signpost.osLog)
    }

    public func event() {
        os_signpost(.event, log: Signpost.osLog, name: name, signpostID: id)
    }
    
    public func begin() {
        event()
        
        os_signpost(.begin, log: Signpost.osLog, name: name, signpostID: id)
    }
    
    public func end() {
        os_signpost(.end, log: Signpost.osLog, name: name, signpostID: id)
    }
}


