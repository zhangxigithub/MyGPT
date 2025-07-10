//
//  Conversation.swift
//  PromptBuddy
//
//  Created by Me on 5/7/2025.
//

import Foundation
import SwiftData
import Combine
#if os(macOS)
import AppKit
#else
import UIKit
#endif

@Model
final class Conversation {
    var date: Date
    var messages: [Message]
    
    init() {
        date = Date()
        messages = [Message]()
    }
}


@Model
final class Message {
    var user: String
    var gpt: String = ""
    var responseId: String?

    @Attribute(.externalStorage) var inputImageData: [Data]
    @Attribute(.externalStorage) var outputImageData: [Data]

    
    init(user: String, gpt: String, inputImageData: [Data], outputImageData: [Data]) {
        self.user = user
        self.gpt = gpt
        self.inputImageData = inputImageData
        self.outputImageData = outputImageData
    }
    
    var inputImages: [PlatformImage] {
        inputImageData.compactMap {
        #if os(macOS)
            NSImage(data: $0)
        #else
            UIImage(data: $0)
        #endif
        }
    }
    
    var outputImages: [PlatformImage] {
        outputImageData.compactMap {
        #if os(macOS)
            NSImage(data: $0)
        #else
            UIImage(data: $0)
        #endif
        }
    }
    
    var isProbablyMarkdown: Bool {
        let markdownPatterns: [String] = [
            #"^#{1,6} .+"#,            // Headings like # H1, ## H2
            #"\*\*.+?\*\*"#,           // Bold **text**
            #"\*.+?\*"#,               // Italic *text*
            #"\[.*?\]\(.*?\)"#,        // Links [text](url)
            #"!\[.*?\]\(.*?\)"#,       // Images ![alt](url)
            #"[-*+] .+"#,              // Unordered lists
            #"^\d+\. .+"#,             // Ordered lists
            #"`{1,3}.+?`{1,3}"#,       // Inline or fenced code
            #"^> .+"#                  // Blockquotes
        ]
        
        for pattern in markdownPatterns {
            if let _ = gpt.range(of: pattern, options: .regularExpression) {
                return true
            }
        }
        
        return false
    }
}
