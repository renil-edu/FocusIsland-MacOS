//
//  FocusSession.swift
//  FocusIsland
//
//  Created by UT Austin on 8/3/25.
//


import Foundation

enum ExpandedViewMode: Equatable {
    case normal
    case editSessions
}

struct FocusSession: Identifiable, Equatable {
    let id: UUID
    var title: String
    var length: Int      // in seconds
    var completed: Bool

    init(title: String, length: Int, completed: Bool = false) {
        self.id = UUID()
        self.title = title
        self.length = length
        self.completed = completed
    }
}

class FocusIslandState: ObservableObject {
    @Published var sessions: [FocusSession]
    @Published var currentSessionIndex: Int = 0
    @Published var expandedViewMode: ExpandedViewMode = .normal

    init(sessions: [FocusSession]) {
        self.sessions = sessions
        self.currentSessionIndex = 0
    }

    /// Only current and upcoming sessions remain in the list as soon as one is complete.
    var sessionsToShow: [FocusSession] {
        sessions
    }

    var editableSessions: [FocusSession] {
        sessions
    }

    var currentSession: FocusSession? {
        guard currentSessionIndex < sessions.count else { return nil }
        return sessions[currentSessionIndex]
    }

    /// Remove the current session as soon as it's complete; do NOT increment index.
    func markSessionComplete() {
        guard currentSessionIndex < sessions.count else { return }
        // Uncomment to support graying out (future polish)
        // sessions[currentSessionIndex].completed = true
        sessions.remove(at: currentSessionIndex)
        // Do not increment currentSessionIndex: next session shifts to this index
    }

    func addSession(title: String, length: Int) {
        sessions.append(FocusSession(title: title, length: length))
    }

    func removeSession(id: UUID) {
        if let idx = sessions.firstIndex(where: { $0.id == id }) {
            sessions.remove(at: idx)
            if idx < currentSessionIndex {
                currentSessionIndex -= 1
            }
            currentSessionIndex = max(0, min(currentSessionIndex, sessions.count - 1))
        }
    }

    func updateSession(id: UUID, title: String, length: Int) {
        if let idx = sessions.firstIndex(where: { $0.id == id }) {
            sessions[idx].title = title
            sessions[idx].length = length
        }
    }
}
