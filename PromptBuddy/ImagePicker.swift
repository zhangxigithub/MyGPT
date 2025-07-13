//
//  ImagePicker.swift
//  SidGPT
//
//  Created by Sid on 1/7/2025.
//
import SwiftUI
import PhotosUI
import ChatGPT

struct ImagePicker: View {
    
    @State var pickerItems = [PhotosPickerItem]()
    @Binding var selectedImages: [PlatformImage]
    
    var body: some View {
        PhotosPicker(selection: $pickerItems, maxSelectionCount: nil, matching: .images) {
            Image(systemName: "photo")
        }
        .onChange(of: pickerItems) { _, newItems in
            Task {
                var images = [PlatformImage]()
                for item in newItems {
                    if let image = try? await item.image() {
                        images.append(image)
                    }
                }
                print(">>>??? \(images.count)")
                Task { @MainActor in
                    selectedImages = images
                }
            }
        }
    }
}

extension PhotosPickerItem {
    @MainActor
    func image() async throws -> PlatformImage? {
        guard let data = try await loadTransferable(type: Data.self) else { return nil }
        return PlatformImage(data: data)
    }
}
