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
        }
        .formStyle(.grouped)
        .navigationTitle("Settings")
    }
}
