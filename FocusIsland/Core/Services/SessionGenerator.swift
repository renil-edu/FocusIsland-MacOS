//
//  SessionGenerator.swift
//  FocusIsland
//
//  Created by UT Austin on 8/3/25.
//


//
//  SessionGenerator.swift
//  FocusIsland
//
//  Created by UT Austin on 8/4/25.
//

import Foundation

/// Pure-function helper that converts Goals → FocusSessions using current settings.
enum SessionGenerator {
    static func build(from goals: [Goal],
                      settings: FocusSettings) -> [FocusSession] {

        var sessions: [FocusSession] = []

        for goal in goals {
            var remaining = goal.minutes
            var chunkIdx  = 1
            // Break goal into focus chunks
            while remaining > 0 {
                let chunk = min(remaining, settings.focusMinutes)
                sessions.append(
                    FocusSession(title: "\(goal.title), Session \(chunkIdx)",
                                 length: chunk * 60) // store in seconds
                )
                remaining -= chunk
                chunkIdx  += 1

                if remaining > 0 {
                    // Standard break between focus chunks
                    sessions.append(
                        FocusSession(title: "Break",
                                     length: settings.standardBreakMinutes * 60)
                    )
                }
            }

            // Post-goal break
            let extra = Int(ceil(Double(goal.minutes) * settings.scalingFactor))
            let post  = settings.standardBreakMinutes + extra
            sessions.append(
                FocusSession(title: "Break",
                             length: post * 60)
            )
        }
        return sessions
    }
}
