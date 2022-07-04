//
//  Message.swift
//  
//  Copyright © 2020 Apple Inc. All rights reserved.
//
import Foundation
import UIKit
import PlaygroundSupport
import SPCCore

public class Message {
    
    // Set to true in situations where the sender and receiver are the same: messages don’t need to be passed via IPC.
    // For example, when 'user code' and the live view are both running in the same process.
    public static var isLiveViewOnly: Bool = false
    
    static var proxyNameToProxyType = [String: Messagable.Type]()
    public static var messagesAwaitingSend = [(Message, String)]()
    public static var waitingForTouchAcknowledegment: Bool = false
    public static var shouldWaitForTouchAcknowledgement: Bool = false
    public static let current = Message()
    private static var loaded = false
    private static let messageEnqueingQueue = DispatchQueue(label: "com.apple.MessageEnqueuingQueue")
    var encodedPayload: Data
    var playgroundValue: PlaygroundValue
    
    public init (with payload: Sendable, payloadName: String, proxyName: String) {
        self.encodedPayload = payload.encodePayload()
        playgroundValue = .array([.string(proxyName), .string(payloadName), .data(encodedPayload)])
    }
    
    private init() {
        encodedPayload = Data()
        playgroundValue = .string("")
    }
    
    static public func registerToReceiveData(as object: Messagable.Type) {
        let typeName = String(describing: type(of: object))
        let splitLine = typeName.split(separator: ".")
        let key = String(splitLine[0])
        proxyNameToProxyType[key] = object
        
        //setting current as the message delegate
        if !loaded {
            loaded = true
            let page = PlaygroundPage.current
            page.needsIndefiniteExecution = true
            let proxy = page.liveView as? PlaygroundRemoteLiveViewProxy
            proxy?.delegate = current
        }
    }
    
    static func getReceiverProcess() -> Environment {
        if PlaygroundPage.current.liveView is PlaygroundRemoteLiveViewProxy {
            return .live //a proxy means this message is being sent from the user process to the live view
        }
        else {
            return .user //no proxy means this message is being send from the live view to the user process
        }
    }
    
    static public func send(_ thing: Sendable, payload: Any.Type, proxy: AnyClass) {
        let temp = String(describing: payload)
        let splitLine = temp.split(separator: ".")
        let payloadName = splitLine[0]
        let message = Message(with: thing, payloadName: String(payloadName), proxyName: String(describing: proxy))
        let destination = Message.getReceiverProcess()
        
        if isLiveViewOnly {
            // Receive the message directly.
            self.receive(message.encodedPayload, payloadName: String(payloadName), withType: String(describing: proxy))
        } else {
            if destination == .user {
                // Queue the message for sending.
                enqueue(message, payloadName: String(describing: payload))
             }
             else  {
                // Send the message.
                 message.playgroundSend()
             }
        }
    }
    
    static public func receive(_ data: Data, payloadName: String, withType type: String) {
        if let proxyType = proxyNameToProxyType[type] {
            proxyType.decode(data: data, withId: payloadName)
        } else {
        }
    }
    
    static func enqueue(_ message: Message, payloadName: String) {
        messageEnqueingQueue.async {
            guard shouldWaitForTouchAcknowledgement else {
                message.playgroundSend()
                return
            }
            if waitingForTouchAcknowledegment {
                messagesAwaitingSend.insert((message, payloadName), at: 0)
                return
            }
            message.playgroundSend()
        }
    }
    
    public func playgroundSend() {
        // If the live view conforms to PlaygroundLiveViewMessageHandler, call its send() method.
        guard let liveViewMessageHandler = PlaygroundPage.current.liveView as? PlaygroundLiveViewMessageHandler else {
            assertionFailure("*** Unable to cast \(String(describing: PlaygroundPage.current.liveView)) as PlaygroundLiveViewMessageHandler ***")
            return
        }
        
        switch Message.getReceiverProcess() {
            case .user:
                Signpost.liveViewMessageSent.event()
            case .live:
                Signpost.userProcessMessageSent.event()
        }
        
        liveViewMessageHandler.send(self.playgroundValue)
    }
}

extension Message: PlaygroundRemoteLiveViewProxyDelegate {
    
    public func remoteLiveViewProxyConnectionClosed(_ remoteLiveViewProxy: PlaygroundRemoteLiveViewProxy) {
        Message.messagesAwaitingSend.removeAll()
        Message.waitingForTouchAcknowledegment = false
    }
    
    public func remoteLiveViewProxy(_ remoteLiveViewProxy: PlaygroundRemoteLiveViewProxy, received message: PlaygroundValue) {
        
        switch Message.getReceiverProcess() {
            case .live:
                Signpost.liveViewMessageReceived.event()
            case .user:
                Signpost.userProcessMessageReceived.event()
        }
        
        guard case let .array(arr) = message else { fatalError("Message must carry a payload") }
        guard case let .string(proxyName) = arr[0] else { fatalError("Message must carry the name of the associated proxy") }
        guard case let .string(payloadName) = arr[1] else { fatalError("Message must carry the name of it's payload") }
        guard case let .data(payload) = arr[2] else { fatalError("Message must carry a payload")}
        
        Message.receive(payload, payloadName: payloadName, withType: proxyName)
    }
}
