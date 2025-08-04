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
    let appDelegate: AppDelegate  // Direct reference!

    // Editing state for Add/Edit sessions (legacy mode)
    @State private var editingSessionID: UUID? = nil
    @State private var newTitle: String = ""
    @State private var editHour: String = "0"
    @State private var editMin: String = "0"
    @State private var editSec: String = "0"
    @State private var newLength: String = "" // compatibility

    // Notification <-> main overlay animation
    @State private var showingMainOverlay = false

    private let maxOverlayWidth: CGFloat = 1000
    private let minOverlayWidth: CGFloat = 540
    private let maxUpcomingToShow: Int = 5

    var body: some View {
        ZStack {
            if state.showNotification && !showingMainOverlay {
                NotificationView(
                    message: state.notificationMessage,
                    onHover: {
                        print("👆 User hovered over notification")
                        print("📞 Calling notificationDismissed() directly")
                        appDelegate.notificationDismissed()
                        
                        // Then animate the transition
                        withAnimation(.easeInOut(duration: 0.33)) {
                            showingMainOverlay = true
                            state.showNotification = false
                        }
                    }
                )
                .frame(minWidth: 370, maxWidth: 470, minHeight: 120, maxHeight: 155)
                .transition(.scale.combined(with: .opacity))
            }
            // Show full overlay if not showing notification, or after animated transition
            if !state.showNotification || showingMainOverlay {
                mainExpandedContent
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .onChange(of: state.showNotification) { show in
            if show {
                showingMainOverlay = false
                print("🔔 Notification shown, hiding main overlay")
            }
        }
        .animation(.easeInOut(duration: 0.33), value: showingMainOverlay)
    }

    private var mainExpandedContent: some View {
        Group {
            switch state.expandedViewMode {
            case .editGoals:
                EditGoalsView(state: state)
            case .settings:
                SettingsView(settings: state.settings, mode: $state.expandedViewMode)
            case .normal:
                let session = state.currentSession ?? FocusSession(title: "--", length: 1)
                HStack(alignment: .top, spacing: 0) {
                    // LEFT: Current session details
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
                    }
                    .frame(minWidth: 110, alignment: .center)

                    Divider()
                        .frame(width: 1)
                        .background(.white.opacity(0.12))
                        .padding(.vertical, 10)

                    // CENTER: Timeline, capped + more indicator
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Upcoming Timeline")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Spacer()
                            Button {
                                state.expandedViewMode = .editGoals
                            } label: {
                                Image(systemName: "pencil.circle.fill")
                                    .foregroundColor(.orange)
                                    .font(.title3)
                            }
                            .buttonStyle(.plain)
                            .help("Edit goals")
                            
                            Button {
                                state.expandedViewMode = .settings
                            } label: {
                                Image(systemName: "gearshape.fill")
                                    .foregroundColor(.orange)
                                    .font(.title3)
                            }
                            .buttonStyle(.plain)
                            .padding(.leading, 4)
                            .help("Settings")
                        }
                        ForEach(
                            Array(state.sessionsToShow.prefix(maxUpcomingToShow).enumerated()),
                            id: \.element.id
                        ) { idx, s in
                            HStack {
                                Text(s.title)
                                    .foregroundColor(.white)
                                    .fontWeight(idx == 0 ? .bold : .regular)
                                Spacer()
                                Text(formattedLength(s.length))
                                    .foregroundColor(.orange)
                                    .font(.caption2.monospacedDigit())
                            }
                        }
                        if state.sessionsToShow.count > maxUpcomingToShow {
                            let remaining = state.sessionsToShow.count - maxUpcomingToShow
                            HStack {
                                Image(systemName: "ellipsis")
                                    .foregroundColor(.gray)
                                Text("and \(remaining) more…")
                                    .foregroundColor(.gray)
                                    .font(.caption)
                                    .lineLimit(1)
                                Spacer()
                            }
                            .opacity(0.7)
                        }
                        Spacer(minLength: 10)
                    }
                    .frame(minWidth: 180, maxWidth: 270, alignment: .leading)
                    .padding(.horizontal, 20)

                    Divider()
                        .frame(width: 1)
                        .background(.white.opacity(0.12))
                        .padding(.vertical, 10)

                    // RIGHT: Timer + start/pause
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
                                print("🎮 Play/Pause button pressed. Current state: isRunning=\(timerModel.isRunning), secondsRemaining=\(timerModel.secondsRemaining)")
                                
                                // Add a safety check - if timer is at 0, try to reload the session
                                if timerModel.secondsRemaining == 0 && !timerModel.isRunning {
                                    print("⚠️ Timer at 0 seconds, attempting to reload session...")
                                    appDelegate.loadCurrentSession()
                                    return
                                }
                                
                                if timerModel.isRunning {
                                    timerModel.pause()
                                    print("⏸️ Timer paused")
                                } else {
                                    timerModel.start()
                                    print("▶️ Timer started")
                                }
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
                    .frame(minWidth: 120, maxWidth: 150)
                }
                .padding(.vertical, 20)
                .padding(.horizontal, 24)
                .fixedSize(horizontal: true, vertical: false)
                .frame(
                    minWidth: minOverlayWidth,
                    maxWidth: maxOverlayWidth
                )
            }
        }
    }

    private func formattedLength(_ seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = seconds % 60
        if h > 0 {
            return String(format: "%d:%02d:%02d", h, m, s)
        } else {
            return String(format: "%d:%02d", m, s)
        }
    }
}

struct NotificationView: View {
    let message: String
    var onHover: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.orange)
                    .frame(width: 34, height: 34)
                Image(systemName: "bell.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 18, weight: .heavy))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("Time's Up!")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.orange)
                Text(message)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
        .padding(.vertical, 32)
        .padding(.horizontal, 44)
        .frame(minWidth: 350, maxWidth: 440)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(Color(.sRGB, white: 0.11, opacity: 0.95))
        )
        .shadow(color: Color.black.opacity(0.21), radius: 12, y: 4)
        .onHover { hovering in
            if hovering {
                onHover?()
            }
        }
    }
}
