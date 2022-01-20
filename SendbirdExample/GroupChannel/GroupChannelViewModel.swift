//
//  GroupChannelViewModel.swift
//  SendbirdExample
//
//  Created by Ernest Hong on 2022/01/19.
//

import Foundation
import SendBirdSDK

final class GroupChannelViewModel: NSObject, ObservableObject {
    
    private enum Constants {
        static let loadPreviousMessageLimit: Int = 15
    }
    
    @Published var messages: [SBDBaseMessage] = []
    
    @Published var inputText: String = ""
    
    @Published var hasPreviousMessages: Bool = true
    
    var channelName: String {
        channel.name
    }
    
    var navigationTitle: String {
        channelName + " (\(channel.memberCount))"
    }
    
    var isEmpty: Bool {
        messages.isEmpty
    }
    
    var isDisabledSendButton: Bool {
        inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
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
        
        let (messages, error) = await listQuery.loadPreviousMessages(withLimit: Constants.loadPreviousMessageLimit, reverse: false)
        
        guard error == nil else {
            // TODO: - Error Handling
            return
        }
        
        guard let messages = messages else { return }
        
        DispatchQueue.main.async { [weak self] in
            self?.hasPreviousMessages = messages.count >= Constants.loadPreviousMessageLimit
        }
        
        guard messages.isEmpty == false else {
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.messages.insert(contentsOf: messages, at: 0)
        }
    }
    
    func message(before givenMessage: SBDBaseMessage?) -> SBDBaseMessage? {
        guard let givenMessage = givenMessage,
              let givenIndex = messages.firstIndex(of: givenMessage) else {
            return nil
        }
        
        let resultIndex = givenIndex - 1
        
        return resultIndex >= 0 ? messages[resultIndex] : nil
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
    
    func deleteMessage(_ message: SBDBaseMessage) async throws {
        let error = await channel.delete(message)
        
        if let error = error {
            throw error
        }
    }
}

// MARK: - SBDChannelDelegate

extension GroupChannelViewModel: SBDChannelDelegate {
    
    func channel(_ sender: SBDBaseChannel, didReceive message: SBDBaseMessage) {
        messages.append(message)
    }
    
    func channel(_ sender: SBDBaseChannel, messageWasDeleted messageId: Int64) {
        messages = messages.filter { $0.messageId != messageId }
    }
    
}
