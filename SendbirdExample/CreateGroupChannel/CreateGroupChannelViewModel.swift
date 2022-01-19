//
//  CreateGroupChannelViewModel.swift
//  SendbirdExample
//
//  Created by Ernest Hong on 2022/01/19.
//

import Foundation
import SendBirdSDK
import SwiftUI

final class CreateGroupChannelViewModel: ObservableObject {
    
    @Published var channelName: String = ""
    @Published var channelUrlString: String?
    @Published var invitedUserIds: [String] = []
    @Published var alert: AlertIdentifier?
    
    @Binding private var isShowing: Bool

    var isCreateButtonDisabled: Bool {
        channelName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    init(isShowing: Binding<Bool>) {
        self._isShowing = isShowing
    }

    func createChannel() async {
        var ops: [String] = []
        ops.append("Jeff")

        let params = SBDGroupChannelParams()
        params.isPublic = false
        params.isEphemeral = false
        params.isDistinct = false
        params.isSuper = false
        params.addUserIds(invitedUserIds)
        params.name = channelName
        params.channelUrl = channelUrlString
//        params.operatorUserIds = ops        // Or .operators
//        params.coverImage = FILE            // Or .coverUrl
//        params.data = DATA
//        params.customType = CUSTOM_TYPE
        
        let (channel, error) = await SBDGroupChannel.createChannel(with: params)
        
        if let error = error {
            alert = .createChannelError(error)
            return
        }
        
        guard channel != nil else {
            alert = .cannotCreateChannel
            return
        }
        
        isShowing = false
    }
        
}

// MARK: - AlertIdentifier

extension CreateGroupChannelViewModel {
    
    enum AlertIdentifier: Identifiable {
        case createChannelError(Error)
        case cannotCreateChannel
        
        var id: String {
            String(describing: self)
        }
        
        var message: String {
            switch self {
            case .createChannelError(let error):
                if let error = error as? SBDError {
                    return error.localizedDescription
                }
            case .cannotCreateChannel:
                return "Cannot create channel"
            }
            
            return "Unknown error"
        }
    }
    
}
