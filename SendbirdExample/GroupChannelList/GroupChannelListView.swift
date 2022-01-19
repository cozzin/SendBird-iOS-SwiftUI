//
//  GroupChannelListView.swift
//  SendbirdExample
//
//  Created by Ernest Hong on 2022/01/18.
//

import SwiftUI

struct GroupChannelListView: View {
    
    @ObservedObject private var viewModel = GroupChannelListViewModel()
    @State private var alert: Alert?
    
    var body: some View {
        List(viewModel.channels) { channel in
            Text("\(channel.name)")
                .task {
                    if viewModel.isLastChannel(channel) {
                        await viewModel.loadNextChannels()
                    }
                }
        }
        .task {
            await viewModel.loadNextChannels()
        }
        .refreshable {
            await viewModel.refreshChannels()
        }
        .navigationTitle(Text("Channel"))
        .alert(item: $viewModel.alert) { alertIdentifier in
            Alert(
                title: Text("Sorry, an error occurred"),
                message: Text(alertIdentifier.message),
                dismissButton: .cancel()
            )
        }
    }
}

struct GroupChannelListView_Previews: PreviewProvider {
    static var previews: some View {
        GroupChannelListView()
    }
}
