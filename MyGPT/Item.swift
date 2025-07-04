//
//  Item.swift
//  MyGPT
//
//  Created by Me on 4/7/2025.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
