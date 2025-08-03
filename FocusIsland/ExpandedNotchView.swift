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

    // Editing state for Add/Edit
    @State private var editingSessionID: UUID? = nil
    @State private var newTitle: String = ""
    // Multi-field time
    @State private var editHour: String = "0"
    @State private var editMin: String = "0"
    @State private var editSec: String = "0"

    // Required for legacy (unused) compatibility; safe to keep for now
    @State private var newLength: String = ""

    private let maxOverlayWidth: CGFloat = 1000
    private let minOverlayWidth: CGFloat = 540
    private let maxUpcomingToShow: Int = 5

    var body: some View {
        Group {
            switch state.expandedViewMode {
            case .editSessions:
                EditSessionsView(
                    state: state,
                    editingSessionID: $editingSessionID,
                    newTitle: $newTitle,
                    editHour: $editHour,
                    editMin: $editMin,
                    editSec: $editSec,
                    newLength: $newLength
                )

            case .normal:
                let session = state.currentSession ?? FocusSession(title: "--", length: 1)
                HStack(alignment: .top, spacing: 0) {
                    // LEFT
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

                    // CENTER: Timeline, capped and "more..." if needed
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Upcoming Timeline")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Spacer()
                            Button {
                                state.expandedViewMode = .editSessions
                            } label: {
                                Image(systemName: "pencil.circle.fill")
                                    .foregroundColor(.orange)
                                    .font(.title3)
                            }
                            .buttonStyle(.plain)
                            .help("Edit sessions")
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

                    // RIGHT
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
        .id(state.expandedViewMode)
        .transition(.scale.combined(with: .opacity))
        .onAppear { print("Expanded view APPEARED") }
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

// --- EDIT SESSIONS PAGE --- //
struct EditSessionsView: View {
    @ObservedObject var state: FocusIslandState
    @Binding var editingSessionID: UUID?
    @Binding var newTitle: String
    @Binding var editHour: String
    @Binding var editMin: String
    @Binding var editSec: String
    @Binding var newLength: String // unused

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Edit Sessions")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                Button("Done") {
                    state.expandedViewMode = .normal
                }
                .font(.system(size: 15, weight: .bold))
                .buttonStyle(.borderedProminent)
                .padding(.trailing, 2)
            }
            .padding(.bottom, 8)

            ScrollView {
                VStack(spacing: 15) {
                    ForEach(state.sessions, id: \.id) { s in
                        HStack(spacing: 44) {
                            if editingSessionID == s.id {
                                TextField("Title", text: $newTitle)
                                    .font(.system(size: 16))
                                    .textFieldStyle(.roundedBorder)
                                    .frame(minWidth: 120, maxWidth: 220)

                                HStack(spacing: 7) {
                                    TextField("Hr", text: $editHour)
                                        .font(.system(size: 15))
                                        .frame(width: 35)
                                        .textFieldStyle(.roundedBorder)
                                    Text(":")
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundColor(.gray)
                                    TextField("Min", text: $editMin)
                                        .font(.system(size: 15))
                                        .frame(width: 35)
                                        .textFieldStyle(.roundedBorder)
                                    Text(":")
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundColor(.gray)
                                    TextField("Sec", text: $editSec)
                                        .font(.system(size: 15))
                                        .frame(width: 35)
                                        .textFieldStyle(.roundedBorder)
                                }

                                Button("Save") {
                                    let hour = Int(editHour) ?? 0
                                    let min = Int(editMin) ?? 0
                                    let sec = Int(editSec) ?? 0
                                    let totalSec = hour * 3600 + min * 60 + sec
                                    if !newTitle.isEmpty, totalSec > 0 {
                                        state.updateSession(id: s.id, title: newTitle, length: totalSec)
                                        editingSessionID = nil
                                    }
                                }
                                .font(.system(size: 15, weight: .bold))
                                .buttonStyle(.borderedProminent)

                                Button("Cancel") {
                                    editingSessionID = nil
                                }
                                .font(.system(size: 14, weight: .regular))
                                .buttonStyle(.bordered)
                            } else {
                                Text(s.title)
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                    .frame(minWidth: 120, maxWidth: 220, alignment: .leading)
                                Text(formattedHourMinSec(s.length))
                                    .font(.system(size: 15, design: .monospaced))
                                    .foregroundColor(.orange)
                                    .frame(width: 70, alignment: .leading)

                                Button {
                                    newTitle = s.title
                                    let (h, m, sec) = secondsToHMS(s.length)
                                    editHour = "\(h)"
                                    editMin = "\(m)"
                                    editSec = "\(sec)"
                                    editingSessionID = s.id
                                } label: {
                                    Image(systemName: "pencil")
                                        .font(.system(size: 17))
                                }
                                .buttonStyle(.plain)
                                .help("Edit session")
                                Button {
                                    state.removeSession(id: s.id)
                                } label: {
                                    Image(systemName: "trash")
                                        .font(.system(size: 17))
                                        .foregroundColor(.red)
                                }
                                .buttonStyle(.plain)
                                .help("Delete session")
                            }
                        }
                        .padding(.vertical, 6)
                    }
                    if editingSessionID == nil {
                        HStack(spacing: 44) {
                            TextField("Title", text: $newTitle)
                                .font(.system(size: 16))
                                .textFieldStyle(.roundedBorder)
                                .frame(minWidth: 120, maxWidth: 220)
                            HStack(spacing: 7) {
                                TextField("Hr", text: $editHour)
                                    .font(.system(size: 15))
                                    .frame(width: 35)
                                    .textFieldStyle(.roundedBorder)
                                Text(":")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.gray)
                                TextField("Min", text: $editMin)
                                    .font(.system(size: 15))
                                    .frame(width: 35)
                                    .textFieldStyle(.roundedBorder)
                                Text(":")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.gray)
                                TextField("Sec", text: $editSec)
                                    .font(.system(size: 15))
                                    .frame(width: 35)
                                    .textFieldStyle(.roundedBorder)
                            }
                            Button("Add") {
                                let hour = Int(editHour) ?? 0
                                let min = Int(editMin) ?? 0
                                let sec = Int(editSec) ?? 0
                                let totalSec = hour * 3600 + min * 60 + sec
                                if !newTitle.isEmpty, totalSec > 0 {
                                    state.addSession(title: newTitle, length: totalSec)
                                    newTitle = ""
                                    editHour = "0"
                                    editMin = "0"
                                    editSec = "0"
                                }
                            }
                            .font(.system(size: 15, weight: .bold))
                            .buttonStyle(.borderedProminent)
                        }
                        .padding(.vertical, 6)
                    }
                }
            }
            .frame(maxHeight: 400)
            Spacer()
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 60)
        .fixedSize(horizontal: true, vertical: false)
        .frame(
            minWidth: 620, maxWidth: 900
        )
        .transition(.scale.combined(with: .opacity))
    }

    private func formattedHourMinSec(_ seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = seconds % 60
        if h > 0 {
            return String(format: "%d:%02d:%02d", h, m, s)
        } else {
            return String(format: "%d:%02d", m, s)
        }
    }
    private func secondsToHMS(_ seconds: Int) -> (Int, Int, Int) {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = seconds % 60
        return (h, m, s)
    }
}
