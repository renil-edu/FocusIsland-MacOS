//
//  CompactTimerView.swift
//  FocusIsland
//
//  Created by UT Austin on 8/2/25.
//


import SwiftUI

struct CompactTimerView: View {
    // Replace these with your real timer logic
    var timerDisplay: String = "19:42"
    var progress: Double = 0.37  // 0.0 (just started) to 1.0 (finished)

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                // Smaller background ring
                Circle()
                    .stroke(Color.gray.opacity(0.5), lineWidth: 4)
                    .frame(width: 19, height: 19)
                // Foreground: animated orange progress (smaller)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Color.orange, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 19, height: 19)
                // Center: smaller timer symbol
                Image(systemName: "timer")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 10, height: 10)
                    .foregroundColor(.orange)
            }

            Text(timerDisplay)
                .font(.system(size: 14, weight: .medium).monospacedDigit())
                .foregroundColor(.orange)
        }
        .padding(.trailing, 14)
        .padding(.vertical, 2)
        .background(Color.clear)
    }
}
