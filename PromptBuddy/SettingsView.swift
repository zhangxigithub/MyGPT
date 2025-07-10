//
//  SettingsView.swift
//  SidGPT
//
//  Created by Sid on 29/6/2025.
//

import SwiftUI
import SwiftData

struct SettingsView: View {

    @EnvironmentObject var settings: AppSettings
    @Environment(\.modelContext) private var modelContext
    @Query private var quickActions: [QuickAction]
    @State private var showingAddQuickAction = false
    
    var body: some View {
        Form {
            Section("API Keys") {
                ForEach($settings.apiKeys) { $key in
                    HStack {
                        Toggle(key.name, isOn: $key.isEnabled)
                            .onChange(of: key.isEnabled) { oldValue, newValue in
                                if newValue == true {
                                    settings.enableAPIKey(key: key)
                                }
                            }
                        Divider()
                        Button("Delete") {
                            settings.deleteAPIKey(key: key)
                        }
                    }
                }
                
                NavigationLink("New API Key") {
                    NewAPIKeyView()
                }
            }
            
            Section("Conversation") {
                Picker("Model", selection: $settings.selectedModel) {
                    ForEach(settings.models, id: \.self) { model in
                        Text(model).tag(model)
                    }
                }
                VStack(alignment: .leading) {
                    Text("Developer")
                    TextEditor(text: $settings.developer)
                        .frame(minHeight: 60, maxHeight: 120)
                }
            }
            
            Section("Image") {
                Picker("Size", selection: $settings.size) {
                    ForEach(ImageSize.allCases) { size in
                        Text(size.name).tag(size)
                    }
                }
                
                Picker("Quality", selection: $settings.quality) {
                    ForEach(ImageQuality.allCases) { quality in
                        Text(quality.rawValue.capitalized).tag(quality)
                    }
                }
                
                Picker("Background", selection: $settings.background) {
                    ForEach(ImageBackground.allCases) { background in
                        Text(background.rawValue.capitalized).tag(background)
                    }
                }
                
                Picker("Number", selection: $settings.number) {
                    Text("1").tag(1)
                    Text("2").tag(2)
                    Text("3").tag(3)
                    Text("4").tag(4)
                }
            }
            
            Section {
                ForEach(quickActions) { action in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(action.name)
                                .bold()
                            Text(action.prompt)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Divider()
                        Button("Delete") {
                            modelContext.delete(action)
                            try? modelContext.save()
                        }
                    }
                }
                Button("Add") {
                    showingAddQuickAction = true
                }
            } header: {
                Text("Quick Action")
            } footer: {
                Text("When you tap a Quick Action, the prompt will be combined with the input text. For example, if the Quick Action is \"Translate to English\" it will send \"Translate to English\" + your input text.")
            }
            .sheet(isPresented: $showingAddQuickAction) {
                AddQuickActionView(showingAddQuickAction: $showingAddQuickAction)
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Settings")
    }
}


struct AddQuickActionView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var newQuickActionName = ""
    @State private var newQuickActionPrompt = ""
    @Binding var showingAddQuickAction: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Text("New Quick Action")
                .font(.headline)
            TextField("Name", text: $newQuickActionName)
                .textFieldStyle(.roundedBorder)
            TextField("Prompt", text: $newQuickActionPrompt)
                .textFieldStyle(.roundedBorder)
            HStack {
                Button("Cancel") {
                    showingAddQuickAction = false
                }
                Spacer()
                Button("Confirm") {
                    let action = QuickAction(name: newQuickActionName, prompt: newQuickActionPrompt)
                    modelContext.insert(action)
                    newQuickActionName = ""
                    newQuickActionPrompt = ""
                    showingAddQuickAction = false
                    try? modelContext.save()
                }
                .disabled(newQuickActionName.isEmpty || newQuickActionPrompt.isEmpty)
            }
        }
        .padding()
        .presentationDetents([.medium, .large])
    }
}
