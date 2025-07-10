//
//  StopwatchModel.swift
//  SidGPT
//
//  Created by Sid on 18/6/2025.
//
import SwiftUI
import Combine

@MainActor
class StopwatchModel: ObservableObject {
    // Published property to track elapsed time
    @Published var elapsedTime: TimeInterval = 0

    var timer: Timer? // Timer to update the stopwatch
    private var startTime: Date? // Reference to stop the timer


    func start() {
        // Stop and reset the stopwatch
        stop()
        elapsedTime = 0
        startTime = Date() // Set the start time
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in            
            DispatchQueue.main.async {
                if let startTime = self.startTime {
                    self.elapsedTime = Date().timeIntervalSince(startTime)
                }
            }
        }
    }

    func stop() {
        timer?.invalidate() // Stop the timer
        timer = nil
        startTime = nil
    }
}

