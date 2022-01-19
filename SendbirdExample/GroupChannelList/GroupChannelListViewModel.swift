//
//  GroupChannelListViewModel.swift
//  SendbirdExample
//
//  Created by Ernest Hong on 2022/01/18.
//

import Foundation
import SendBirdSDK

final class GroupChannelListViewModel: ObservableObject {
    
    @Published var channels: [GroupChannel] = []
    @Published var alert: AlertIdentifier?
    
    private var isNextChannelsLoading: Bool = false
    
    private lazy var query: SBDGroupChannelListQuery = createQuery()
    
    func refreshChannels() async {
        query = createQuery()
        channels = []
        await loadNextChannels()
    }
    
    func loadNextChannels() async {
        guard query.isLoading() == false else { return }
        
        let (channels, error) = await query.loadNextPage()
        
        if let error = error {
            alert = .groupChannelQueryError(error)
            return
        }
        
        guard let channels = channels else { return }
        
        DispatchQueue.main.async { [weak self] in
            self?.channels.append(contentsOf: channels.map(GroupChannel.init))
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

extension GroupChannelListViewModel {
    
    struct GroupChannel: Identifiable, Equatable {
        
        private let rawValue: SBDGroupChannel
        
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

extension GroupChannelListViewModel {
    
    enum AlertIdentifier: Identifiable {
        case groupChannelQueryError(SBDError)
        
        var id: String {
            switch self {
            case .groupChannelQueryError(let error):
                return "groupChannelQueryError.\(error.code)"
            }
        }
        
        var message: String {
            switch self {
            case .groupChannelQueryError(let error):
                return error.localizedDescription
            }
        }
    }

}
