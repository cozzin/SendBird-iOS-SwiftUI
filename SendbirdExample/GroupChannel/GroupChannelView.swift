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
    
    init(channel: SBDGroupChannel) {
        _viewModel = .init(initialValue: .init(channel: channel))
    }
    
    var body: some View {
        List(viewModel.messages) { message in
            GroupChannelMessageView(message: message)
                .task {
                    if viewModel.isFirstMessage(message) {
                        await viewModel.loadPreviousMessages()
                    }
                }
        }
        .listStyle(.plain)
        .navigationTitle(Text(viewModel.navigationTitle))
        .onAppear {
            viewModel.onAppear()
        }
        .onDisappear {
            viewModel.onDisappear()
        }
        .task {
            await viewModel.loadPreviousMessages()
        }
    }
}

struct GroupChannelView_Previews: PreviewProvider {
    static var previews: some View {
        GroupChannelView(channel: .init(dictionary: [:]))
    }
}
