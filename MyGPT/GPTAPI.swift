//
//  GPTAPI.swift
//  SidGPT
//
//  Created by Sid on 24/7/2023.
//

import Foundation
import SwiftUI

private let baseURL = "https://api.openai.com/v1/"

@MainActor
class GPTAPI {
    var settings: AppSettings

    init(settings: AppSettings) {
        self.settings = settings
    }

    func urlRequest(path: String, httpMethod: String = "POST") -> URLRequest {
        let urlString = baseURL + path
        let url = URL(string: urlString)!

        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.timeoutInterval = 0
        request.allHTTPHeaderFields = [
            "Content-Type" : "application/json",
            "Authorization": "Bearer \(settings.apiKey)"
        ]
        return request
    }
    
    static func requestAndHandleAPIError<T>(_ type: T.Type, from request: URLRequest) async throws -> T where T : Decodable {
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            print(String(data: data, encoding: .utf8) ?? "")
            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch let decodingError as DecodingError {
                if let apiError = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                    throw apiError.apiError
                } else {
                    throw decodingError
                }
            }
        } catch {
            print("Network or decoding error:", error)
            throw error
        }
    }

    // MARK: - Chat /response
    func createResponse(message: String,
                        previousResponseId: String? = nil,
                        developer: String? = nil,
                        tools: [ChatTool]? = [],
                        images: [PlatformImage] = []
    ) async throws -> ChatResponse {
        var request = urlRequest(path: "responses")

        var input = [ChatMessage]()
        if let developer {
            input.append(ChatMessage(developer: developer))
        }
        if !images.isEmpty {
            var content = [ChatMessageContent(text: message)]
            content.append(contentsOf: images.map { ChatMessageContent(image: $0)})
            input.append(ChatMessage(user: content))
        } else {
            input.append(ChatMessage(user: message))
        }

        let chatRequest = ChatRequest(model: settings.selectedModel, input: input, previous_response_id: previousResponseId, tools: tools)
        request.httpBody = try JSONEncoder().encode(chatRequest)

        return try await Self.requestAndHandleAPIError(ChatResponse.self, from: request)
    }
    
    // MARK: - Images
    func generateImage(prompt: String,
                       size: ImageSize = .auto,
                       quality: ImageQuality = .auto,
                       background: ImageBackground = .auto,
                       number: Int = 1
    ) async throws -> ImageResponse {

        var request = urlRequest(path: "images/generations")

        var payload: [String: Any] = [
            "model": "gpt-image-1",
            "prompt": prompt,
            "n": number
        ]

        if background != .auto {
            payload["background"] = background.rawValue
        }

        if size != .auto {
            payload["size"] = size.rawValue
        }

        if quality != .auto {
            payload["quality"] = quality.rawValue
        }

        print("Generating... \(payload))")

        let jsonData = try JSONSerialization.data(withJSONObject: payload)
        request.httpBody = jsonData

        return try await Self.requestAndHandleAPIError(ImageResponse.self, from: request)
    }

    func editImage(
        prompt: String,
        size: ImageSize = .auto,
        quality: ImageQuality = .auto,
        background: ImageBackground = .auto,
        number: Int = 1,
        images: [PlatformImage]
    ) async throws -> ImageResponse {

        var request = urlRequest(path: "images/edits")
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()

        func appendFormField(name: String, value: String) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }

        func appendFormFile(name: String, fileName: String, data: Data, mimeType: String) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
            body.append(data)
            body.append("\r\n".data(using: .utf8)!)
        }

        appendFormField(name: "model", value: "gpt-image-1")
        appendFormField(name: "prompt", value: prompt)
        appendFormField(name: "n", value: "\(number)")
        appendFormField(name: "background", value: background.rawValue)
        appendFormField(name: "size", value: size.rawValue)
        appendFormField(name: "quality", value: quality.rawValue)


        if images.count == 1 {
            appendFormFile(name: "image", fileName: "image.png", data: images[0].data!, mimeType: "image/png")
        } else {
            for i in 0..<images.count {
                appendFormFile(name: "image[]", fileName: "image_\(i).png", data: images[i].data!, mimeType: "image/png")
            }
        }

        // End the body with --boundary--
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        return try await Self.requestAndHandleAPIError(ImageResponse.self, from: request)
    }

    // MARK: - Models
    static func models(apiKey: String) async throws -> [String] {
        let url = URL(string: baseURL + "models")!
        var request = URLRequest(url: url)
        request.timeoutInterval = 30
        request.allHTTPHeaderFields = [
            "Content-Type" : "application/json",
            "Authorization": "Bearer \(apiKey)"
        ]
        
        let response = try await Self.requestAndHandleAPIError(ModelResponse.self, from: request)
        return response.data.sorted { $0.created > $1.created }.map { $0.id }
    }
}
