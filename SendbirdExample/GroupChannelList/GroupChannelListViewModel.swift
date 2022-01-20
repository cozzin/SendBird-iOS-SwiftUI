//
//  GroupChannelListViewModel.swift
//  SendbirdExample
//
//  Created by Ernest Hong on 2022/01/18.
//

import Foundation
import SendBirdSDK
import SwiftUI

final class GroupChannelListViewModel: ObservableObject {
    
    @Published var alert: AlertIdentifier?
    @Published private(set) var channels: [GroupChannel] = []
    
    let user: SBDUser
    private var isNextChannelsLoading: Bool = false
    private lazy var query: SBDGroupChannelListQuery = createQuery()
    
    init(user: SBDUser) {
        self.user = user
    }
    
    func refreshChannels() async {
        query = createQuery()

        do {
            let channels = try await query.loadNextPageChannels()

            DispatchQueue.main.async { [weak self] in
                self?.channels = channels.map(GroupChannel.init)
            }
        } catch {
            DispatchQueue.main.async { [weak self] in
                self?.alert = .queryError(error)
            }
        }
    }
    
    func loadNextChannels() async {
        do {
            let channels = try await query.loadNextPageChannels()
            
            DispatchQueue.main.async { [weak self] in
                self?.channels.append(contentsOf: channels.map(GroupChannel.init))
            }
        } catch {
            DispatchQueue.main.async { [weak self] in
                self?.alert = .queryError(error)
            }
        }
    }
    
    func isLastChannel(_ channel: GroupChannel) -> Bool {
        channels.last == channel
    }
    
    private func createQuery() -> SBDGroupChannelListQuery {
        let listQuery = SBDGroupChannel.createMyGroupChannelListQuery()
        listQuery?.includeEmptyChannel = true
        listQuery?.order = .latestLastMessage
        listQuery?.limit = 15
        return listQuery ?? SBDGroupChannelListQuery(dictionary: [:])
    }
        
}

// MARK: - GroupChannel

extension GroupChannelListViewModel {
    
    struct GroupChannel: Identifiable, Equatable {
        
        let rawValue: SBDGroupChannel
        
        init(_ rawValue: SBDGroupChannel) {
            self.rawValue = rawValue
        }
        
        var id: String {
            rawValue.channelUrl
        }
        
        var name: String {
            rawValue.name
        }
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.rawValue == rhs.rawValue
        }
    }
    
}

// MARK: - AlertIdentifier

extension GroupChannelListViewModel {
    
    enum AlertIdentifier: Identifiable {
        var id: String {
            String(describing: self)
        }
        
        var message: String {
            switch self {
            case .queryError(let error):
                if let error = error as? SBDError {
                    return error.localizedDescription
                }
            }
            
            return "Unknown error"
        }
        
        case queryError(Error)
    }
    
}

// MARK: - SBDGroupChannelListQuery

extension SBDGroupChannelListQuery {
    
    func loadNextPageChannels() async throws -> [SBDGroupChannel] {
        let (channels, error) = await loadNextPage()
        
        if let error = error {
            throw error
        }
        
        guard let channels = channels else {
            return []
        }
        
        return channels
    }

}
