//
//  NewQuickActionView.swift
//  PromptBuddy
//
//  Created by Me on 16/7/2025.
//
import SwiftUI
import SwiftData

struct NewQuickActionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var prompt = ""
    
    var addNewAction: (String, String) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("New Quick Action")
                .font(.headline)
            TextField("Name", text: $name)
                .textFieldStyle(.roundedBorder)
            TextField("Prompt", text: $prompt)
                .textFieldStyle(.roundedBorder)
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                Spacer()
                Button("Confirm")
                {
                    addNewAction(name, prompt)
                }
                .disabled(name.isEmpty || prompt.isEmpty)
            }
        }
        .padding()
        .presentationDetents([.medium, .large])
    }
}
