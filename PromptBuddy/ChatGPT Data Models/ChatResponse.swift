//
//  ChatResponse.swift
//  PromptBuddy
//
//  Created by Me on 5/7/2025.
//

import Foundation

struct ChatResponse: Decodable {

    let id: String
    let error: ChatError?
    let output: [ResponseMessage]?

    var message: String {
        var content = ""

        output?.forEach {
            switch $0.type {
            case "reasoning":
                if $0.summary?.isEmpty == false {
                    content += "Reasoning:\n"
                    $0.summary?.forEach {
                        content += "[\($0.type)]:\n\($0.text ?? "")"
                    }
                    content += "\n"
                }
            case "message":
                $0.content?.forEach {
                    content += "\($0.text ?? "")\n"
                }
            default:
                break
            }
        }
        return content
    }
}

struct ResponseMessage: Decodable {
    let type: String
    let status: String?
    let content: [ResponseContent]?
    let summary: [ResponseContent]?
}

struct ResponseContent: Decodable {
    let type: String
    let text: String?
}

struct ChatRequest: Codable {
    let model: String
    let input: [ChatMessage]
    let previous_response_id: String?
    let tools: [ChatTool]?

    init(model: String,
         input: [ChatMessage],
         previous_response_id: String? = nil,
         tools: [ChatTool]? = nil) {
        self.model = model
        self.input = input
        self.tools = tools
        self.previous_response_id = previous_response_id
    }

}

struct ChatTool: Codable {
    let type: String
}

struct ChatMessage: Codable {
    let role: String // "developer", "user", or "assistant"
    let content: [ChatMessageContent]

    init(developer: String) {
        role = "developer"
        content = [ChatMessageContent(text: developer)]
    }

    init(user message: String) {
        role = "user"
        self.content = [ChatMessageContent(text: message)]
    }

    init(user content: [ChatMessageContent]) {
        role = "user"
        self.content = content
    }
}

struct ChatMessageContent: Codable {
    let type: String
    var text: String?
    var image_url: String?

    init(image: PlatformImage) {
        type = "input_image"
        if let pngData = image.data {
            image_url = "data:image/png;base64,\(pngData.base64EncodedString())"
        }
    }

    init(text: String) {
        type = "input_text"
        self.text = text
        self.image_url = nil
    }
}

struct ModelResponse: Decodable {
    let data: [ModelResponseItem]
    let error: ChatError?
}

struct ModelResponseItem: Decodable {
    let id: String
    let created: Int
}

struct ChatError: Decodable {
    let message: String
}


struct ErrorResponse: Decodable {
    let error: ChatError
    
    var apiError: GPTAPIError {
        .error(error.message)
    }
}

enum GPTAPIError: Error {
    case error(String)
}
