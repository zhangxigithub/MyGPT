//
//  AppSettings.swift
//  MyGPT
//
//  Created by Me on 5/7/2025.
//


import Foundation
import SwiftUI
import Combine

@MainActor
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
    
    
    let keychainManager = KeychainAPIKeyManager()
    init() {
        apiKeys = keychainManager.getAllAPIKeys()

        if apiKey != "" {
            // Bypass swift6 issue
            let safeApiKey = apiKey
            Task {
                let fetchedModels = try await GPTAPI.models(apiKey: safeApiKey)
                await MainActor.run {
                    self.models = fetchedModels
                }
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
        keychainManager.deleteAPIKey(id: key.id)
        self.apiKeys = keychainManager.getAllAPIKeys()
    }
    
    func addAPIKey(name: String, key: String) {
        keychainManager.getAllAPIKeys().forEach {
            keychainManager.setAPIKeyEnabled(id: $0.id, isEnabled: false)
        }
        let key = StoredAPIKey(name: name, key: key, isEnabled: true)
        keychainManager.saveAPIKey(key)
        
        self.apiKeys = keychainManager.getAllAPIKeys()
    }
    
    func enableAPIKey(key: StoredAPIKey) {
        let keys = keychainManager.getAllAPIKeys()
        keys.forEach {
            if $0.id == key.id {
                keychainManager.setAPIKeyEnabled(id: key.id, isEnabled: true)
            } else {
                keychainManager.setAPIKeyEnabled(id: $0.id, isEnabled: false)
            }
        }
        self.apiKeys = keychainManager.getAllAPIKeys()
    }
}

