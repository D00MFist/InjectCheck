//
//  CheckApp.swift
//  InjectCheck
//
//  Created by itsatrap on 9/30/20.
//

import Foundation

class CheckApp {
    
    func electronCheck(pathToapplication: String){
    //electron app

    //https://stackoverflow.com/questions/24181699/how-to-check-if-a-file-exists-in-the-documents-directory-in-swift
    
    let filePath = pathToapplication + "/Contents/Resources/app.asar"
    let fileManager = FileManager.default
        if fileManager.fileExists(atPath: filePath) {
           // print("The " + applicationName + " application contains a app.asar and is likely an Electron app. Can abuse ELECTRON_RUN_AS_NODE environment variable for injection. e.g: create plist and use launchctl to load tamper plist. Example is https://blog.xpnsec.com/macos-injection-via-third-party-frameworks/")
            print("The application contains a app.asar and is likely an Electron app. Can abuse ELECTRON_RUN_AS_NODE environment variable for injection. e.g: create plist and use launchctl to load tamper plist. Example is https://blog.xpnsec.com/macos-injection-via-third-party-frameworks/")
        } else {
            print("No 'app.asar' file. Likely not an Electron app")
        }
    }
    
    func verifyHardenedRuntimeAndProblematicEntitlements(applicationName: String, secStaticCode: SecStaticCode) -> Bool {
           var signingInformationOptional: CFDictionary? = nil
           if SecCodeCopySigningInformation(secStaticCode, SecCSFlags(rawValue: kSecCSDynamicInformation), &signingInformationOptional) != errSecSuccess {
               NSLog("Couldn't obtain signing information")
               return false
           }
           
           guard let signingInformation = signingInformationOptional else {
               return false
           }

           let signingInformationDict = signingInformation as NSDictionary
           
           let signingFlagsOptional = signingInformationDict.object(forKey: "flags") as? UInt32
           
           if let signingFlags = signingFlagsOptional {
               let hardenedRuntimeFlag: UInt32 = 0x10000
            print(String(format: "The " + applicationName + " application has a Hardened runtime Value of %llX ",signingFlags))
             if (signingFlags & hardenedRuntimeFlag) != hardenedRuntimeFlag {
                print("Hardened runtime is not set for the " + applicationName + " application. Nice and easy injection option: use 'DYLD_INSERT_LIBRARIES'. (e.g.: DYLD_INSERT_LIBRARIES=/PATH_TO/evil.dylib /Applications/Calculator.app/Contents/MacOS/Calculator &)")
                   return false
               }
           } else {
               return false
           }
           
           let entitlementsOptional = signingInformationDict.object(forKey: "entitlements-dict") as? NSDictionary
           guard let entitlements = entitlementsOptional else {
               return false
           }
            //list all entitlements just for Debugging
            //print("The Entitlements are \(entitlements)")
            
            //Injection Entitlements
            let disableDylbkeyExists = entitlements["com.apple.security.cs.disable-library-validation"] != nil
            let allowDylibkeyExsists = entitlements["com.apple.security.cs.allow-dyld-environment-variables"] != nil
            let unsignMemkeyExists = entitlements["com.apple.security.cs.allow-unsigned-executable-memory"] != nil
            let getTaskkeyExists = entitlements["com.apple.security.get-task-allow"] != nil
            
           //Check for "com.apple.security.cs.allow-dyld-environment-variables"  & "com.apple.security.cs.disable-library-validation" entitlements
             if disableDylbkeyExists && allowDylibkeyExsists {
                print("The " + applicationName + " application contains the 'com.apple.security.cs.disable-library-validation' and 'com.apple.security.cs.allow-dyld-environment-variables' entitlements are present. Nice and easy injection option: use 'DYLD_INSERT_LIBRARIES'. (e.g.: DYLD_INSERT_LIBRARIES=/PATH_TO/evil.dylib /Applications/Calculator.app/Contents/MacOS/Calculator &)")
             }
            
            //Check for com.apple.security.cs.allow-unsigned-executable-memory (allows shellcode injection) and com.apple.security.cs.disable-library-validation (allows any dylib)
                    if unsignMemkeyExists && allowDylibkeyExsists {
                        print("The " + applicationName + " application contains the 'com.apple.security.cs.allow-unsigned-executable-memory' (allows shellcode injection) and 'com.apple.security.cs.allow-dyld-environment-variables' (allows any dylib) entitlements are present. Use https://github.com/KJCracks/yololib (e.g.: './yololib /Applications/Dropbox.app/Contents/MacOS/Dropbox inject.dylib')")
                    } else if unsignMemkeyExists && disableDylbkeyExists {
                        print("The " + applicationName + " application contains the 'com.apple.security.cs.allow-unsigned-executable-memory' and 'com.apple.security.cs.disable-library-validation' entitlements. Use https://github.com/KJCracks/yololib (e.g.: './yololib /Applications/Dropbox.app/Contents/MacOS/Dropbox inject.dylib')")
                    }  else if unsignMemkeyExists && allowDylibkeyExsists == false {
                        print("The " + applicationName + " application contains the 'com.apple.security.cs.allow-unsigned-executable-memory' entitlement is present. Code injection is possible but requres some creativey that cannot be automated.")
                        }
            //check for just get-task-allow
            if getTaskkeyExists {
                print("The " + applicationName + " application contains the 'com.apple.security.get-task-allow' entitlements is present. Due to this we can obtain a task port without root. Use https://github.com/KJCracks/yololib or libinject in poseidon")
            }
            
           return true
       }

}
