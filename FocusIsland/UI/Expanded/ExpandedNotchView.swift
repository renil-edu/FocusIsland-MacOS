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
    let appDelegate: AppDelegate

    @State private var showingMainOverlay = false

    private let maxOverlayWidth: CGFloat = 1000
    private let minOverlayWidth: CGFloat = 540

    var body: some View {
        ZStack {
            if state.showNotification && !showingMainOverlay {
                NotificationView(
                    message: state.notificationMessage,
                    onHover: {
                        appDelegate.notificationDismissed()
                        withAnimation(.easeInOut(duration: 0.33)) {
                            showingMainOverlay = true
                            state.showNotification = false
                        }
                    }
                )
                .frame(minWidth: 370, maxWidth: 470, minHeight: 120, maxHeight: 155)
                .transition(.scale.combined(with: .opacity))
            }

            if !state.showNotification || showingMainOverlay {
                mainExpandedContent
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .onChange(of: state.showNotification) { _, show in
            if show {
                showingMainOverlay = false
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
            case .calendar:
                FullScreenCalendarView(state: state, timerModel: timerModel)
            case .normal:
                normalModeContent
            }
        }
    }
    
    private var normalModeContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            // RESTORED: Current session title bar across the top - PROPERLY CENTERED
            currentSessionTitleBar
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 16)
            
            // Original 2-column layout below - RESTORED PROPER WIDTH
            HStack(alignment: .top, spacing: 0) {
                // Calendar (left column)
                VStack(alignment: .leading, spacing: 20) {
                    // Header with buttons
                    HStack {
                        Text("Upcoming Timeline")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Spacer()
                        
                        Button {
                            state.expandedViewMode = .calendar
                        } label: {
                            Image(systemName: "arrow.up.left.and.arrow.down.right")
                                .foregroundColor(.orange)
                                .font(.title3)
                        }
                        .buttonStyle(.plain)
                        .help("Maximize calendar")
                        
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
                    
                    // Calendar itself - USING UNIFIED CALENDAR
                    UnifiedCalendarView(
                        sessionBlocks: makeCalendarSessionBlocks(state: state, timerModel: timerModel),
                        referenceTime: Date(),
                        config: .compact
                    )
                }
                .frame(minWidth: 295, maxWidth: 400, alignment: .topLeading)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)

                Divider()
                    .frame(width: 1)
                    .background(.white.opacity(0.12))
                    .padding(.vertical, 10)

                // Timer + controls (right column)
                timerControlsSection
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 24)
        }
        .fixedSize(horizontal: true, vertical: false)
        .frame(minWidth: minOverlayWidth, maxWidth: maxOverlayWidth)
    }
    
    // RESTORED: Current session title bar component - PROPERLY CENTERED
    private var currentSessionTitleBar: some View {
        HStack {
            Spacer() // Left spacer for centering
            
            HStack(spacing: 12) {
                // Checkmark icon
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(.blue)
                    .font(.system(size: 22, weight: .bold))
                
                // Session title
                Text(state.currentSession?.title ?? "No Active Session")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
            }
            
            Spacer() // Right spacer for centering
        }
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
    }
    
    private var timerControlsSection: some View {
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
                Button(action: handleTimerButtonPress) {
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
    
    private func handleTimerButtonPress() {
        if timerModel.secondsRemaining == 0 && !timerModel.isRunning {
            appDelegate.loadCurrentSession()
            return
        }
        
        if timerModel.isRunning {
            timerModel.pause()
        } else {
            timerModel.start()
        }
    }
}
