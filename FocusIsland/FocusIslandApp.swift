//
//  FocusIslandApp.swift
//  FocusIsland
//
//  Created by UT Austin on 8/2/25.
//


import SwiftUI
import DynamicNotchKit

@main
struct FocusIslandApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings { EmptyView() }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    let focusState = FocusIslandState(sessions: [
        FocusSession(title: "Homework 1", length: 15),
        FocusSession(title: "Resume Polishing", length: 10),
        FocusSession(title: "Coding Project", length: 10),
        FocusSession(title: "Break", length: 5)
    ])
    // Hold one TimerModel always
    let timerModel = TimerModel(sessionDuration: 15)
    var notch: DynamicNotch<ExpandedNotchView, CompactSessionView, CompactTimerView>?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Setup the timer for the first session
        loadCurrentSession()
        // Set up the window only ONCE!
        notch = DynamicNotch(
            hoverBehavior: .all,
            style: .notch,
            expanded: { ExpandedNotchView(state: self.focusState, timerModel: self.timerModel) },
            compactLeading: { CompactSessionView(state: self.focusState) },
            compactTrailing: { CompactTimerView(timerModel: self.timerModel) }
        )
        Task { await notch?.compact() }
    }

    /// Loads correct timer state for the current session and wires completion logic
    private func loadCurrentSession() {
        guard let session = focusState.currentSession else { return }
        // Reset timer to the correct new duration
        timerModel.reset(to: session.length)
        timerModel.start()
        timerModel.onCompletion = { [weak self] in
            guard let self = self else { return }
            self.focusState.markSessionComplete()
            let nextIdx = self.focusState.currentSessionIndex + 1
            if nextIdx < self.focusState.sessions.count {
                // Advance session index & reset timer for new session
                self.focusState.currentSessionIndex = nextIdx
                self.loadCurrentSession()
            }
            // Otherwise, all sessions complete; optionally show 'Done!' or handle as you prefer
        }
    }
}
