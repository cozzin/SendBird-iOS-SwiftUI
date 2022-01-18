//
//  IntroView.swift
//  SendbirdExample
//
//  Created by Ernest Hong on 2022/01/18.
//

import SwiftUI

struct IntroView: View {
    @StateObject var viewModel = IntroViewModel()
    
    var body: some View {
        if viewModel.isLoggedIn {
            ChannelListView()
        } else {
            loginView
        }
    }
    
    private var loginView: some View {
        VStack {
            Text("Welcome to Sendbird Chat 👋")
            TextField("Input UserId", text: $viewModel.userId)
                .multilineTextAlignment(.center)
            Button("Login") {
                viewModel.login()
            }
            .disabled(viewModel.isLoginButtonDisabled)
        }
        .padding()
    }
}

struct IntroView_Previews: PreviewProvider {
    static var previews: some View {
        IntroView()
    }
}
