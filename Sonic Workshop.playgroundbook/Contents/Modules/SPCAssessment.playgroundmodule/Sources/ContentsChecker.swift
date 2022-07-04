//
//  ContentsChecker.swift
//  
//  Copyright © 2020 Apple Inc. All rights reserved.
//

import Foundation

/**:
 This does not analyze the code execution. It only makes statements about 
 the static nature of the contents.
 */
public class ContentsChecker {
    let contents: String
    let nodes: [Node]
    
    public let numberOfStatements: Int
    
    public init(contents: String) {
        self.contents = contents
        
        let tokens = TokenGenerator(content: contents).reduce([]) { tokens, currentToken in
            return tokens + [currentToken]
        }
        
        let parser = SimpleParser(tokens: tokens)
        
        let nodes: [Node]
        do {
            nodes = try parser.createNodes()
        }
        catch {
            nodes = []
        }
        
        self.nodes = nodes
        
        numberOfStatements = nodes.reduce(0) { $0 + $1.lineCount }
    }
    
    func nodesOfType<T: Node>(_ type: T.Type) -> [T] {
        return nodes.flatMap { node -> [T] in
            var subNodes = [node]
            if let statement = node as? Statement {
                 subNodes += statement.flattenedBodyNodes
            }
            
            return subNodes.compactMap { $0 as? T }
        }
    }

    
    public lazy var definitionNodes: [DefinitionNode] = self.nodesOfType(DefinitionNode.self)
    public lazy var callNodes: [CallNode] = self.nodesOfType(CallNode.self)
    public lazy var loopNodes: [LoopNode] = self.nodesOfType(LoopNode.self)
    public lazy var conditionalNodes: [ConditionalStatementNode] = self.nodesOfType(ConditionalStatementNode.self)
    public lazy var variableNodes : [VariableNode] = self.nodesOfType(VariableNode.self)

    /// The names of the custom functions defined in the contents.
    public var customFunctions: [String] {
        return definitionNodes.map {
            $0.name
        }
    }
    
    public var passedArguments: [String] {
        return callNodes.map {
            $0.arguments
        }
    }
    
    public func passedArguments(forCall name: String) -> [String] {
        let functions = callNodes.filter {
            $0.identifier == name
        }
        return functions.map {
            $0.arguments
        }
    }
    
    /// The names of the functions that were called.
    public var calledFunctions: [String] {
        return callNodes.map {
            $0.identifier
        }
    }
    
    public var accessedVariables: [String] {
        return variableNodes.map {
            $0.identifier
        }
    }
    
    public var hasForLoop: Bool {
        return loopNodes.contains {
            $0.type == .for
        }
    }
    
    public var hasWhileLoop: Bool {
        return loopNodes.contains {
            $0.type == .while
        }
    }
    
    public var hasConditionalStatement: Bool {
        return !conditionalNodes.isEmpty
    }
    
    public func hasConditionalStatement(_ name: String) -> Bool {
        guard let word = Keyword(rawValue: name) else { return false }
        return conditionalNodes.contains {
            $0.type == word
        }
    }
    
    /// Returns `true` if a function was defined and then contains a call to 
    /// the function at least once.
    public func calledCustomFunction() -> Bool {
        return customFunctions.contains {
            functionCallCount(forName: $0) > 0
        }
    }
    
    public func functionCallCount(forName name: String) -> Int {
        return callNodes.filter {
            $0.identifier == name
        }.count
    }
    
    public func functionCallCount(containing string: String) -> Int {
        return callNodes.filter {
            $0.identifier.contains(string)
        }.count
    }
    
    public func variableAccessCount(forName name: String) -> Int {
        return variableNodes.filter {
            $0.identifier == name
        }.count
    }
    
    public func variableAccessCount(containing string: String) -> Int {
        return variableNodes.filter {
            $0.identifier.contains(string)
        }.count
    }
    
