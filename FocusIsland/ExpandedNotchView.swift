//
//  ExpandedNotchView.swift
//  FocusIsland
//
//  Created by UT Austin on 8/2/25.
//


import SwiftUI

struct ExpandedNotchView: View {
    @ObservedObject var state: FocusIslandState
    @ObservedObject var timerModel: TimerModel
    private let maxOverlayWidth: CGFloat = 900
    private let minOverlayWidth: CGFloat = 380

    var body: some View {
        let session = state.currentSession ?? FocusSession(title: "--", length: 1)
        HStack(alignment: .top, spacing: 0) {
            // LEFT: Session info, centered
            VStack(alignment: .center, spacing: 14) {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 24, weight: .bold))
                    Text(session.title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .layoutPriority(1)
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

            // CENTER: Timeline/tasks (dynamically rendered)
            VStack(alignment: .leading, spacing: 8) {
                Text("Upcoming Timeline")
                    .font(.caption)
                    .foregroundColor(.gray)
                ForEach(state.sessions.indices, id: \.self) { idx in
                    let s = state.sessions[idx]
                    HStack {
                        Image(systemName: idx < state.currentSessionIndex ? "checkmark.circle.fill"
                                    : idx == state.currentSessionIndex ? "circle.fill" : "circle")
                            .font(.system(size: 11))
                            .foregroundColor(
                                idx < state.currentSessionIndex ? .green
                                : idx == state.currentSessionIndex ? .orange
                                : .gray)
                        Text(s.title)
                            .foregroundColor(.white)
                            .fontWeight(idx == state.currentSessionIndex ? .bold : .regular)
                        Spacer()
                        Text(formattedLength(s.length))
                            .foregroundColor(.orange)
                            .font(.caption2.monospacedDigit())
                    }
                    .opacity(idx < state.currentSessionIndex ? 0.48 : 1.0)
                    .padding(.vertical, 1)
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
        .fixedSize(horizontal: true, vertical: false)
        .frame(
            minWidth: minOverlayWidth,
            maxWidth: maxOverlayWidth
        )
        .transition(.scale.combined(with: .opacity))
        .onAppear { print("Expanded view APPEARED") }
    }

    private func formattedLength(_ seconds: Int) -> String {
        String(format: "%d:%02d", seconds / 60, seconds % 60)
    }
}
