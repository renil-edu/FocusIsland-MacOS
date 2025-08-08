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

    // MARK: — Status Bar
    var statusBarItem: NSStatusItem!
    
    // MARK: — Core singleton models
    let settings  = FocusSettings.load()
    lazy var state: FocusIslandState = {
        let focusState = FocusIslandState(
            goals: [
                Goal(title: "Homework 1",     minutes: 60),
                Goal(title: "Coding Project", minutes: 30),
                Goal(title: "Resume Fixing",  minutes: 20)
            ],
            settings: settings
        )
        // FIXED: Set the app delegate reference immediately
        focusState.appDelegate = self
        return focusState
    }()
    let timerModel = TimerModel(sessionDuration: 1)

    // MARK: — UI (Dynamic Notch)
    var notch: DynamicNotch<ExpandedNotchView,
                            CompactSessionView,
                            CompactTimerView>?

    // MARK: — App State
    @Published var isNotchHidden = false

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
        print("🔍 DEBUG: App launch starting...")
        
        // Set the app activation policy to prevent dock appearance
        NSApp.setActivationPolicy(.accessory)
        
        // Setup status bar first
        setupStatusBar()
        
        // FIXED: Ensure state is fully initialized before loading session
        print("🔍 DEBUG: State has \(state.sessions.count) sessions")
        print("🔍 DEBUG: Current session index: \(state.currentSessionIndex)")
        
        // FIXED: Load current session properly after state is fully set up
        loadCurrentSession()
        
        // Create notch after everything is properly initialized
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
        
        print("🔍 DEBUG: App launch completed")
    }
    
    // Prevent app from quitting when all windows are closed
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
    
    // MARK: — Status Bar Setup
    private func setupStatusBar() {
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusBarItem.button {
            // Create the image with smaller size
            if let image = NSImage(systemSymbolName: "hourglass", accessibilityDescription: "FocusIsland") {
                image.size = NSSize(width: 14, height: 14)
                button.image = image
                button.contentTintColor = NSColor.systemOrange
            }
        }
        
        let menu = NSMenu()
        
        // Show/Hide Dynamic Island
        let toggleItem = NSMenuItem(
            title: isNotchHidden ? "Show Focus Island" : "Hide Focus Island",
            action: #selector(toggleNotchVisibility),
            keyEquivalent: "h"
        )
        toggleItem.target = self
        menu.addItem(toggleItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Current session info
        if let session = state.currentSession {
            let sessionItem = NSMenuItem(title: "Current: \(session.title)", action: nil, keyEquivalent: "")
            sessionItem.isEnabled = false
            menu.addItem(sessionItem)
            
            let timerItem = NSMenuItem(title: "Time: \(timerModel.timeDisplay)", action: nil, keyEquivalent: "")
            timerItem.isEnabled = false
            menu.addItem(timerItem)
            
            menu.addItem(NSMenuItem.separator())
        }
        
        // Pause/Resume
        let playPauseItem = NSMenuItem(
            title: timerModel.isRunning ? "Pause Timer" : "Resume Timer",
            action: #selector(toggleTimer),
            keyEquivalent: "p"
        )
        playPauseItem.target = self
        menu.addItem(playPauseItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Quit
        let quitItem = NSMenuItem(title: "Quit FocusIsland", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        
        statusBarItem.menu = menu
        
        // Update menu periodically
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.updateStatusBarMenu()
        }
    }
    
    // MARK: — Status Bar Actions
    @objc func toggleNotchVisibility() {
        isNotchHidden.toggle()
        
        if isNotchHidden {
            Task { await notch?.hide() }
        } else {
            Task { await notch?.compact() }
        }
        
        updateStatusBarMenu()
    }
    
    @objc private func toggleTimer() {
        if timerModel.isRunning {
            timerModel.pause()
        } else {
            timerModel.start()
        }
    }
    
    @objc private func quitApp() {
        NSApplication.shared.terminate(nil)
    }
    
    private func updateStatusBarMenu() {
        guard let menu = statusBarItem.menu else { return }
        
        // Update toggle item
        if let toggleItem = menu.item(at: 0) {
            toggleItem.title = isNotchHidden ? "Show Focus Island" : "Hide Focus Island"
        }
        
        // Update current session info (rebuild the relevant menu items)
        // Remove old session items (items 2, 3, 4 if they exist)
        while menu.numberOfItems > 6 {
            menu.removeItem(at: 2)
        }
        
        if let session = state.currentSession {
            let sessionItem = NSMenuItem(title: "Current: \(session.title)", action: nil, keyEquivalent: "")
            sessionItem.isEnabled = false
            menu.insertItem(sessionItem, at: 2)
            
            let timerItem = NSMenuItem(title: "Time: \(timerModel.timeDisplay)", action: nil, keyEquivalent: "")
            timerItem.isEnabled = false
            menu.insertItem(timerItem, at: 3)
            
            menu.insertItem(NSMenuItem.separator(), at: 4)
        }
        
        // Update play/pause item
        if let playPauseItem = menu.items.first(where: { $0.action == #selector(toggleTimer) }) {
            playPauseItem.title = timerModel.isRunning ? "Pause Timer" : "Resume Timer"
        }
    }

    // MARK: — Session lifecycle (FIXED)
    func loadCurrentSession() {
        print("🔍 DEBUG: loadCurrentSession() called")
        timerModel.pause()
        timerModel.onCompletion = nil

        guard let session = state.currentSession else {
            print("🔍 DEBUG: No current session found, resetting to 0")
            timerModel.reset(to: 0)
            return
        }
        
        print("🔍 DEBUG: Loading session: \(session.title), duration: \(session.length) seconds")
        timerModel.reset(to: session.length)
        timerModel.onCompletion = { [weak self] in self?.handleCompletion() }
        
        print("🔍 DEBUG: Timer reset to \(session.length) seconds, display: \(timerModel.timeDisplay)")
    }

    private func handleCompletion() {
        state.markSessionComplete()

        // Decide message
        state.notificationMessage = state.currentSession == nil
            ? finals.randomElement()!
            : congrats.randomElement()!
        state.showNotification = true
        
        // Always show notch for completion notifications
        if isNotchHidden {
            isNotchHidden = false
        }
        
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
