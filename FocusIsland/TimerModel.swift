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
        guard !isRunning, secondsRemaining > 0 else { return }
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

    func reset(to seconds: Int? = nil) {
        pause()
        if let s = seconds {
            totalDuration = s
            secondsRemaining = s
        } else {
            secondsRemaining = totalDuration
        }
    }

    private func tick() {
        guard secondsRemaining > 0 else {
            pause()
            onCompletion?()
            return
        }
        secondsRemaining -= 1
        if secondsRemaining == 0 {
            pause()
            onCompletion?()
        }
    }

    deinit {
        pause()
    }
}
