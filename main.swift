//
//  main.swift
//  InjectCheck
//
//  Created by D00mfist
//

import Cocoa

let injectcheck = InjectCheck()

if CommandLine.argc < 2 {
  print("Not enough Arguments")
} else {
    injectcheck.staticMode()
}
