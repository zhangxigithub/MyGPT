//
//  InputTextField.swift
//  SidGPT
//
//  Created by Sid on 24/6/2025.
//
import SwiftUI
import SwiftData
import ChatGPT

struct InputTextField: View {

    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var settings: AppSettings
    
    @State var input = ""
    @State var loading = false
    @StateObject var stopwatch = StopwatchModel()
    @Binding var selectedImages: [PlatformImage]
    @State var errorMessage: String?
    var conversation: Conversation
    
    
    @Query private var quickActions: [QuickAction]
    
    
    @State var search = false
    @State var image = false

    var body: some View {
        VStack(alignment: .leading) {
            if let errorMessage {
                Text(errorMessage)
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.red)
            }
            
            HStack {
                HStack {
                    Toggle("Search", isOn: $search)
                        .toggleStyle(.button)
                    Toggle("Image", isOn: $image)
                        .toggleStyle(.button)
                    
                    if quickActions.count <= 2 {
                        ForEach(quickActions) { action in
                            Button(action.name) {
                                let message = action.prompt + "\n" + input
                                Task {
                                    await chat(message: message)
                                }
                            }
                            .tint(.orange)
                        }
                    } else {
                        Menu {
                            ForEach(quickActions) { action in
                                Button(action.name) {
                                    let message = action.prompt + "\n" + input
                                    Task {
                                        await chat(message: message)
                                    }
                                }
                            }
                        } label: {
                            Label("Quick Actions", systemImage: "bolt.fill")
                                .labelStyle(.titleAndIcon)
                                .tint(.orange)
                                .padding(.horizontal)
                        }
                    }
                }
                .padding(4)
                .glassEffectIfAvailable()
                
                Spacer()
                
                if !selectedImages.isEmpty {
                    ImagesView(images: selectedImages)
                        .disabled(true)
                        .padding(.trailing, 90)
                }
            }
            .frame(maxWidth: .infinity)

            
            HStack(alignment: .bottom) {
                TextEditor(text: $input)
                    .lineLimit(1...10)
                    .frame(maxHeight: .infinity)
                    .textFieldStyle(.plain)
                    .padding()
                    .scrollContentBackground(.hidden)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 18))

                if loading {
                    ProgressView {
                        Text(Date(timeIntervalSinceReferenceDate: stopwatch.elapsedTime),
                             format: .dateTime.minute().second())
                    }
                    .frame(width: 50)
                } else {
                    Button {
                        if settings.apiKey.isEmpty {
                            errorMessage = "API Key is required. Please go to the settings (top right) and add a valid API Key."
                            return
                        }
                        Task {
                            if image {
                                await image()
                            } else {
                                await chat(message: input)
                            }
                        }
                    } label: {
                        Image(systemName: "paperplane.fill")
                            .frame(width: 50)
                            .frame(maxHeight: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .frame(height: 80)
        }
    }
    
    
    func chat(message: String) async {
        errorMessage = nil
        loading = true
        stopwatch.start()
        defer {
            stopwatch.stop()
            loading = false
        }
        
        do {
            let id = conversation.messages.last?.responseId
            let api = GPTAPI(settings: settings)

            let response = try await api.chat(previousResponseId: id,
                                              developer: settings.developer,
                                              message: message,
                                              search: search,
                                              inputImages: selectedImages)
            
            let responseMessage = Message(user: message, gpt: response.message, inputImageData: selectedImages.compactMap { $0.data }, outputImageData: [])
            conversation.messages.append(responseMessage)
            
            selectedImages.removeAll()
            input = ""
        } catch GPTAPIError.error(let errorMessage) {
            self.errorMessage = errorMessage
        } catch  {
            self.errorMessage = error.localizedDescription
        }

    }
    
    func image() async {
        errorMessage = nil
        loading = true
        stopwatch.start()
        defer {
            stopwatch.stop()
            loading = false
        }
        do {
            let api = GPTAPI(settings: settings)
            let response = try await api.generateImage(message: input, inputImages: selectedImages)
            let responseMessage = Message(user: input, gpt: "Images", inputImageData: selectedImages.compactMap { $0.data }, outputImageData: response.images.compactMap { $0.data })
            conversation.messages.append(responseMessage)
            selectedImages.removeAll()
            input = ""
        } catch GPTAPIError.error(let errorMessage) {
            self.errorMessage = errorMessage
        } catch  {
            self.errorMessage = error.localizedDescription
        }
    }
}




extension View {
    @ViewBuilder
    func glassEffectIfAvailable() -> some View {
#if os(iOS)
        if #available(iOS 26.0, *) {
            // Waiting for Xcode 26
            // self.glassEffect()
            self
        } else {
            self
        }
#else
        self
#endif
    }
}
