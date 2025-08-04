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

    // Pool of congratulatory messages
    let congratulatoryMessages = [
        "Section complete!",
        "Nice work!",
        "Well done!",
        "Keep it up!",
        "Great focus!",
        "Finished!",
        "Good job!"
    ]

    // Final completion messages for when all sessions are done
    let finalCompletionMessages = [
        "All sessions complete!",
        "Great work today!",
        "You did it!",
        "Sessions finished!",
        "Well done!",
        "All done!"
    ]

    func applicationDidFinishLaunching(_ notification: Notification) {
        loadCurrentSession()
        notch = DynamicNotch(
            hoverBehavior: .all,
            style: .notch,
            expanded: {
                ExpandedNotchView(
                    state: self.focusState,
                    timerModel: self.timerModel,
                    appDelegate: self
                )
            },
            compactLeading: { CompactSessionView(state: self.focusState) },
            compactTrailing: { CompactTimerView(timerModel: self.timerModel) }
        )
        Task { await notch?.compact() }
    }

    func loadCurrentSession() {
        print("🔄 Loading current session...")
        
        // Always clear any existing timer state first
        timerModel.pause()
        timerModel.onCompletion = nil
        
        // Check if we have a current session
        guard let session = focusState.currentSession else {
            print("❌ No current session found")
            timerModel.reset(to: 0)
            return
        }
        
        print("✅ Loading session: \(session.title) (\(session.length)s)")
        
        // Reset timer for the current session
        timerModel.reset(to: session.length)
        
        // Set up completion handler
        timerModel.onCompletion = { [weak self] in
            print("⏰ Timer completed!")
            self?.handleSessionCompletion()
        }
        
        print("🎯 Timer reset to \(session.length)s, ready to start")
    }
    
    private func handleSessionCompletion() {
        print("🎉 Handling session completion...")
        
        // Mark the current session as complete (removes it from the array)
        focusState.markSessionComplete()
        print("✅ Session marked complete, \(focusState.sessions.count) sessions remaining")
        
        // ALWAYS show the notification, whether there are more sessions or not
        if focusState.currentSession != nil {
            // More sessions remaining
            print("➡️ Next session available")
            focusState.notificationMessage = congratulatoryMessages.randomElement() ?? "Section complete!"
        } else {
            // All sessions complete!
            print("🏁 All sessions complete!")
            focusState.notificationMessage = finalCompletionMessages.randomElement() ?? "All sessions complete!"
        }
        
        // Show notification in both cases
        focusState.showNotification = true
        
        // Expand the notch to show notification
        Task {
            await notch?.expand()
        }
    }
    
    // This method should be called when the notification is dismissed
    func notificationDismissed() {
        print("🔔 Notification dismissed, loading next session...")
        
        // If there are no more sessions, just reset the timer to 0 and clear completion
        if focusState.currentSession == nil {
            print("🏁 No more sessions, resetting timer to 0")
            timerModel.reset(to: 0)
            timerModel.onCompletion = nil
        } else {
            // Load the next session normally
            loadCurrentSession()
        }
    }
}
