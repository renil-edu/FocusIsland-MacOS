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

class AppDelegate: NSObject, NSApplicationDelegate {
    let timerModel = TimerModel(sessionDuration: 20 * 60)
    var notch: DynamicNotch<ExpandedNotchView, CompactSessionView, CompactTimerView>?

    func applicationDidFinishLaunching(_ notification: Notification) {
        timerModel.start()
        notch = DynamicNotch(
            hoverBehavior: .all,
            style: .notch,
            expanded: { ExpandedNotchView(timerModel: self.timerModel) },         // << use self.timerModel
            compactLeading: { CompactSessionView() },
            compactTrailing: { CompactTimerView(timerModel: self.timerModel) }    // << use self.timerModel
        )
        Task { await notch?.compact() }
    }
}
