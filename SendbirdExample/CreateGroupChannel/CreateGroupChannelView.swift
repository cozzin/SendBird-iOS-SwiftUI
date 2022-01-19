//
//  CreateGroupChannelView.swift
//  SendbirdExample
//
//  Created by Ernest Hong on 2022/01/19.
//

import SwiftUI

struct CreateGroupChannelView: View {
    
    @ObservedObject var viewModel: CreateGroupChannelViewModel
    
    var body: some View {
        VStack {
            Text("You can create new group channel 🤗")
            TextField("Channel Name", text: $viewModel.channelName)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            Button("Create Channel") {
                Task {
                    await viewModel.createChannel()
                }
            }
            .disabled(viewModel.isCreateButtonDisabled)
        }
        .padding()
        .navigationTitle(Text("Create Channel"))
    }
}

struct CreateGroupChannelView_Previews: PreviewProvider {
    static var previews: some View {
        CreateGroupChannelView(
            viewModel: CreateGroupChannelViewModel(
                isShowing: .constant(true)
            )
        )
    }
}
