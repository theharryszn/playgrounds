//
//  AuthorizationManager.swift
//  
//  Copyright © 2020 Apple Inc. All rights reserved.
//

import Foundation
import AVFoundation
import Photos

public enum AuthorizableFeature {
    case camera
    case photoLibrary
}

public struct AuthorizationManager {
    
    public static func requestAuthorization(for feature: AuthorizableFeature, waitUntilDone: Bool, completion: @escaping ((_ authorized: Bool) -> Void)) {
        
        var done = false
        
        func wrappedCompletion(authorized: Bool) {
            done = true
            let status = authorized ? "authorized" : "denied"
            PBLog("for \(feature): \(status)")
            completion(authorized)
        }
        
        switch feature {
        case .camera:
            AuthorizationManager.checkCameraAuthorization(completion: wrappedCompletion)
        case .photoLibrary:
            AuthorizationManager.checkPhotoLibraryAuthorization(completion: wrappedCompletion)
        }
        
        if waitUntilDone {
            while !done {
                RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.25))
            }
        }
    }
    
    // Camera authorization
    private static func checkCameraAuthorization(completion: @escaping ((_ authorized: Bool) -> Void)) {
        let authorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        
        switch authorizationStatus {
        case .authorized:
            //The user has previously granted access to the camera.
            completion(true)
        case .notDetermined:
            // The user has not yet been presented with the option to grant video access so request access.
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { success in
                completion(success)
            })
        case .denied:
            // The user has previously denied access.
            completion(false)
        case .restricted:
            // The user doesn't have the authority to request access e.g. parental restriction.
            completion(false)
        @unknown default:
            completion(false)
            fatalError("Unknown AVCaptureDevice.authorizationStatus, \(authorizationStatus)")
        }
    }
    
    public static var hasRequestedCameraAuthorization: Bool {
        switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video) {
        case .authorized, .denied, .restricted:
            return true
        default:
            return false
        }
    }
    
    // Photos Library authorization
    private static func checkPhotoLibraryAuthorization(completion: @escaping ((_ authorized: Bool) -> Void)) {
        let status = PHPhotoLibrary.authorizationStatus()
        if status == PHAuthorizationStatus.authorized {
            // Access has been granted.
            completion(true)
        } else {
            PHPhotoLibrary.requestAuthorization({ newStatus in
                completion(newStatus == PHAuthorizationStatus.authorized)
            })
        }
    }
    
    public static var hasRequestedPhotoLibraryAuthorization: Bool {
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized, .denied, .restricted:
            return true
        default:
            return false
        }
    }
}
