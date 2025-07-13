//
//  SettingsView.swift
//  SidGPT
//
//  Created by Sid on 29/6/2025.
//

import SwiftUI
import SwiftData
import ChatGPT

struct SettingsView: View {

    @EnvironmentObject var settings: AppSettings
    @Environment(\.modelContext) private var modelContext
    @Query private var quickActions: [QuickAction]
    @State private var showingAddQuickAction = false
    
    var body: some View {
        Form {
            Section("API Keys") {
                ForEach($settings.apiKeys) { $key in
                    Toggle(key.name, isOn: $key.isEnabled)
                        .onChange(of: key.isEnabled) { oldValue, newValue in
                            if newValue == true {
                                settings.enableAPIKey(key: key)
                            }
                        }
                }.onDelete { indexSet in
                    if let index = indexSet.first {
                        let key = settings.apiKeys[index]
                        settings.deleteAPIKey(key: key)
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
                    VStack(alignment: .leading) {
                        Text(action.name)
                            .bold()
                        Text(action.prompt)
                            .foregroundStyle(.secondary)
                    }
                }
                .onDelete { indexSet in
                    if let index = indexSet.first {
                        let action = quickActions[index]
                        modelContext.delete(action)
                        try? modelContext.save()
                    }
                }
                
                Button("Add") {
                    showingAddQuickAction = true
                }
                .sheet(isPresented: $showingAddQuickAction) {
                    NewQuickActionView { name, prompt in
                        let action = QuickAction(name: name, prompt: prompt)
                        modelContext.insert(action)
                        try? modelContext.save()
                        showingAddQuickAction = false
                    }
                }
            } header: {
                Text("Quick Action")
            } footer: {
                Text("When you tap a Quick Action, the prompt will be combined with the input text. For example, if the Quick Action is \"Translate to English\" it will send \"Translate to English\" + your input text.")
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Settings")
    }
}


