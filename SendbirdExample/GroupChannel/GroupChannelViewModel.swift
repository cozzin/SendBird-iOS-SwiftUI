//
//  GroupChannelViewModel.swift
//  SendbirdExample
//
//  Created by Ernest Hong on 2022/01/19.
//

import Foundation
import SendBirdSDK

final class GroupChannelViewModel: NSObject, ObservableObject {
    
    @Published var messages: [SBDBaseMessage] = []
    
    var channelName: String {
        channel.name
    }
    
    var navigationTitle: String {
        channelName + " (\(channel.memberCount))"
    }
    
    private let channel: SBDGroupChannel
    
    private lazy var previousMessagesQuery = channel.createPreviousMessageListQuery()
    
    private var channelDelegateIdentifier: String {
        "GroupChannelViewModel.\(channel.channelUrl)"
    }
    
    init(channel: SBDGroupChannel) {
        self.channel = channel
        super.init()
    }
    
    func onAppear() {
        SBDMain.add(self, identifier: channelDelegateIdentifier)
    }
    
    func onDisappear() {
        SBDMain.removeChannelDelegate(forIdentifier: channelDelegateIdentifier)
    }
    
    func loadPreviousMessages() async {
        guard let listQuery = previousMessagesQuery else { return }
        
        let (messages, error) = await listQuery.loadPreviousMessages(withLimit: 15, reverse: false)
        
        guard error == nil else {
            // TODO: - Error Handling
            return
        }
        
        guard let messages = messages else { return }
        
        DispatchQueue.main.async { [weak self] in
            self?.messages.insert(contentsOf: messages, at: 0)
        }
    }
    
    func isFirstMessage(_ message: SBDBaseMessage) -> Bool {
        messages.first == message
    }
}

// MARK: - SBDChannelDelegate

extension GroupChannelViewModel: SBDChannelDelegate {
    
    func channel(_ sender: SBDBaseChannel, didReceive message: SBDBaseMessage) {
        messages.append(message)
    }
    
}
