//
//  FocusIslandState.swift
//  FocusIsland
//
//  Created by UT Austin on 8/3/25.
//

import Foundation
import Combine

enum ExpandedViewMode: Equatable {
    case normal
    case editGoals
    case settings
    case calendar
}

/// Global app-wide state.
///
/// - Holds the user's goals
/// - Generates `[FocusSession]` anytime goals / settings change
/// - Drives the UI and timer logic exactly like before
final class FocusIslandState: ObservableObject {

    // MARK: — Input
    @Published var goals: [Goal]
    @Published var settings: FocusSettings

    // MARK: — Output (generated)
    @Published var sessions: [FocusSession] = []
    @Published var currentSessionIndex: Int = 0

    // MARK: — UI mode
    @Published var expandedViewMode: ExpandedViewMode = .normal

    // MARK: — Notification overlay
    @Published var showNotification: Bool = false
    @Published var notificationMessage: String = ""

    // Optional weak reference to AppDelegate to reload timer on session changes
    weak var appDelegate: AppDelegate?

    private var cancellables: Set<AnyCancellable> = []

    // MARK: — Init (FIXED)
    init(goals: [Goal], settings: FocusSettings) {
        print("🔍 DEBUG: FocusIslandState init starting...")
        self.goals    = goals
        self.settings = settings
        
        // FIXED: Generate sessions immediately during init
        regenerateSessions()
        print("🔍 DEBUG: Initial session generation complete. Sessions: \(sessions.count)")

        // React to any goal change
        $goals
            .sink { [weak self] _ in
                print("🔍 DEBUG: Goals changed, regenerating sessions")
                self?.regenerateSessions()
            }
            .store(in: &cancellables)

        // React to any settings change
        settings.objectWillChange
            .sink { [weak self] _ in
                print("🔍 DEBUG: Settings changed, regenerating sessions")
                self?.regenerateSessions()
            }
            .store(in: &cancellables)

        // Save settings whenever they change
        settings.objectWillChange
            .sink { [weak settings] _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    settings?.save()
                }
            }
            .store(in: &cancellables)
        
        print("🔍 DEBUG: FocusIslandState init completed")
    }

    // MARK: — Derived helpers
    var sessionsToShow: [FocusSession] { sessions }
    var currentSession: FocusSession? {
        guard currentSessionIndex < sessions.count else { return nil }
        return sessions[currentSessionIndex]
    }

    // MARK: — Mutations (FIXED PROPAGATION)
    func addGoal(title: String, minutes: Int) {
        print("🔍 DEBUG: Adding goal: \(title), \(minutes) minutes")
        goals.append(Goal(title: title, minutes: minutes))
        // Goals array change will trigger regeneration via $goals publisher
    }

    func removeGoal(id: UUID) {
        print("🔍 DEBUG: Removing goal with id: \(id)")
        goals.removeAll { $0.id == id }
        // Goals array change will trigger regeneration via $goals publisher
    }

    func updateGoal(id: UUID, title: String, minutes: Int) {
        print("🔍 DEBUG: Updating goal \(id) to: \(title), \(minutes) minutes")
        guard let idx = goals.firstIndex(where: { $0.id == id }) else {
            print("🔍 DEBUG: Goal not found for update")
            return
        }
        
        let oldGoal = goals[idx]
        print("🔍 DEBUG: Old goal: \(oldGoal.title), \(oldGoal.minutes) minutes")
        
        goals[idx].title   = title
        goals[idx].minutes = minutes
        
        print("🔍 DEBUG: Updated goal: \(goals[idx].title), \(goals[idx].minutes) minutes")
        
        // FIXED: Force immediate regeneration and timer update
        regenerateSessions()
        
        // FIXED: Force UI update to ensure changes are visible
        DispatchQueue.main.async { [weak self] in
            self?.objectWillChange.send()
        }
    }

    func moveGoalUp(id: UUID) {
        guard let idx = goals.firstIndex(where: { $0.id == id }), idx > 0 else { return }
        goals.move(fromOffsets: IndexSet(integer: idx), toOffset: idx - 1)
        currentSessionIndex = 0 // Reset session index to zero after reorder
        regenerateSessions()
    }

    func moveGoalDown(id: UUID) {
        guard let idx = goals.firstIndex(where: { $0.id == id }), idx < goals.count - 1 else { return }
        goals.move(fromOffsets: IndexSet(integer: idx), toOffset: idx + 2)
        currentSessionIndex = 0 // Reset session index
        regenerateSessions()
    }

    func isFirst(_ goal: Goal) -> Bool {
        goals.first?.id == goal.id
    }

    func isLast(_ goal: Goal) -> Bool {
        goals.last?.id == goal.id
    }

    func markSessionComplete() {
        guard currentSessionIndex < sessions.count else { return }
        sessions.remove(at: currentSessionIndex)
    }

    // MARK: — Private (FIXED IMMEDIATE PROPAGATION)
    private func regenerateSessions() {
        print("🔍 DEBUG: regenerateSessions() called")
        let newSessions = SessionGenerator.build(from: goals, settings: settings)
        
        // FIXED: Update sessions immediately instead of async
        let oldCurrentSession = currentSession
        sessions = newSessions
        currentSessionIndex = min(currentSessionIndex, max(0, sessions.count - 1))
        
        print("🔍 DEBUG: Generated \(sessions.count) sessions")
        if let current = currentSession {
            print("🔍 DEBUG: Current session: \(current.title), length: \(current.length)")
        }
        
        // FIXED: Check if current session changed and force timer reload
        let newCurrentSession = currentSession
        let sessionChanged = oldCurrentSession?.id != newCurrentSession?.id ||
                            oldCurrentSession?.length != newCurrentSession?.length ||
                            oldCurrentSession?.title != newCurrentSession?.title
        
        if sessionChanged {
            print("🔍 DEBUG: Current session changed, forcing timer reload")
        }
        
        // FIXED: Call loadCurrentSession immediately to update timer
        appDelegate?.loadCurrentSession()
    }
}
