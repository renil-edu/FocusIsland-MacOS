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
    let timerModel = TimerModel(sessionDuration: 15)
    var notch: DynamicNotch<ExpandedNotchView, CompactSessionView, CompactTimerView>?

    func applicationDidFinishLaunching(_ notification: Notification) {
        loadCurrentSession()
        notch = DynamicNotch(
            hoverBehavior: .all,
            style: .notch,
            expanded: { ExpandedNotchView(state: self.focusState, timerModel: self.timerModel) },
            compactLeading: { CompactSessionView(state: self.focusState) },
            compactTrailing: { CompactTimerView(timerModel: self.timerModel) }
        )
        Task { await notch?.compact() }
    }

    private func loadCurrentSession() {
        guard let session = focusState.currentSession else { return }
        timerModel.reset(to: session.length)
        timerModel.start()
        timerModel.onCompletion = { [weak self] in
            guard let self = self else { return }
            self.focusState.markSessionComplete()
            // Do NOT increment currentSessionIndex.
            // The new current session is now at the same index (0), or none left if all are done.
            if let newSession = self.focusState.currentSession {
                self.loadCurrentSession() // Keep going if more sessions remain
            }
            // Optionally: handle "all complete" UI if self.focusState.currentSession == nil
        }
    }
}
