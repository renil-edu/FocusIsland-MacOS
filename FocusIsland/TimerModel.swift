//
//  TimerModel.swift
//  FocusIsland
//
//  Created by UT Austin on 8/3/25.
//


import Foundation
import Combine

class TimerModel: ObservableObject {
    @Published var secondsRemaining: Int
    @Published var isRunning: Bool = false
    
    // Total duration in seconds for this session; never changes
    let totalDuration: Int
    
    private var timer: Timer?
    
    var progress: Double {
        if totalDuration == 0 { return 1.0 }
        return 1.0 - Double(secondsRemaining) / Double(totalDuration)
    }
    
    var timeDisplay: String {
        String(format: "%d:%02d", secondsRemaining / 60, secondsRemaining % 60)
    }
    
    init(sessionDuration: Int) {
        self.totalDuration = sessionDuration
        self.secondsRemaining = sessionDuration
    }
    
    func start() {
        guard !isRunning else { return }
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }
    
    func pause() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    func reset() {
        pause()
        secondsRemaining = totalDuration
    }
    
    private func tick() {
        guard secondsRemaining > 0 else {
            pause()
            return
        }
        secondsRemaining -= 1
        if secondsRemaining == 0 {
            pause()
        }
    }
    
    deinit {
        pause()
    }
}
