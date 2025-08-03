//
//  ExpandedNotchView.swift
//  FocusIsland
//
//  Created by UT Austin on 8/2/25.
//


import SwiftUI

struct ExpandedNotchView: View {
    @ObservedObject var timerModel: TimerModel
    private let maxOverlayWidth: CGFloat = 900   // How wide the island can ever get
    private let minOverlayWidth: CGFloat = 380
    var sessionTitle: String = "Homework 1"

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            // LEFT: Session info, centered
            VStack(alignment: .center, spacing: 14) {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 24, weight: .bold))
                    Text(sessionTitle)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)           // Only one line
                        .truncationMode(.tail)  // Truncate with ...
                        .layoutPriority(10)
                }
                .padding(.horizontal, 8)
                .frame(minWidth: 60, maxWidth: .infinity, alignment: .center)
                Text("Current session in progress…")
                    .foregroundColor(.white.opacity(0.7))
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .frame(minWidth: 110, alignment: .center)

            Divider()
                .frame(width: 1)
                .background(.white.opacity(0.12))
                .padding(.vertical, 10)

            // CENTER: Timeline/Task List (same as before)
            VStack(alignment: .leading, spacing: 8) {
                Text("Upcoming Timeline")
                    .font(.caption)
                    .foregroundColor(.gray)
                ForEach(1..<5) { idx in
                    HStack {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 10))
                            .foregroundColor(idx == 1 ? .orange : .gray)
                        Text("Task \(idx): Placeholder")
                            .foregroundColor(.white)
                            .fontWeight(idx == 1 ? .semibold : .regular)
                    }
                }
                Spacer(minLength: 8)
            }
            .frame(minWidth: 120, maxWidth: 200, alignment: .leading)
            .padding(.horizontal, 10)

            Divider()
                .frame(width: 1)
                .background(.white.opacity(0.12))
                .padding(.vertical, 10)

            // RIGHT: Timer/progress/play-pause
            VStack(alignment: .center, spacing: 14) {
                Text(timerModel.timeDisplay)
                    .font(.system(size: 27, weight: .bold).monospacedDigit())
                    .foregroundColor(.orange)
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.5), lineWidth: 6)
                        .frame(width: 48, height: 48)
                    Circle()
                        .trim(from: 0, to: timerModel.progress)
                        .stroke(Color.orange, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .frame(width: 48, height: 48)
                    Button(action: {
                        timerModel.isRunning ? timerModel.pause() : timerModel.start()
                    }) {
                        Image(systemName: timerModel.isRunning ? "pause.fill" : "play.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.orange)
                            .padding(8)
                            .offset(x: timerModel.isRunning ? 0 : 2)
                    }
                    .buttonStyle(.plain)
                }
                Text(timerModel.isRunning ? "Pause Session" : "Resume Session")
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.76))
            }
            .frame(minWidth: 90, maxWidth: 130)
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 18)
        .fixedSize(horizontal: true, vertical: false) // << This is the magic!
        .frame(
            minWidth: minOverlayWidth,
            maxWidth: maxOverlayWidth, // Cap overlay at some clan max width if session title is nuts
            alignment: .center
        )
        .transition(.scale.combined(with: .opacity))
        .onAppear {
            print("Expanded view APPEARED")
        }
    }
}
