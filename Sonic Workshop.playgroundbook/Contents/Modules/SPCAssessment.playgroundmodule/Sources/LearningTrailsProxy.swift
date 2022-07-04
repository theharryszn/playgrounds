//  Copyright © 2020 Apple Inc. All rights reserved.

import Foundation
import os
import PlaygroundSupport

public class LearningTrailsProxy {
    
    private static let currentTrailKey = "LearningTrails.currentTrail"
    private static let currentStepKey = "LearningTrails.currentStep"
    
    /// The key under which the names of sent messages are saved in the key-value store (per page/trail).
    private var sentMessagesKey: String? {
        guard !currentTrailIdentifier.isEmpty else {
            os_log("LearningTrailsProxy: failed to create sentMessagesKey: missing currentTrailIdentifier.", log: OSLog.default, type: .error)
            return nil
        }
        return "LearningTrailsProxy.SentMessages.\(currentTrailIdentifier)"
    }
    
    public init() { }
    
    /// A persistent array of the messages that have been sent.
    var sentMessages: [String] {
        get {
            guard
                let sentMessagesKey = sentMessagesKey,
                case let .array(playgroundValues)? = PlaygroundKeyValueStore.current[sentMessagesKey]
            else { return [] }
            var messageNames = [String]()
            messageNames = playgroundValues.compactMap { playgroundValue in
                guard case let .string(messageName) = playgroundValue else { return nil }
                return messageName
            }
            return messageNames
        }
        set {
            guard let sentMessagesKey = sentMessagesKey else { return }
            PlaygroundKeyValueStore.current[sentMessagesKey] = .array(newValue.map { PlaygroundValue.string($0) } )
        }
    }
    
    /// Returns a dictionary of key-value pairs for the specified key.
    func getKeyValueStoreInfoFor(key: String) -> [String : String]? {
        guard case let .dictionary(valueDict)? = PlaygroundKeyValueStore.current[key] else { return nil }
        var info = [String : String]()
        if let value = valueDict["Identifier"], case let .string(identifier) = value {
            info["Identifier"] = identifier
        }
        if let value = valueDict["Name"], case let .string(name) = value {
            info["Name"] = name
        }
        return info
    }
    
    /// The name of the current learning trail (as defined in LearningTrail.xml).
    public var currentTrail: String {
        guard
            let trailInfo = getKeyValueStoreInfoFor(key: Self.currentTrailKey),
            let trailName = trailInfo["Name"]
        else { return "" }
        return trailName
    }
    
    /// The identifier of the current trail.
    public var currentTrailIdentifier: String {
        guard
            let trailInfo = getKeyValueStoreInfoFor(key: Self.currentTrailKey),
            let trailIdentifier = trailInfo["Identifier"]
        else { return "" }
        return trailIdentifier
    }
    
    /// The name of the current step (as defined in LearningTrail.xml).
    public var currentStep: String {
        guard
            let stepInfo = getKeyValueStoreInfoFor(key: Self.currentStepKey),
            let stepName = stepInfo["Name"]
        else { return "" }
        return stepName
    }
    
    /// The identifier of the current step.
    public var currentStepIdentifier: String {
        guard
            let stepInfo = getKeyValueStoreInfoFor(key: Self.currentStepKey),
            let stepIdentifier = stepInfo["Identifier"]
        else { return "" }
        return stepIdentifier
    }
    
    /// Sends actions to the learning trail.
    /// - parameter actions: The actions to be sent.
    public func sendActions(_ actions: [String]) {
        PlaygroundPage.current.assessmentStatus = .fail(hints: actions, solution: nil)
    }
    
    /// Sends a message to be displayed in the learning trail.
    /// To send a message defined in LearningTrail.xml just specify its `name`.
    /// To send an ad hoc message specify `name`, `sender`, `content`, and optionally `scope`.
    /// - parameter name: The name of the message to be sent.
    /// - parameter sender: The character the message is to be sent from: byte, blue, hopper or expert.
    /// - parameter scope: The scope of the message: trail, step (the default), or ephemeral.
    /// - parameter content: The content of the message.
    public func sendMessage(_ name: String, sender: String? = nil, scope: String? = nil, content: String? = nil) {
        var action = "learningtrails://sendChatMessage?name=\(name)"
        if let sender = sender, let content = content, let encodedContent = content.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            action += "&sender=\(sender)"
            if let scope = scope {
                action += "&scope=\(scope)"
            }
            action += "&content=\(encodedContent)"
        }
        sendActions([action])
        sentMessages.append(name)
    }
    
    /// Sends a message to be displayed in the learning trail, but will only send the message one time.
    /// To send a message defined in LearningTrail.xml just specify its `name`.
    /// To send an ad hoc message specify `name`, `sender`, `content`, and optionally `scope`.
    /// - parameter name: The name of the message to be sent.
    /// - parameter sender: The character the message is to be sent from: byte, blue, hopper or expert.
    /// - parameter scope: The scope of the message: trail, step (the default), or ephemeral.
    /// - parameter content: The content of the message.
    public func sendMessageOnce(_ name: String, sender: String? = nil, scope: String? = nil, content: String? = nil) {
        guard !hasSentMessage(name) else { return }
        sendMessage(name, sender: sender, content: content)
      }
    
    /// Returns `true` if the specified message has been sent.
    /// - parameter messageName: The name of the message.
    public func hasSentMessage(_ messageName: String) -> Bool {
        return sentMessages.contains(messageName)
    }
    
    /// Sets the assessment status.
    /// - parameter assessmentName: The name of the assessment (as defined in LearningTrail.xml).
    /// - parameter passed: The status of the assessment to be set.
    public func setAssessment(_ assessmentName: String, passed: Bool) {
        let action = "assessment://assessmentPassed?name=\(assessmentName)&passed=\(passed)"
        sendActions([action])
    }
    
    /// Marks a task as completed.
    /// - parameter taskName: The name of the task (as defined in LearningTrail.xml).
    /// - parameter completed: The status of the task to be set.
    public func setTask(_ taskName: String, completed: Bool) {
        let action = "learningtrails://setTaskCompleted?name=\(taskName)&completed=\(completed)"
        sendActions([action])
    }
}
