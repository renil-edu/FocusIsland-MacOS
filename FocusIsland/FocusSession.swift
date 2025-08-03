//
//  FocusSession.swift
//  FocusIsland
//
//  Created by UT Austin on 8/3/25.
//


import Foundation

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

    init(sessions: [FocusSession]) {
        self.sessions = sessions
        self.currentSessionIndex = 0
    }

    var currentSession: FocusSession? {
        guard sessions.indices.contains(currentSessionIndex) else { return nil }
        return sessions[currentSessionIndex]
    }

    func advanceSession() {
        if currentSessionIndex + 1 < sessions.count {
            currentSessionIndex += 1
        }
    }

    func markSessionComplete() {
        guard let idx = sessions.indices.contains(currentSessionIndex) ? currentSessionIndex : nil else { return }
        sessions[idx].completed = true
    }
}
