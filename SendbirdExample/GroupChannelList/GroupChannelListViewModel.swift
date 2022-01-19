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
    
    private lazy var query: SBDGroupChannelListQuery = {
        let listQuery = SBDGroupChannel.createMyGroupChannelListQuery()
        listQuery?.includeEmptyChannel = true
        listQuery?.memberStateFilter = .stateFilterAll // TODO: - Change filter dynamically
        listQuery?.order = .latestLastMessage
        listQuery?.limit = 15
        return SBDGroupChannelListQuery(dictionary: [:])
    }()
    
    func loadNextChannels() async {
        guard query.isLoading() == false else { return }
        
        let (channels, error) = await query.loadNextPage()
        
        if let error = error {
            alert = .groupChannelQueryError(error)
            return
        }
        
        guard let channels = channels else {
            return
        }
        
        self.channels.append(contentsOf: channels.map(GroupChannel.init))
    }
    
    func isLastChannel(_ channel: GroupChannel) -> Bool {
        channels.last == channel
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
