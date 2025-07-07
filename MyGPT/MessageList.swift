//
//  MessageList.swift
//  SidGPT
//
//  Created by Sid on 1/7/2025.
//
import SwiftUI

struct MessageList: View {
    
    @Bindable var conversation: Conversation

    var body: some View {
        ScrollViewReader { scrollProxy in
            List {
                ForEach(conversation.messages) { message in
                    UserMessageBubble(message: message)
                    ResponseMessageBubble(message: message)
                }
                Color.clear.frame(height: 1)
                    .id("bottom")
                    .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            .onChange(of: conversation.messages.count) {
                // Scroll to the bottom when messages change
                withAnimation {
                    scrollProxy.scrollTo("bottom", anchor: .bottom)
                }
            }
        }
    }
}

struct UserMessageBubble: View {
    let text: String
    let images: [PlatformImage]

    init(message: Message) {
        if message.user.count > 100 {
            self.text = String(message.user.prefix(100)) + " ..."
        } else {
            self.text = message.user
        }
        self.images = message.inputImages
    }
    var body: some View {
        VStack {
            Text(text)
                .padding(8)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(18)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.leading, 60)
                .padding(.vertical, 2)
                .textSelection(.enabled)
            HStack {
                Spacer()
                ImagesView(images: images)
            }
        }
        .listRowSeparator(.hidden)
    }
}

struct ResponseMessageBubble: View {
    let message: Message
    let images: [PlatformImage]
    
    @State var markdown: Bool = false
    @State var isProbablyMarkdown: Bool
    
    init(message: Message) {
        self.message = message
        self.images = message.outputImages
        self.isProbablyMarkdown = message.isProbablyMarkdown
    }

    var body: some View {
        VStack {
            if markdown {
                MarkdownView(markdown: message.gpt)
            } else {
                Text(message.gpt)
                    .padding(0)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.trailing, 60)
                    .padding(.vertical, 2)
                    .textSelection(.enabled)
            }
            HStack {
                ImagesView(images: images)
                Spacer()
            }
            if isProbablyMarkdown {
                HStack {
                    Toggle("Markdown", isOn: $markdown)
                        .toggleStyle(.button)
                    Spacer()
                }
            }
        }
        .listRowSeparator(.hidden)
    }
}

struct ImagesView: View {
    var images: [PlatformImage]
    
    var body: some View {
        if !images.isEmpty {
            HStack(spacing: 8) {
                ForEach(images, id: \.self) {
                    $0.imageView
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .cornerRadius(10)
                }
            }
            .frame(height: 50)
        } else {
            EmptyView()
        }
    }
}

struct MarkdownView: View {
    let markdown: String

    var body: some View {
        if let attributedString = try? AttributedString(markdown: markdown, options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)) {
            Text(attributedString)
                .textSelection(.enabled)
        } else {
            Text(markdown)
        }
    }
}
