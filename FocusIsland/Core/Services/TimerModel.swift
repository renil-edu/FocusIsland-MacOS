//
//  TimerModel.swift
//  FocusIsland
//
//  Created by UT Austin on 8/3/25.
//

import Foundation

class TimerModel: ObservableObject {
    @Published var secondsRemaining: Int
    @Published var isRunning: Bool = false
    private(set) var totalDuration: Int

    private var timer: Timer?
    var onCompletion: (() -> Void)?

    var progress: Double {
        totalDuration == 0 ? 1.0 : 1.0 - Double(secondsRemaining) / Double(totalDuration)
    }

    var timeDisplay: String {
        String(format: "%d:%02d", secondsRemaining / 60, secondsRemaining % 60)
    }

    init(sessionDuration: Int) {
        self.totalDuration = sessionDuration
        self.secondsRemaining = sessionDuration
    }

    func start() {
        print("🚀 Timer start() called - isRunning: \(isRunning), secondsRemaining: \(secondsRemaining)")
        guard !isRunning, secondsRemaining > 0 else {
            print("❌ Timer start() blocked - already running or no time left")
            return
        }
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.tick()
        }
        print("✅ Timer started successfully")
    }

    func pause() {
        print("⏸️ Timer pause() called")
        isRunning = false
        timer?.invalidate()
        timer = nil
        print("✅ Timer paused successfully")
    }

    func reset(to seconds: Int? = nil) {
        print("🔄 Timer reset() called with seconds: \(seconds ?? -1)")
        
        // Always pause first to clean up any existing timer
        pause()
        
        if let s = seconds {
            totalDuration = s
            secondsRemaining = s
        } else {
            secondsRemaining = totalDuration
        }
        
        print("✅ Timer reset to \(secondsRemaining) seconds")
        
        // Force UI update on main thread
        DispatchQueue.main.async { [weak self] in
            self?.objectWillChange.send()
        }
    }

    private func tick() {
        guard secondsRemaining > 0 else {
            print("⏰ Timer tick() - time's up!")
            pause()
            onCompletion?()
            return
        }
        secondsRemaining -= 1
        if secondsRemaining == 0 {
            print("⏰ Timer tick() - reached zero!")
            pause()
            onCompletion?()
        }
    }

    deinit {
        pause()
    }
}
