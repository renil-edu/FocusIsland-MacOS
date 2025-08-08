//
//  FullScreenCalendarView.swift
//  FocusIsland
//
//  Created by UT Austin on 8/7/25.
//

import SwiftUI

struct FullScreenCalendarView: View {
    @ObservedObject var state: FocusIslandState
    @ObservedObject var timerModel: TimerModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Header
            HStack {
                Text("Session Timeline")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                Button("Done") {
                    state.expandedViewMode = .normal
                }
                .buttonStyle(.borderedProminent)
            }
            
            // UNIFIED CALENDAR - FULL SCREEN VERSION
            UnifiedCalendarView(
                sessionBlocks: makeCalendarSessionBlocks(state: state, timerModel: timerModel),
                referenceTime: Date(),
                config: .fullScreen
            )
            
            Spacer()
        }
        .padding(40)
        .frame(minWidth: 800, maxWidth: 1000, minHeight: 400)
        .background(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(Color(.sRGB, white: 0.12, opacity: 0.97))
        )
    }
}
