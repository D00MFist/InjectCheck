//
//  InjectCheck.swift
//  InjectCheck
//
//  Created by itsatrap on 9/30/20.
//

import Foundation
class InjectCheck {

  let consoleIO = ConsoleIO()
    
  let checkApp = CheckApp()
      
    func getOption(_ option: String) -> (option:OptionType, value: String) {
      return (OptionType(value: option), option)
    }

    
    
  func staticMode() {
    let argCount = CommandLine.argc
    let argument = CommandLine.arguments[1]
    let (option, value) = getOption(argument.substring(from: argument.index(argument.startIndex, offsetBy: 1)))
    
    //For Debugging
    print("Argument count: \(argCount) Option: \(option) value: \(value)")
    
    switch option {
    case .allApps:
        if argCount != 2 {
            if argCount > 2 {
                print("Too many arguments for option \(option.rawValue)")
            } else {
                print("Too few arguments for option \(option.rawValue)")
            }
            consoleIO.printUsage()
            
        } else {
                       
            if value == "All" {
                //print("Selected All Option")
                print("Checking All Applications")
                
                //Run all function
                let appPath = "/Applications"
                let fileManager = FileManager.default
                do {
                    let appsArray = try fileManager.contentsOfDirectory(atPath: appPath)
                    //print(appsArray)
                    let justApps = appsArray.filter { $0 != ".DS_Store" && $0 != ".localized" && $0 != "Utilities"}
                    for app in justApps {
                        print(" ================ " + app + " ================ ")
                        
                        
                            //testing
                        let mybundle = Bundle(path : "/Applications/" + app)
                        let myURL = mybundle?.bundleURL
                        let name = mybundle?.object(forInfoDictionaryKey: kCFBundleNameKey as String)
                        //let appName = name as! String
                       // print("The Application Name is " + appName)
                        var codeRef: SecStaticCode? = nil
                        SecStaticCodeCreateWithPath(myURL! as CFURL, [], &codeRef)
                        checkApp.verifyHardenedRuntimeAndProblematicEntitlements(applicationName: app, secStaticCode: codeRef!)
                        checkApp.electronCheck(pathToapplication: "/Applications" + app)
                    }
                        } catch {
                            print(error)
                            }

            } else {
                consoleIO.printUsage()
            }
        }
    case .oneApp:
        if argCount != 3 {
            if argCount > 3 {
                print("Too many arguments for option \(option.rawValue)")
            } else {
                print("Too few arguments for option \(option.rawValue)")
            }
            consoleIO.printUsage()
        } else {

            let pathtoApp = CommandLine.arguments[2]
           
            if value == "p" {
                //print("Selected Path Option")
                print("Running on \(pathtoApp)")
                               
                //Run single path function
                let mybundle = Bundle(path :pathtoApp)
                let myURL = mybundle?.bundleURL
                let name = mybundle?.object(forInfoDictionaryKey: kCFBundleNameKey as String)
                let appName = name as! String
                print("The Application Name is " + appName)
                var codeRef: SecStaticCode? = nil
                SecStaticCodeCreateWithPath(myURL! as CFURL, [], &codeRef)
                checkApp.verifyHardenedRuntimeAndProblematicEntitlements(applicationName: appName, secStaticCode: codeRef!)
                checkApp.electronCheck(pathToapplication: pathtoApp)
                   
            } else {
                consoleIO.printUsage()
            }
                
        }
    case .help:
        consoleIO.printUsage()
    case .unknown:
        print("Unknown option \(value)")
        consoleIO.printUsage()
    }

}

enum OptionType: String {
  case allApps = "All"
  case oneApp = "p"
  case help = "h"
  case unknown
  
  init(value: String) {
    switch value {
    case "All": self = .allApps
    case "p": self = .oneApp
    case "h": self = .help
    default: self = .unknown
    }
  }
}
}
