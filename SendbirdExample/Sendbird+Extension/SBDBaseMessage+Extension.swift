//
//  SBDBaseMessage+Extension.swift
//  SendbirdExample
//
//  Created by Ernest Hong on 2022/01/20.
//

import Foundation
import SendBirdSDK

extension SBDBaseMessage: Identifiable {
    public var id: Int64 {
        messageId
    }
}
