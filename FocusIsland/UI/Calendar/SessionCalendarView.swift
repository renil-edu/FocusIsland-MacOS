//
//  SessionCalendarView.swift
//  FocusIsland
//
//  Inspired by Apple Calendar Day View (12-hour version)
//

import SwiftUI

struct SessionBlock: Identifiable {
    let id = UUID()
    let title: String
    let start: Date
    let end: Date
    let isCurrent: Bool
    let color: Color
}

struct SessionCalendarView: View {
    let sessionBlocks: [SessionBlock]
    let referenceTime: Date   // Use Date() when ticking, or frozen time if paused

    private let hourHeight: CGFloat = 64 // px per hour

    var body: some View {
        ScrollView(showsIndicators: true) {
            ZStack(alignment: .top) {
                // Hour grid lines and labels
                ForEach(0..<13) { hourOffset in
                    let hour = Calendar.current.component(.hour, from: referenceTime) + hourOffset
                    let y = CGFloat(hourOffset) * hourHeight
                    HStack(spacing: 0) {
                        Text(label(for: hour % 24))
                            .frame(width: 38, alignment: .trailing)
                            .font(.caption2)
                            .foregroundColor(.gray)
                            .opacity(0.95)
                        Rectangle().frame(height: 1)
                            .foregroundColor(Color.white.opacity(0.09))
                        Spacer()
                    }
                    .offset(y: y)
                }

                // Session blocks
                ForEach(sessionBlocks) { block in
                    let (top, height) = blockRect(block: block)
                    RoundedRectangle(cornerRadius: 8)
                        .fill(block.color)
                        .frame(width: 168, height: max(height, 16))
                        .overlay(
                            VStack(alignment: .leading, spacing: 2) {
                                Text(block.title)
                                    .fontWeight(block.isCurrent ? .bold : .medium)
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                    .font(.system(size: 14))
                                Text(timeSpanString(start: block.start, end: block.end))
                                    .font(.caption2).foregroundColor(.white.opacity(0.75))
                            }.padding(.leading, 8).padding(.vertical, 3),
                            alignment: .topLeading
                        )
                        .offset(x: 44, y: top)
                        .shadow(color: Color.black.opacity(0.08), radius: 2, x: 1, y: 2)
                }

                // Current time line
                let nowY = CGFloat(minutesSince(referenceTime, from: referenceTime)) / 60.0 * hourHeight
                Rectangle()
                    .fill(Color.red.opacity(0.93))
                    .frame(height: 2)
                    .offset(x: 40, y: nowY-1)
            }
            .frame(height: hourHeight * 12)
        }
        .frame(minWidth: 250, maxWidth: 250)
        .background(Color(.sRGB, white: 0.14, opacity: 0.96))
        .cornerRadius(18)
    }

    // MARK: - Geometry

    private func label(for hour: Int) -> String {
        let hour12 = (hour == 0 || hour == 12) ? 12 : hour % 12
        let ampm = hour < 12 || hour == 24 ? "AM" : "PM"
        return "\(hour12)\(ampm)"
    }

    // offset from referenceTime, in minutes
    private func minutesSince(_ time: Date, from: Date) -> Int {
        let delta = time.timeIntervalSince(from)
        return max(0, Int(delta/60))
    }
    // Returns (top, height) in px for block in the 12h window starting at referenceTime
    private func blockRect(block: SessionBlock) -> (CGFloat, CGFloat) {
        let startMins = Double(minutesSince(block.start, from: referenceTime))
        let endMins   = Double(minutesSince(block.end, from: referenceTime))
        let minY = max(0.0, min(startMins/60.0 * hourHeight, hourHeight*12))
        let maxY = min(max(endMins/60.0 * hourHeight, minY), hourHeight*12)
        let blockHeight = maxY - minY
        return (minY, blockHeight)
    }

    private func timeSpanString(start: Date, end: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "h:mm a"
        return "\(fmt.string(from: start)) – \(fmt.string(from: end))"
    }
}
