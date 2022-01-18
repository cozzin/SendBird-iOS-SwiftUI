//
//  Environment.swift
//  SendbirdExample
//
//  Created by Ernest Hong on 2022/01/18.
//

import Foundation
import SendBirdSDK

struct Environment {
    private enum Constant {
        static let applicationId: String = "A74A3E6C-ECE4-410C-AA5D-69D397B1EA73"
    }
    
    static func setup() {
        SBDMain.initWithApplicationId(
            Constant.applicationId,
            useCaching: true,
            migrationStartHandler: {
                
            },
            completionHandler: { error in
                // TODO: Error Handling
            }
        )
    }
}
