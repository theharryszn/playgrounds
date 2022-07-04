//
//  LiveViewExtensionHost.swift
//  
//  Copyright © 2020 Apple Inc. All rights reserved.
//

import UIKit
import AVFoundation

public protocol LiveViewRegistering {
    static func liveViewRegistration()
}

protocol LiveViewExtensionHostDelegate: class {
    func liveViewExtensionHostDidEnterBackground()
    func liveViewExtensionHostWillEnterForeground()
}

class LiveViewExtensionHost {
    
    static let current = LiveViewExtensionHost()
    
    weak var delegate: LiveViewExtensionHostDelegate?
    
    // Marks if the extension is currently in the background.
    private(set) var isInBackground = false
    
    private var notificationObservers = [Any]()

    init() {
        let notificationCenter = NotificationCenter.default
        
        // Register for extension notifications.
        let didEnterBackground = notificationCenter.addObserver(forName: .NSExtensionHostDidEnterBackground, object: nil, queue: .main) { [weak self] _ in
            self?.isInBackground = true
            
            PBLog("NSExtensionHostDidEnterBackground")
            
            self?.delegate?.liveViewExtensionHostDidEnterBackground()
        }
        
        let willEnterForeground = notificationCenter.addObserver(forName: .NSExtensionHostWillEnterForeground, object: nil, queue: .main) { [weak self] _ in
            self?.isInBackground = false
            
            PBLog("NSExtensionHostWillEnterForeground")
            
            self?.delegate?.liveViewExtensionHostWillEnterForeground()
        }
        
        notificationObservers = [didEnterBackground, willEnterForeground]
    }
    
    deinit {
        for observer in notificationObservers {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
