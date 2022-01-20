//
//  ProfileSettingViewModel.swift
//  SendbirdExample
//
//  Created by Ernest Hong on 2022/01/21.
//

import Foundation
import SendBirdSDK
import SwiftUI

final class ProfileSettingViewModel: ObservableObject {
    
    @Binding var isShowing: Bool
    @Published var nickname: String
    
    var userId: String {
        user.userId
    }
    
    var isUpdateButtonDisabled: Bool {
        user.nickname == nickname
    }
    
    private let user: SBDUser
    
    init(user: SBDUser, isShowing: Binding<Bool>) {
        self.user = user
        self._isShowing = isShowing
        self._nickname = .init(initialValue: user.nickname ?? "")
    }
    
    func updateProfile() async throws {
        let error = await SBDMain.updateCurrentUserInfo(withNickname: nickname, profileUrl: nil)
        
        if let error = error {
            throw error
        }
        
        isShowing = false
    }
    
}
