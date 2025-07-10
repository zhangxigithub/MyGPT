//
//  PlatformImage.swift
//  SidGPT
//
//  Created by Sid on 2/6/2025.
//

import SwiftUI
import PhotosUI

#if os(macOS)
import AppKit
typealias PlatformImage = NSImage

extension PlatformImage {
    var data: Data? {
        guard let tiffRep = self.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffRep),
              let pngData = bitmap.representation(using: .png, properties: [:])
        else { return nil }
        return pngData
    }

    var imageView: Image {
        Image(nsImage: self)
    }

    @MainActor
    func save() {
        guard let data = self.data else { return }

        let panel = NSSavePanel()
        panel.nameFieldStringValue = "Image.png"

        panel.begin { response in
            Task { @MainActor in
                if response == .OK, let url = panel.url {
                    do {
                        try data.write(to: url)
                        print("Image saved to \(url)")
                    } catch {
                        print("Failed to save image: \(error)")
                    }
                }
            }
        }
    }
}
#else
import UIKit
typealias PlatformImage = UIImage

extension PlatformImage {
    var data: Data? {
        return self.pngData()
    }

    var imageView: Image {
        Image(uiImage: self)
    }

    func save() {
        UIImageWriteToSavedPhotosAlbum(self, nil, nil, nil)
    }
    
}

#endif



