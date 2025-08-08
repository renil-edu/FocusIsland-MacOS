//
//  CalendarModels.swift
//  FocusIsland
//
//  Created by UT Austin on 8/6/25.
//

import SwiftUI

// MARK: - Calendar Data Models

struct CalendarSessionBlock: Identifiable {
    let id = UUID()
    let title: String
    let start: Date
    let end: Date
    let isCurrent: Bool
    let color: Color
}

// MARK: - Helper Functions

func makeCalendarSessionBlocks(state: FocusIslandState,
                               timerModel: TimerModel) -> [CalendarSessionBlock] {
    let now = Date()
    
    // Calculate the anchor time (when current session started)
    let anchor: Date = {
        guard let cur = state.currentSession else { return now }
        let elapsed = cur.length - timerModel.secondsRemaining
        return now.addingTimeInterval(-TimeInterval(elapsed))
    }()

    var blocks: [CalendarSessionBlock] = []
    var cursor = anchor
    
    // Only process sessions starting from current session index
    let remainingSessions = Array(state.sessions[state.currentSessionIndex...])
    
    for (idx, session) in remainingSessions.enumerated() {
        let sessionStart = cursor
        let sessionEnd = cursor.addingTimeInterval(TimeInterval(session.length))
        
        // Only include sessions that are within our display window (next 8 hours)
        let displayWindow = anchor.addingTimeInterval(8 * 3600)
        if sessionStart >= displayWindow {
            break
        }
        
        // Skip sessions that ended before our anchor time
        if sessionEnd <= anchor {
            cursor = sessionEnd
            continue
        }
        
        // Clean up session titles for display
        let displayTitle = session.title.replacingOccurrences(of: ", Session \\d+", with: "", options: .regularExpression)
        
        blocks.append(
            CalendarSessionBlock(
                title: displayTitle,
                start: sessionStart,
                end: sessionEnd,
                isCurrent: idx == 0, // First in remaining sessions is current
                color: session.title.lowercased().contains("break")
                       ? Color.blue.opacity(0.6)
                       : (idx == 0 ? Color.orange.opacity(0.8) : Color.blue.opacity(0.7))
            )
        )
        
        cursor = sessionEnd
    }
    
    return blocks
}
