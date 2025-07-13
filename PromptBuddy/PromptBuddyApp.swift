//
//  PromptBuddyApp.swift
//  PromptBuddy
//
//  Created by Me on 4/7/2025.
//

import SwiftUI
import SwiftData
import ChatGPT

@main
struct PromptBuddyApp: App {
    
    let settings = AppSettings()
    let newConversation: Conversation
    let sharedModelContainer: ModelContainer

    init() {
        let schema = Schema([
            Conversation.self,
            QuickAction.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            sharedModelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            
            let descriptor = FetchDescriptor<Conversation>()
            let items = try sharedModelContainer.mainContext.fetch(descriptor)
            for item in items where item.messages.isEmpty {
                sharedModelContainer.mainContext.delete(item)
            }
            try sharedModelContainer.mainContext.save()
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }

        let context = self.sharedModelContainer.mainContext
        let newConversation = Conversation()
        context.insert(newConversation)
        self.newConversation = newConversation
    }

    var body: some Scene {
        WindowGroup {
            ConversationView(conversation: newConversation)
        }
        .environmentObject(settings)
        .modelContainer(sharedModelContainer)
    }
}

