//
//  NewAPIKeyView.swift
//  PromptBuddy
//
//  Created by Me on 6/7/2025.
//

import SwiftUI
import ChatGPT

struct NewAPIKeyView: View {
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var settings: AppSettings
    
    @State var apiKey: String = ""
    @State var name: String = ""
    
    @State var verifingAPIKey: Bool = false
    @State var errorMessage: String?
    
    
    
    var body: some View {
        Form {
            Section("API Key") {
                TextEditor(text: $apiKey)
                    .frame(minHeight: 60, maxHeight: 120)
            }
            Section("Name") {
                TextField("Name", text: $name)
            }
            
            Section {
                if verifingAPIKey {
                    ProgressView {
                        Text("Verifying API Key...")
                    }
                } else {
                    Button("Add") {
                        verifingAPIKey = true
                        Task {
                            defer {
                                verifingAPIKey = false
                            }
                            do {
                                let models = try await GPTAPI.models(apiKey: apiKey)
                                if !models.isEmpty {
                                    settings.addAPIKey(name: name.isEmpty ? "Key" : name, key: apiKey)
                                    settings.models = models
                                    dismiss()
                                }
                            } catch GPTAPIError.error(let errorMessage) {
                                self.errorMessage = errorMessage
                            } catch  {
                                self.errorMessage = error.localizedDescription
                            }
                        }
                    }
                }
            }
            
            if let errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
                .listRowBackground(Color.clear)
            }
        }
        .formStyle(.grouped)
    }
    
    
    func verifyAPIKey() async throws -> Bool {
        let models = try await GPTAPI.models(apiKey: apiKey)
        return models.isEmpty == false 
    }
}

