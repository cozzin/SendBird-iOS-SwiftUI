//
//  GroupChannelListView.swift
//  SendbirdExample
//
//  Created by Ernest Hong on 2022/01/18.
//

import SwiftUI
import SendBirdSDK

struct GroupChannelListView: View {
    
    @ObservedObject var viewModel: GroupChannelListViewModel
    @State private var alert: Alert?
    @State private var isShowingCreateChannel: Bool = false
    @State private var isShowingProfile: Bool = false
    
    var body: some View {
        List(viewModel.channels) { channel in
            NavigationLink(destination: GroupChannelView(channel: channel.rawValue)) {
                Text("\(channel.name)")
                    .task {
                        if viewModel.isLastChannel(channel) {
                            await viewModel.loadNextChannels()
                        }
                    }
            }
        }
        .task {
            await viewModel.loadNextChannels()
        }
        .refreshable {
            await viewModel.refreshChannels()
        }
        .alert(item: $viewModel.alert) { alertIdentifier in
            Alert(
                title: Text("Sorry, an error occurred"),
                message: Text(alertIdentifier.message),
                dismissButton: .cancel()
            )
        }
        .sheet(
            isPresented: $isShowingCreateChannel,
            onDismiss: { Task { await viewModel.refreshChannels() } },
            content: {
                NavigationView {
                    CreateGroupChannelView(
                        viewModel: .init(isShowing: $isShowingCreateChannel)
                    )
                }
            }
        )
        .sheet(
            isPresented: $isShowingProfile,
            content: {
                NavigationView {
                    ProfileSettingView(
                        viewModel: .init(user: viewModel.user, isShowing: $isShowingProfile)
                    )
                }
            }
        )
        .navigationTitle(Text("Channel"))
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { isShowingProfile = true }) {
                    Image(systemName: "person.circle")
                }
                .accessibilityLabel("Create Group Channel")
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { isShowingCreateChannel = true }) {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Create Group Channel")
            }
        }
    }
}
