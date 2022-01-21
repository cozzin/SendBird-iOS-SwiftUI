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
    
    let onLongPress: () -> Void
    
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
                if let fileMessage = message as? SBDFileMessage,
                   let imageUrlString = fileMessage.url,
                   let imageUrl = URL(string: imageUrlString) {
                    AsyncImage(url: imageUrl) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 200)
                    } placeholder: {
                        ProgressView()
                            .frame(height: 200)
                    }
                } else {
                    Text(message.message)
                }
                Spacer()
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color(UIColor.secondarySystemBackground))
            )
            .onTapGesture { }
            .onLongPressGesture {
                onLongPress()
            }
        }
        .padding(5)
        .id(message)
    }
}
