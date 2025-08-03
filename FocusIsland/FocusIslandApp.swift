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
    // Supply all 3 views to DynamicNotch
    var notch: DynamicNotch<ExpandedNotchView, CompactSessionView, CompactTimerView>?
    
    

    func applicationDidFinishLaunching(_ notification: Notification) {
        notch = DynamicNotch(
            hoverBehavior: .all,
            style: .notch,
            expanded: { ExpandedNotchView() },
            compactLeading: { CompactSessionView() },
            compactTrailing: { CompactTimerView() }
        )
        // Delay compact mode to ensure window is fully ready
        Task {
            try? await Task.sleep(nanoseconds: 350_000_000)   // 350ms
            await notch?.compact()
        }
    }

}
