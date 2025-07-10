//
//  ImageResponse.swift
//  PromptBuddy
//
//  Created by Me on 5/7/2025.
//
import SwiftUI

struct ImageResponse: Decodable {
    let data: [ImageResponseData]
    
    var images: [PlatformImage] {
        data.compactMap { item -> PlatformImage? in
            guard let imageData = item.imageData else { return nil }

            #if os(macOS)
            return NSImage(data: imageData)
            #else
            return UIImage(data: imageData)
            #endif
        }
    }
}

struct ImageResponseData: Decodable {
    let b64_json: String
    var imageData: Data? {
        return Data(base64Encoded: b64_json)
    }
}

enum ImageSize: String, CaseIterable, Identifiable {
    case square = "1024x1024"
    case landscape = "1536x1024"
    case portrait = "1024x1536"
    case auto = "auto"

    var id: String { self.rawValue }

    var name: String {
        switch self {
        case .square: return "Square"
        case .landscape: return "Landscape"
        case .portrait: return "Portrait"
        case .auto: return "Auto"
        }
    }
}

enum ImageQuality: String, CaseIterable, Identifiable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case auto = "auto"

    var id: String { self.rawValue }
}

enum ImageBackground: String, CaseIterable, Identifiable {
    case transparent = "transparent"
    case opaque = "opaque"
    case auto = "auto"

    var id: String { self.rawValue }
}
