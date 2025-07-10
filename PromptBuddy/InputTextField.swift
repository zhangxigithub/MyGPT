//
//  File.swift
//  SidGPT
//
//  Created by Sid on 24/6/2025.
//
import SwiftUI

struct InputTextField: View {

    @EnvironmentObject var settings: AppSettings
    
    @State var input = ""
    @State var loading = false
    @StateObject var stopwatch = StopwatchModel()
    @Binding var selectedImages: [PlatformImage]
    @State var errorMessage: String?
    var conversation: Conversation
    
    
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
                                await chat()
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
    
    
    func chat() async {
        errorMessage = nil
        loading = true
        stopwatch.start()
        defer {
            stopwatch.stop()
            loading = false
        }
        let service = GPTService(settings: settings)
        do {
            try await service.chat(with: conversation, message: input, search: search, inputImages: selectedImages)
        } catch GPTAPIError.error(let errorMessage) {
            self.errorMessage = errorMessage
        } catch  {
            self.errorMessage = error.localizedDescription
        }
        selectedImages.removeAll()
        input = ""
    }
    
    func image() async {
        errorMessage = nil
        loading = true
        stopwatch.start()
        defer {
            stopwatch.stop()
            loading = false
        }
        let service = GPTService(settings: settings)
        do {
            try await service.generateImage(with: conversation, message: input, inputImages: selectedImages)
        } catch GPTAPIError.error(let errorMessage) {
            self.errorMessage = errorMessage
        } catch  {
            self.errorMessage = error.localizedDescription
        }
        selectedImages.removeAll()
        input = ""
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
