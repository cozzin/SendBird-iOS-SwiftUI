//
//  GroupChannelView.swift
//  SendbirdExample
//
//  Created by Ernest Hong on 2022/01/19.
//

import SwiftUI
import SendBirdSDK

struct GroupChannelView: View {
    
    @ObservedObject private var viewModel: GroupChannelViewModel
    @State private var errorMessage: String?
    @State private var alert: AlertIdentifier?
    @State private var isShowingImagePicker = false
    @FocusState private var isTyping: Bool

    init(channel: SBDGroupChannel) {
        _viewModel = .init(initialValue: .init(channel: channel))
    }
    
    var body: some View {
        ScrollViewReader { scrollViewProxy in
            VStack(spacing: 0) {
                scrollView(with: scrollViewProxy)
                inputView(with: scrollViewProxy)
            }
        }
        .navigationTitle(Text(viewModel.navigationTitle))
    }
    
    private func scrollView(with scrollViewProxy: ScrollViewProxy) -> some View {
        ScrollView(.vertical) {
            LazyVStack {
                if viewModel.hasPreviousMessages {
                    loadPreviousMessagesButton(with: scrollViewProxy)
                }
                
                ForEach(viewModel.messages) { message in
                    GroupChannelMessageView(message: message, onLongPress: {
                        alert = .longPressMessage(message)
                    })
                }
            }
            .task {
                guard viewModel.isEmpty else { return }
                await viewModel.loadPreviousMessages()
                scrollToBottom(scrollViewProxy)
            }
            .onAppear {
                viewModel.onAppear()
            }
            .onDisappear {
                viewModel.onDisappear()
            }
            .onChange(of: viewModel.messages) { newValue in
                scrollToBottom(scrollViewProxy)
            }
            .alert(item: $alert) { alertIdentifier in
                switch alertIdentifier {
                case .longPressMessage(let message):
                    return Alert(
                        title: Text("Are you sure you want to delete the message?"),
                        message: Text(message.message),
                        primaryButton: .destructive(
                            Text("Delete"),
                            action: {
                                Task {
                                    try await viewModel.deleteMessage(message)
                                }
                            }
                        ),
                        secondaryButton: .cancel()
                    )
                }
            }
        }
    }
    
    private func loadPreviousMessagesButton(with scrollViewProxy: ScrollViewProxy) -> some View {
        Button("Load Previous Messages") {
            let oldFirstMessage = viewModel.messages.first
            
            Task {
                await viewModel.loadPreviousMessages()
                DispatchQueue.main.async {
                    scrollViewProxy.scrollTo(viewModel.message(before: oldFirstMessage), anchor: .top)
                }
            }
        }
    }

    private func inputView(with scrollViewProxy: ScrollViewProxy) -> some View {
        HStack {
            if viewModel.isSendingImage {
                ProgressView()
            } else {
                Button(action: {
                    isShowingImagePicker.toggle()
                }) {
                    Image(systemName: "photo.circle.fill")
                }
                .sheet(isPresented: $isShowingImagePicker) {
                    ImagePicker(didPickImage: { image in
                        Task {
                            guard let data = image.pngData() else { return }
                            try await viewModel.sendImage(data)
                        }
                    })
                }
            }
            
            TextField("Say something...", text: $viewModel.inputText, onCommit: {
                sendMessage()
                isTyping = true
            }).focused($isTyping)
            
            Button("Send") {
                sendMessage()
            }.disabled(viewModel.isDisabledSendButton)
        }
        .padding()
    }
    
    private func sendMessage() {
        Task {
            do {
                try await viewModel.sendMessage()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    private func scrollToBottom(_ scrollViewProxy: ScrollViewProxy) {
        guard let lastMessage = viewModel.messages.last else { return }
        scrollViewProxy.scrollTo(lastMessage, anchor: .bottom)
    }
}


// MARK: - Alert

extension GroupChannelView {
    
    enum AlertIdentifier: Identifiable {
        var id: String {
            switch self {
            case .longPressMessage(let message):
                return "longPressMessage.\(message.messageId)"
            }
        }
        
        var title: String {
            "Are you sure you want to delete the message?"
        }
        
        var message: String {
            switch self {
            case .longPressMessage(let message):
                return "longPressMessage.\(message.message)"
            }
        }
        
        case longPressMessage(SBDBaseMessage)
    }
    
}

struct GroupChannelView_Previews: PreviewProvider {
    static var previews: some View {
        GroupChannelView(channel: .init(dictionary: [:]))
    }
}
