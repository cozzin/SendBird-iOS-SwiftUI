//
//  GroupChannelView.swift
//  SendbirdExample
//
//  Created by Ernest Hong on 2022/01/19.
//

import SwiftUI
import SendBirdSDK

struct GroupChannelView: View {
    
    let channel: SBDGroupChannel
    
    var body: some View {
        Text("Hello, \(channel.name)!")
            .navigationTitle(Text(channel.name + " (\(channel.memberCount))"))
    }
}

struct GroupChannelView_Previews: PreviewProvider {
    static var previews: some View {
        GroupChannelView(channel: .init(dictionary: [:]))
    }
}
