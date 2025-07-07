//
//  ConversationView.swift
//  SidGPT
//
//  Created by Sid on 18/6/2025.
//
import SwiftUI
import SwiftData
import PhotosUI

struct ConversationView: View {
    @EnvironmentObject var settings: AppSettings
    @Environment(\.modelContext) private var modelContext
    @State var conversation: Conversation
    @State var selectedImages: [PlatformImage] = []

    var body: some View {
        NavigationStack {
            MessageList(conversation: conversation)
                .interactivelyDismissIfAvailable()
                .navigationTitle(settings.selectedModel)
                .dropDestination(for: Data.self) { items, location in
                    guard let item = items.first else { return false }
                    guard let image = PlatformImage(data: item) else { return false }
                    selectedImages.append(image)
                    return true
                }
            .safeAreaInset(edge: .bottom) {
                InputTextField(selectedImages: $selectedImages, conversation: conversation)
                .padding()
            }
            .toolbar {
                ToolbarItemGroup {
                    Button("", systemImage: "square.and.pencil") {
                        let newConversation = Conversation()
                        modelContext.insert(newConversation)
                        conversation = newConversation
                    }
                    
                    NavigationLink {
                        ConversationHistoryView {
                            conversation = $0
                        }
                    } label: {
                        Image(systemName: "clock.fill")
                    }
                    
                    ImagePicker(selectedImages: $selectedImages)
                    
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gear")
                    }
                }
            }
        }
    }
}



extension View {
    @ViewBuilder
    func interactivelyDismissIfAvailable() -> some View {
#if os(iOS)
        self.scrollDismissesKeyboard(.interactively)
#else
        self
#endif
    }
}
