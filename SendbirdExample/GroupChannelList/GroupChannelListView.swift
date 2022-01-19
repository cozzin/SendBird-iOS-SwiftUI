//
//  GroupChannelListView.swift
//  SendbirdExample
//
//  Created by Ernest Hong on 2022/01/18.
//

import SwiftUI

struct GroupChannelListView: View {
    
    private var viewModel = GroupChannelListViewModel()
    
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
    }
}

struct GroupChannelListView_Previews: PreviewProvider {
    static var previews: some View {
        GroupChannelListView()
    }
}
