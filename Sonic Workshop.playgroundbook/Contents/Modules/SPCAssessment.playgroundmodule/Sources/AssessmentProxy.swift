//
//  AssessmentProxy.swift
//  
//  Copyright © 2020 Apple Inc. All rights reserved.
//

import Foundation
import PlaygroundSupport
import SPCCore
import SPCIPC

public protocol AssessmentUserCodeProxyProtocol {
    func setAssessment(status: PlaygroundPage.AssessmentStatus)
    func trigger(trigger: AssessmentTrigger)
}

public class AssessmentUserCodeProxy: AssessmentUserCodeProxyProtocol, Messagable {
    static var receivers = [AssessmentUserCodeProxyProtocol]()
    
    static func registerToRecieveDecodedMessage(as object: AssessmentUserCodeProxyProtocol) {
        receivers.append(object)
        Message.registerToReceiveData(as: self)
    }
    
    public init() {}
    
    enum MessageType: String {
        case SetAssessment
        case Trigger
    }
    
    public func setAssessment(status: PlaygroundPage.AssessmentStatus) {
        Message.send(SetAssessment(status: status), payload: type(of: SetAssessment.self), proxy: type(of: self))
    }
    
    public func trigger(trigger: AssessmentTrigger) {
        Message.send(Trigger(assessmentTrigger: trigger), payload: type(of: Trigger.self), proxy: type(of: self))
    }
    
    public static func decode(data: Data, withId id: String) {
        if let type = MessageType.init(rawValue: id) {
            switch type {
            case .SetAssessment:
                if let decoded = try? JSONDecoder().decode(SetAssessment.self, from: data) {
                    receivers.forEach({$0.setAssessment(status: decoded.status)})
                }
            case .Trigger:
                if let decoded = try? JSONDecoder().decode(Trigger.self, from: data) {
                    receivers.forEach({$0.trigger(trigger: decoded.trigger)})
                }
            }
        }
    }
}

struct SetAssessment: Sendable {
    private var pass: Bool
    private var message: String?
    private var hints: [String]
    var status: PlaygroundPage.AssessmentStatus {
        get {
            if pass {
                return PlaygroundPage.AssessmentStatus.pass(message: message)
            }
            else {
                return PlaygroundPage.AssessmentStatus.fail(hints: hints, solution: message)
            }
        }
    }
    init(status: PlaygroundPage.AssessmentStatus) {
        switch status {
        case let .pass(success):
            pass = true
            message = success
            hints = []
        case let .fail(failureHints, solution):
            pass = false
            message = solution
            hints = failureHints
        }
    }
}

struct Trigger: Sendable {
    private var type: String
    private var context: Int?
    var trigger: AssessmentTrigger {
        get {
            switch type {
            case "start":
                return .start(context: AssessmentInfo.Context(rawValue: context!)!)
            case "stop":
                return .stop
            case "evaluate":
                return .evaluate
            default:
                fatalError("Message was sent with incorrect type")
            }
        }
    }
    
    init(assessmentTrigger: AssessmentTrigger) {
        type = assessmentTrigger.name
        switch assessmentTrigger {
        case .start(context: let assessmentContext):
            context = assessmentContext.rawValue
        default:
            break
        }
    }
}
