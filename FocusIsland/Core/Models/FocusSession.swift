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
