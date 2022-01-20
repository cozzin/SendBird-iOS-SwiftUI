//
//  GroupChannelMessageView.swift
//  SendbirdExample
//
//  Created by Ernest Hong on 2022/01/20.
//

import SwiftUI
import SendBirdSDK

struct GroupChannelMessageView: View {
    
    let message: SBDBaseMessage
    
    var body: some View {
        HStack {
            if let sender = message.sender {
                VStack {
                    Text(sender.nickname ?? "(unknown)")
                    Spacer()
                }
                .padding(.top, 10)
            }
            
            HStack {
                Text(message.message)
                Spacer()
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color(UIColor.secondarySystemBackground))
            )
        }
        .padding(.vertical, 5)
    }
}
