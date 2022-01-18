//
//  IntroViewModel.swift
//  SendbirdExample
//
//  Created by Ernest Hong on 2022/01/18.
//

import Foundation
import SendBirdSDK
import SwiftUI

final class IntroViewModel: ObservableObject {
        
    @Published var userId: String = ""
    @Published var alert: AlertIdentifier?
    @Published var user: SBDUser?
    
    var isLoggedIn: Bool {
        user != nil
    }
    
    var isLoginButtonDisabled: Bool {
        userId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func login() {
        SBDMain.connect(withUserId: userId) { [weak self] user, error in
            if let error = error {
                self?.alert = .loginError(error)
                return
            }
            
            guard let user = user else {
                self?.alert = .emptyUser
                return
            }
            
            self?.user = user
        }
    }
    
}

extension IntroViewModel {
    
    enum AlertIdentifier: Identifiable {
        case loginError(SBDError)
        case emptyUser
        
        var id: String {
            switch self {
            case .loginError(let error):
                return "loginError.\(error.code)"
            case .emptyUser:
                return "emptyUser"
            }
        }
        
        var message: String {
            switch self {
            case .loginError(let error):
                return error.localizedDescription
            case .emptyUser:
                return "Unable to get user"
            }
        }
    }

}
