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
    
    init(viewModel: GroupChannelViewModel) {
        _viewModel = .init(initialValue: viewModel)
    }
    
    var body: some View {
        List(viewModel.messages) { message in
            GroupChannelMessageView(message: message)
        }
        .listStyle(.plain)
        .navigationTitle(Text(viewModel.navigationTitle))
        .task {
            await viewModel.loadPreviousMessages()
        }
    }
}

struct GroupChannelView_Previews: PreviewProvider {
    static var previews: some View {
        GroupChannelView(viewModel: .init(channel: .init(dictionary: [:])))
    }
}
