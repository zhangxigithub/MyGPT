//
//  ConversationHistoryView.swift
//  MyGPT
//
//  Created by Me on 6/7/2025.
//

import SwiftUI
import SwiftData


struct ConversationHistoryView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Conversation.date, order: .reverse) private var conversations: [Conversation]
    
    var onTap: (Conversation) -> Void
    
    var body: some View {
        List {
            ForEach(conversations) { conversation in
                VStack(alignment: .leading) {
                    if let message = conversation.messages.first {
                        Text(message.user)
                            .lineLimit(2)
                        Text(message.gpt)
                            .lineLimit(2)
                    } else {
                        Text("No messages")
                    }
                    Text(conversation.date, format: .dateTime)
                        .foregroundStyle(.secondary)
                }
                .onTapGesture {
                    self.onTap(conversation)
                    dismiss()
                }
            }
            .onDelete { indexSet in
                if let index = indexSet.first {
                    let conversation = conversations[index]
                    modelContext.delete(conversation)
                    try? modelContext.save()
                }
            }
        }
    }
}
