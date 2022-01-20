//
//  GroupChannelView.swift
//  SendbirdExample
//
//  Created by Ernest Hong on 2022/01/19.
//

import SwiftUI
import SendBirdSDK

struct GroupChannelView: View {
    
    @ObservedObject private var viewModel: GroupChannelViewModel
    @State private var errorMessage: String?

    init(channel: SBDGroupChannel) {
        _viewModel = .init(initialValue: .init(channel: channel))
    }
    
    var body: some View {
        VStack {
            messageList
            inputView
        }
    }
    
    private var messageList: some View {
        List(viewModel.messages) { message in
            GroupChannelMessageView(message: message)
                .id(message)
                .task {
                    guard viewModel.isFirstMessage(message) else { return }
                    
                    await viewModel.loadPreviousMessages()
                }
        }
        .listStyle(.plain)
        .navigationTitle(Text(viewModel.navigationTitle))
        .task {
            guard viewModel.isEmpty else { return }
            
            await viewModel.loadPreviousMessages()
        }
        .onAppear {
            viewModel.onAppear()
        }
        .onDisappear {
            viewModel.onDisappear()
        }
    }
    
    private var inputView: some View {
        HStack {
            TextField("Say something...", text: $viewModel.inputText)
            Button("Send") {
                Task {
                    do {
                        try await viewModel.sendMessage()
                    } catch {
                        errorMessage = error.localizedDescription
                    }
                }
            }
        }
        .padding()
    }
}

struct GroupChannelView_Previews: PreviewProvider {
    static var previews: some View {
        GroupChannelView(channel: .init(dictionary: [:]))
    }
}
