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
        // This doesn't create a real window unless the user opens app settings.
        Settings { EmptyView() }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var notch: DynamicNotch<ContentView, EmptyView, EmptyView>?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // This is called when your app launches, before any SwiftUI scene appears
        Task { @MainActor in
            guard notch == nil else { return }
            notch = DynamicNotch(expanded: { ContentView() })
            await notch?.expand()
        }
    }
}
