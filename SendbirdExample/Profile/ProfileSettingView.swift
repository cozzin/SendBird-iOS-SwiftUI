//
//  ProfileSettingView.swift
//  SendbirdExample
//
//  Created by Ernest Hong on 2022/01/21.
//

import SwiftUI
import SendBirdSDK

struct ProfileSettingView: View {
    
    @ObservedObject var viewModel: ProfileSettingViewModel
    @State private var error: SBDError?
    
    var isAlertPresented: Binding<Bool> {
        Binding<Bool>(
            get: {
                error != nil
            },
            set: { newValue in
                if newValue == false {
                    error = nil
                }
            }
        )
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("UserId :")
                Text(viewModel.userId)
                Spacer()
            }
            
            HStack {
                Text("Nickname :")
                TextField("Change Nickname", text: $viewModel.nickname)
            }
            
            Spacer()
            
            Button("Update") {
                Task {
                    do {
                        try await viewModel.updateProfile()
                    } catch {
                        self.error = (error as? SBDError)
                    }
                }
            }
            .disabled(viewModel.isUpdateButtonDisabled)
        }
        .alert(isPresented: isAlertPresented, error: error, actions: { })
        .padding()
        .navigationTitle(Text("Profile Setting"))
    }
}