    func extractCallNodes(from definition: DefinitionNode, arguments: Bool = true) -> [String] {
        var callNodes: [String] = []
        for node in definition.body {
            
            if let call = node as? CallNode {
                callNodes.append(call.identifier)
                if arguments {
                    callNodes.append(call.arguments)
                }
            }
            
            if let conditionalNode = node as? ConditionalStatementNode {
                for node in conditionalNode.body {
                    guard let call = node as? CallNode else { continue }
                    callNodes.append(call.identifier)
                    if arguments {
                        callNodes.append(call.arguments)
                    }
                }
            }
            
            if let loopNode = node as? LoopNode {
                for node in loopNode.body {
                    guard let call = node as? CallNode else { continue }
                    callNodes.append(call.identifier)
                    if arguments {
                        callNodes.append(call.arguments)
                    }
                }
            }
        }
        return callNodes
    }
    
    public func containsNestedLoop() -> Bool {
        for loop in loopNodes {
            for node in loop.body {
                if let nestedLoop = node as? LoopNode {
                    return true
                }
            }
        }
        return false
    }
    
    func extractVariableNodes(from definition: DefinitionNode) -> [String] {
        var variableNodes: [String] = []
        for node in definition.body {
            
            if let variable = node as? VariableNode {
                variableNodes.append(variable.identifier)
            }
            
            if let conditionalNode = node as? ConditionalStatementNode {
                variableNodes.append(conditionalNode.condition)
                for node in conditionalNode.body {
                    guard let variable = node as? VariableNode else { continue }
                    variableNodes.append(variable.identifier)
                }
            }
            
            if let loopNode = node as? LoopNode {
                variableNodes.append(loopNode.condition)
                for node in loopNode.body {
                    guard let variable = node as? VariableNode else { continue }
                    variableNodes.append(variable.identifier)
                }
            }
        }
        return variableNodes
    }
    
    public func functionCallsInFunctionDefinition(named functionName: String) -> [String] {
        var callNodes: [String] = []
        if let functionNode = definitionNodes.filter({ $0.name == functionName }).first {
            callNodes = extractCallNodes(from: functionNode)
        } else {
            return []
        }
    
        return callNodes
    }
    
    public func variablesInFunctionDefinition(named functionName: String) -> [String] {
        var variableNodes: [String] = []
        
        if let functionNode = definitionNodes.filter({ $0.name == functionName }).first {
            variableNodes = extractVariableNodes(from: functionNode)
        } else {
            return []
        }
        return variableNodes
    }

    public func allDataInFunction(named functionName: String, arguments: Bool = true) -> [String] {
        var allNodes: [String] = []
        if let functionNode = definitionNodes.filter({ $0.name == functionName }).first {
            allNodes += extractCallNodes(from: functionNode, arguments: arguments)
            allNodes += extractVariableNodes(from: functionNode)
        } else {
            return []
        }
        
        return allNodes
    }
    
    public func callNodesInFunctionDefinition(named functionName: String) -> [CallNode] {
        var callNodes: [CallNode] = []
        if let functionNode = definitionNodes.filter({ $0.name == functionName }).first {
            for node in functionNode.body {
                guard let call = node as? CallNode else { continue }
                callNodes.append(call)
            }
        } else {
            return []
        }
        return callNodes
    }
    
    
    
    public func function(_ name: String, matchesCalls calls: [String]) -> Bool {
        guard let functionNode = definitionNodes.first else { return false }
        guard !functionNode.body.isEmpty else { return false }
        
        let sanitizedCalls: [String] = calls.map {
            if $0.hasSuffix("()") {
                return String($0.dropLast(2))
            }
            return $0
        }
        
        guard functionNode.body.count == sanitizedCalls.count else { return false }
        for (bodyNode, check) in zip(functionNode.body, sanitizedCalls) {
            guard let call = bodyNode as? CallNode else { continue }
            
            if call.identifier != check {
                return false
            }
        }
        
        return true
    }
}
