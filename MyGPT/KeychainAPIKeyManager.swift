//
//  KeychainAPIKeyManager.swift
//  MyGPT
//
//  Created by Me on 6/7/2025.
//
import Foundation

struct StoredAPIKey: Identifiable, @MainActor Codable, Hashable {
    let id: String                  // UUID used as key
    var name: String               // User-defined name (can change)
    var key: String              // API Key
    var isEnabled: Bool            // Enabled flag

    init(name: String, key: String, isEnabled: Bool) {
        self.id = UUID().uuidString
        self.name = name
        self.key = key
        self.isEnabled = isEnabled
    }
}

final class KeychainAPIKeyManager {
    static let shared = KeychainAPIKeyManager()
    private init() {}

    private let service = "sidzhang.MyGPT"
    private let classType = kSecClassGenericPassword


    // Save API Key (create or update)
    func saveAPIKey(_ key: StoredAPIKey) {
        guard let data = try? JSONEncoder().encode(key) else { return }

        let query: [String: Any] = [
            kSecClass as String: classType,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.id,
            kSecValueData as String: data
        ]

        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    // Get key by ID
    func getAPIKey(id: String) -> StoredAPIKey? {
        let query: [String: Any] = [
            kSecClass as String: classType,
            kSecAttrService as String: service,
            kSecAttrAccount as String: id,
            kSecReturnData as String: true,
            kSecMatchLimit as String: 1
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        if status != errSecSuccess {
            let message = SecCopyErrorMessageString(status, nil)
            print("Failed to get key: \(status) message: \(String(describing: message))")
        }
        guard status == errSecSuccess, let data = result as? Data else { return nil }

        return try? JSONDecoder().decode(StoredAPIKey.self, from: data)
    }

    func getAllAPIKeys() -> [StoredAPIKey] {
        let query: [String: Any] = [
            kSecClass as String: classType,
            kSecAttrService as String: service,
            kSecReturnData as String: true,
            kSecReturnAttributes as String: true,
            kSecMatchLimit as String: 99
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        if status != errSecSuccess {
            let message = SecCopyErrorMessageString(status, nil)
            print("Failed to get all keys: \(status) message: \(String(describing: message))")
        }
        guard status == errSecSuccess, let items = result as? [[String: Any]] else { return [] }
        return items.compactMap { item in
            guard let data = item[kSecValueData as String] as? Data else { return nil }
            return try? JSONDecoder().decode(StoredAPIKey.self, from: data)
        }
    }

    // Delete by ID
    func deleteAPIKey(id: String) {
        let query: [String: Any] = [
            kSecClass as String: classType,
            kSecAttrService as String: service,
            kSecAttrAccount as String: id
        ]
        SecItemDelete(query as CFDictionary)
    }

    // Toggle enable
    func setAPIKeyEnabled(id: String, isEnabled: Bool) {
        guard var key = getAPIKey(id: id) else { return }
        key.isEnabled = isEnabled
        saveAPIKey(key)
    }
}
