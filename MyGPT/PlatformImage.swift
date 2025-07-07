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

    func save() {
        let fileManager = FileManager.default
        guard let url = fileManager.urls(for: .downloadsDirectory, in: .userDomainMask).first else {
            print("Unable to access Documents directory")
            return
        }
        let filename = "GeneratedImage_\(arc4random()).png"
        let fileURL = url.appendingPathComponent(filename)

        guard let data = self.data else { return }

        do {
            try data.write(to: fileURL)
            print("Image saved to: \(fileURL)")
        } catch {
            print("Error saving image: \(error)")
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



