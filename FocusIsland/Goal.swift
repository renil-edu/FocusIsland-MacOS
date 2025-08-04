//
//  Goal.swift
//  FocusIsland
//
//  Created by UT Austin on 8/3/25.
//


//
//  Goal.swift
//  FocusIsland
//
//  Created by UT Austin on 8/4/25.
//

import Foundation

/// A high-level work item entered by the user.
struct Goal: Identifiable, Equatable, Codable {
    let id: UUID
    var title: String
    /// Estimated duration in **minutes**.
    var minutes: Int

    init(title: String, minutes: Int) {
        self.id     = UUID()
        self.title  = title
        self.minutes = minutes
    }
}
