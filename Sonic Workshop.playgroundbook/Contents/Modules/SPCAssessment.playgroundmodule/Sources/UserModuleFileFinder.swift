//
//  UserModuleFileFinder.swift
//  
//  Copyright © 2020 Apple Inc. All rights reserved.
//

import PlaygroundSupport

public class UserModuleFileFinder {
    public init() { }
    
    public let files = PlaygroundPage.current.listSourceFiles(inUserModule: "MyFiles")
    
    /// Leave out file extension names.
    public func getContents(ofFile name: String, module: String) -> String {
        if let fileContents = PlaygroundPage.current.getText(forSourceFile: "\(name).swift", inUserModule: module) {
            
            return fileContents
        } else {
            return ""
        }
    }
}
