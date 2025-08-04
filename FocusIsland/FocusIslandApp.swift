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
    var body: some Scene { Settings { EmptyView() } }
}

final class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {

    // MARK: — Core singleton models
    let settings  = FocusSettings.load()
    lazy var state: FocusIslandState = {
        FocusIslandState(
            goals: [
                Goal(title: "Homework 1",     minutes: 60),
                Goal(title: "Coding Project", minutes: 30),
                Goal(title: "Resume Fixing",  minutes: 20)
            ],
            settings: settings
        )
    }()
    let timerModel = TimerModel(sessionDuration: 1)

    // MARK: — UI (Dynamic Notch)
    var notch: DynamicNotch<ExpandedNotchView,
                            CompactSessionView,
                            CompactTimerView>?

    // MARK: — Messages
    private let congrats = [
        "Section complete!", "Nice work!", "Well done!",
        "Keep it up!", "Great focus!", "Finished!", "Good job!"
    ]
    private let finals = [
        "All sessions complete!", "Great work today!",
        "You did it!", "Sessions finished!",
        "Well done!", "All done!"
    ]

    // MARK: — Launch
    func applicationDidFinishLaunching(_ n: Notification) {
        loadCurrentSession()
        notch = DynamicNotch(
            hoverBehavior: .all,
            style: .notch,
            expanded: { ExpandedNotchView(state: self.state,
                                          timerModel: self.timerModel,
                                          appDelegate: self) },
            compactLeading: { CompactSessionView(state: self.state) },
            compactTrailing: { CompactTimerView(timerModel: self.timerModel) }
        )
        Task { await notch?.compact() }
    }

    // MARK: — Session lifecycle
    func loadCurrentSession() {
        timerModel.pause()
        timerModel.onCompletion = nil

        guard let session = state.currentSession else {
            timerModel.reset(to: 0)
            return
        }
        timerModel.reset(to: session.length)
        timerModel.onCompletion = { [weak self] in self?.handleCompletion() }
    }

    private func handleCompletion() {
        state.markSessionComplete()

        // Decide message
        state.notificationMessage = state.currentSession == nil
            ? finals.randomElement()!
            : congrats.randomElement()!
        state.showNotification = true
        Task { await notch?.expand() }
    }

    func notificationDismissed() {
        if state.currentSession == nil {
            timerModel.reset(to: 0)
            timerModel.onCompletion = nil
        } else {
            loadCurrentSession()
        }
    }
}
