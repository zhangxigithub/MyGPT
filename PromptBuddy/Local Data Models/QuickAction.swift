//
//  QuickAction.swift
//  PromptBuddy
//
//  Created by Me on 11/7/2025.
//
import Foundation
import SwiftData

@Model
final class QuickAction {
    var name: String
    var prompt: String
    
    init(name: String, prompt: String) {
        self.name = name
        self.prompt = prompt
    }
}
