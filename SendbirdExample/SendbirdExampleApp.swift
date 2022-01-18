//
//  SendbirdExampleApp.swift
//  SendbirdExample
//
//  Created by Ernest Hong on 2022/01/18.
//

import SwiftUI

@main
struct SendbirdExampleApp: App {
    init() {
        Environment.setup()
    }
    
    var body: some Scene {
        WindowGroup {
            IntroView()
        }
    }
}
