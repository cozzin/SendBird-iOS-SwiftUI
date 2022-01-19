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
        NavigationView {
            if viewModel.isLoggedIn {
                GroupChannelListView()
            } else {
                loginView
            }
        }
    }
    
    private var loginView: some View {
        VStack {
            Text("Welcome to Sendbird Chat 👋")
            TextField("Input UserId", text: $viewModel.userId)
                .multilineTextAlignment(.center)
            Spacer()
            Button("Login") {
                viewModel.login()
            }
            .disabled(viewModel.isLoginButtonDisabled)
        }
        .padding()
        .navigationTitle(Text("Sendbird"))
    }
}

struct IntroView_Previews: PreviewProvider {
    static var previews: some View {
        IntroView()
    }
}
