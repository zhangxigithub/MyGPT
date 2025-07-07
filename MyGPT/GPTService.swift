//
//  GPTService.swift
//  MyGPT
//
//  Created by Me on 6/7/2025.
//
import Foundation

class GPTService {
    
    let settings: AppSettings
    
    init(settings: AppSettings) {
        self.settings = settings
    }
    
    @MainActor
    func chat(with conversation: Conversation, message: String, search: Bool, inputImages: [PlatformImage] = []) async throws {
        
        let previousResponseId = conversation.messages.last?.responseId

        let api = GPTAPI(settings: settings)
        
        do {
            let response = try await api.createResponse(message: message,
                                                        previousResponseId: previousResponseId,
                                                        developer: settings.developer,
                                                        tools: search ? [ChatTool(type: "web_search_preview")] : nil,
                                                        images: inputImages)
            
            let storedMessage = Message(user: message, gpt: response.message, inputImageData: inputImages.compactMap { $0.data }, outputImageData: [])
            storedMessage.responseId = response.id
            conversation.messages.append(storedMessage)
        } catch let error as URLError  {
            let nsError = error as NSError
            if nsError.domain == NSURLErrorDomain {
                if nsError.domain == NSURLErrorDomain {
                    switch nsError.code {
                    case NSURLErrorNetworkConnectionLost, NSURLErrorTimedOut, NSURLErrorCannotFindHost, NSURLErrorCannotConnectToHost, NSURLErrorNotConnectedToInternet:
                        try? await Task.sleep(nanoseconds: 1_000_000_000)
                        try await chat(with: conversation, message: message, search: search, inputImages: inputImages)
                    default:
                        break
                    }
                }
            }
        } catch {
            throw error
        }
    }
    
    @MainActor
    func generateImage(with conversation: Conversation, message: String, inputImages: [PlatformImage] = []) async throws {
        do {
            let api = GPTAPI(settings: settings)

            let outputImages: [PlatformImage]
            if !inputImages.isEmpty {
                let response = try await api.editImage(prompt: message,
                                                       size: settings.size,
                                                       quality: settings.quality,
                                                       background: settings.background,
                                                       number: settings.number,
                                                       images: inputImages)
                outputImages = response.images
            } else {
                let response = try await api.generateImage(prompt: message,
                                                           size: settings.size,
                                                           quality: settings.quality,
                                                           background: settings.background,
                                                           number: settings.number)
                outputImages = response.images
            }

            if !outputImages.isEmpty {
                let storedMessage = Message(user: message, gpt: "Images:", inputImageData: inputImages.compactMap { $0.data }, outputImageData: outputImages.compactMap { $0.data })
                conversation.messages.append(storedMessage)
            }
        } catch let error as URLError  {
            let nsError = error as NSError
            if nsError.domain == NSURLErrorDomain {
                if nsError.domain == NSURLErrorDomain {
                    switch nsError.code {
                    case NSURLErrorNetworkConnectionLost, NSURLErrorTimedOut, NSURLErrorCannotFindHost, NSURLErrorCannotConnectToHost, NSURLErrorNotConnectedToInternet:
                        try? await Task.sleep(nanoseconds: 1_000_000_000)
                        try await generateImage(with: conversation, message: message, inputImages: inputImages)
                    default:
                        break
                    }
                }
            }
        } catch {
            throw error
        }
    }
}
