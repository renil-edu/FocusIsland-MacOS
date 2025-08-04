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

    private var cancellables: Set<AnyCancellable> = []

    // MARK: — Init
    init(goals: [Goal], settings: FocusSettings) {
        self.goals    = goals
        self.settings = settings
        regenerateSessions()

        // React to any goal change
        $goals
            .sink { [weak self] _ in
                self?.regenerateSessions()
            }
            .store(in: &cancellables)

        // React to any settings change
        settings.objectWillChange
            .sink { [weak self] _ in
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
    }

    // MARK: — Derived helpers
    var sessionsToShow: [FocusSession] { sessions }
    var currentSession: FocusSession? {
        guard currentSessionIndex < sessions.count else { return nil }
        return sessions[currentSessionIndex]
    }

    // MARK: — Mutations
    func addGoal(title: String, minutes: Int) {
        goals.append(Goal(title: title, minutes: minutes))
    }
    func removeGoal(id: UUID) {
        goals.removeAll { $0.id == id }
        // currentSessionIndex corrected on regenerate
    }
    func updateGoal(id: UUID, title: String, minutes: Int) {
        guard let idx = goals.firstIndex(where: { $0.id == id }) else { return }
        goals[idx].title   = title
        goals[idx].minutes = minutes
    }

    func markSessionComplete() {
        guard currentSessionIndex < sessions.count else { return }
        sessions.remove(at: currentSessionIndex)
        // derive index stays the same; next session shifts into this slot
    }

    // MARK: — Private
    private func regenerateSessions() {
        sessions = SessionGenerator.build(from: goals, settings: settings)
        currentSessionIndex = min(currentSessionIndex, max(0, sessions.count - 1))
    }
}
