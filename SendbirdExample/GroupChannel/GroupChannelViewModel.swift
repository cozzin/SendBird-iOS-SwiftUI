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
    
    @Published var inputText: String = ""
    
    var channelName: String {
        channel.name
    }
    
    var navigationTitle: String {
        channelName + " (\(channel.memberCount))"
    }
    
    var isEmpty: Bool {
        messages.isEmpty
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
        guard let listQuery = previousMessagesQuery, listQuery.isLoading() == false else {
            return
        }
        
        let (messages, error) = await listQuery.loadPreviousMessages(withLimit: 5, reverse: false)
        
        guard error == nil else {
            // TODO: - Error Handling
            return
        }
        
        guard let messages = messages else { return }
        
        guard messages.isEmpty == false else {
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.messages.insert(contentsOf: messages, at: 0)
        }
    }
    
    func isFirstMessage(_ message: SBDBaseMessage) -> Bool {
        messages.first == message
    }
    
    func sendMessage() async throws {
        guard let params = SBDUserMessageParams(message: inputText) else { return }
        
        let message: SBDUserMessage = try await withCheckedThrowingContinuation { continuation in
            channel.sendUserMessage(with: params) { message, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let message = message else { return }
                
                continuation.resume(returning: message)
            }
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.inputText = ""
            self?.messages.append(message)
        }
    }
}

// MARK: - SBDChannelDelegate

extension GroupChannelViewModel: SBDChannelDelegate {
    
    func channel(_ sender: SBDBaseChannel, didReceive message: SBDBaseMessage) {
        messages.append(message)
    }
    
}
