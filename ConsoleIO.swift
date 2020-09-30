//
//  ConsoleIO.swift
//  InjectCheck
//
//  Created by D00mfist
//

import Foundation

class ConsoleIO {
    
    func printUsage() {
        let executableName = (CommandLine.arguments[0] as NSString).lastPathComponent
              
        print("Usage:")
        print("\(executableName) -All")
        print("Runs against all Applications in '/Applications'")
        print("or")
        print("\(executableName) -p /Path/to/ApplicationBundle")
        print("Runs against the specified application")
        print("or")
        print("\(executableName) -h to show usage information")
    }
}
