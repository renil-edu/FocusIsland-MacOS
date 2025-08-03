//
//  CompactTimerView.swift
//  FocusIsland
//
//  Created by UT Austin on 8/2/25.
//


import SwiftUI

struct CompactTimerView: View {
    @ObservedObject var timerModel: TimerModel

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.5), lineWidth: 4)
                    .frame(width: 19, height: 19)
                Circle()
                    .trim(from: 0, to: timerModel.progress)
                    .stroke(Color.orange, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 19, height: 19)
                Image(systemName: "timer")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 10, height: 10)
                    .foregroundColor(.orange)
            }
            Text(timerModel.timeDisplay)
                .font(.system(size: 14, weight: .medium).monospacedDigit())
                .foregroundColor(.orange)
        }
        .padding(.trailing, 14)
        .padding(.vertical, 2)
        .background(Color.clear)
    }
}
