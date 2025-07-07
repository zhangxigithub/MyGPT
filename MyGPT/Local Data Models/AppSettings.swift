//
//  AppSettings.swift
//  MyGPT
//
//  Created by Me on 5/7/2025.
//


import Foundation
import SwiftUI
import Combine

class AppSettings: ObservableObject {
    @Published var models: [String] = []
    @AppStorage("AppSettings.selectedModel") var selectedModel: String = ""
    @AppStorage("AppSettings.developer") var developer: String = ""
    @Published var apiKeys: [StoredAPIKey]
    
    
    // MARK: - Images
    @AppStorage("chatGPT.image.size") var size: ImageSize = .auto
    @AppStorage("chatGPT.image.quality") var quality: ImageQuality = .auto
    @AppStorage("chatGPT.image.background") var background: ImageBackground = .auto
    @AppStorage("chatGPT.image.number") var number: Int = 1
    
    init() {
        apiKeys = KeychainAPIKeyManager.shared.getAllAPIKeys()

        if apiKey != "" {
            Task {
                try await models = GPTAPI.models(apiKey: apiKey)
            }
        }
    }
}


// MARK: - API Key
extension AppSettings {
    var apiKey: String {
        apiKeys.first(where: { $0.isEnabled })?.key ?? ""
    }

    func deleteAPIKey(key: StoredAPIKey) {
        KeychainAPIKeyManager.shared.deleteAPIKey(id: key.id)
        self.apiKeys = KeychainAPIKeyManager.shared.getAllAPIKeys()
    }
    
    func addAPIKey(name: String, key: String) {
        KeychainAPIKeyManager.shared.getAllAPIKeys().forEach {
            KeychainAPIKeyManager.shared.setAPIKeyEnabled(id: $0.id, isEnabled: false)
        }
        let key = StoredAPIKey(name: name, key: key, isEnabled: true)
        KeychainAPIKeyManager.shared.saveAPIKey(key)
        
        self.apiKeys = KeychainAPIKeyManager.shared.getAllAPIKeys()
    }
    
    func enableAPIKey(key: StoredAPIKey) {
        let keys = KeychainAPIKeyManager.shared.getAllAPIKeys()
        keys.forEach {
            if $0.id == key.id {
                KeychainAPIKeyManager.shared.setAPIKeyEnabled(id: key.id, isEnabled: true)
            } else {
                KeychainAPIKeyManager.shared.setAPIKeyEnabled(id: $0.id, isEnabled: false)
            }
        }
        self.apiKeys = KeychainAPIKeyManager.shared.getAllAPIKeys()
    }
}

