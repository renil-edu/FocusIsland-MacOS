//
//  UnifiedCalendarView.swift
//  FocusIsland
//
//  Created by UT Austin on 8/7/25.
//

import SwiftUI

struct UnifiedCalendarView: View {
    let sessionBlocks: [CalendarSessionBlock]
    let referenceTime: Date
    let config: CalendarConfig
    
    struct CalendarConfig {
        let rowHeight: CGFloat
        let hourWidth: CGFloat
        let hourLabelWidth: CGFloat
        let visibleHours: Int
        let minBlockHeight: CGFloat
        let maxBlocksPerRow: Int
        let fontSize: CGFloat
        let timeSpanFontSize: CGFloat
        let hourFontSize: CGFloat
        let containerHeight: CGFloat
        let cornerRadius: CGFloat
        let padding: CGFloat
        let blockSpacing: CGFloat
        
        static let compact = CalendarConfig(
            rowHeight: 70,
            hourWidth: 340,
            hourLabelWidth: 55,
            visibleHours: 6,
            minBlockHeight: 16,
            maxBlocksPerRow: 3,
            fontSize: 10,
            timeSpanFontSize: 8,
            hourFontSize: 12,
            containerHeight: 160,
            cornerRadius: 16,
            padding: 4,
            blockSpacing: 4
        )
        
        static let fullScreen = CalendarConfig(
            rowHeight: 120,
            hourWidth: 700,
            hourLabelWidth: 80,
            visibleHours: 8,
            minBlockHeight: 24,
            maxBlocksPerRow: 4,
            fontSize: 13,
            timeSpanFontSize: 10,
            hourFontSize: 16,
            containerHeight: 320,
            cornerRadius: 16,
            padding: 6,
            blockSpacing: 6
        )
    }

    // FIXED: Properly get the start of the current hour
    private var timelineStart: Date {
        let calendar = Calendar.current
        let now = Date()
        let currentHour = calendar.component(.hour, from: now)
        
        // FIXED: Also subtract 1 hour here to match the grid
        let adjustedHour = (currentHour - 1 + 24) % 24
        
        let startComponents = DateComponents(
            year: calendar.component(.year, from: now),
            month: calendar.component(.month, from: now),
            day: calendar.component(.day, from: now),
            hour: adjustedHour,
            minute: 0,
            second: 0
        )
        
        return calendar.date(from: startComponents) ?? now
    }

    
    // FIXED: Get the actual current hour (not timeline start hour)
    private var currentHour24: Int {
        Calendar.current.component(.hour, from: Date())
    }

    var body: some View {
        let calendarScrollView = createScrollView()
        
        return calendarScrollView
            .frame(height: config.containerHeight)
            .clipped()
    }
    
    // MARK: - Main Components
    
    private func createScrollView() -> some View {
        ScrollView(.vertical, showsIndicators: true) {
            ZStack(alignment: .topLeading) {
                // Hour grid background
                createHourGrid()
                
                // Events positioned absolutely with FIXED COLUMN LAYOUT
                createAllEvents()
                
                // Current time indicator
                createCurrentTimeLine()
            }
            .frame(width: config.hourWidth + 20, height: CGFloat(config.visibleHours) * config.rowHeight)
            .background(Color(.sRGB, white: 0.14, opacity: 0.96))
            .cornerRadius(config.cornerRadius)
        }
    }
    
    private func createHourGrid() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(0..<config.visibleHours + 1) { offset in
                createHourGridLine(offset: offset)
            }
        }
    }
    
    private func createHourGridLine(offset: Int) -> some View {
        // FIXED: Start from current hour, not timeline start hour
        let h24 = (currentHour24 - 1 + offset) % 24
        
        return HStack(spacing: 0) {
            Text(hourLabel(for: h24))
                .frame(width: config.hourLabelWidth, alignment: .trailing)
                .font(.system(size: config.hourFontSize, weight: .medium))
                .foregroundColor(.gray.opacity(0.9))
                .padding(.trailing, config.padding * 2)
            
            Rectangle()
                .fill(Color.white.opacity(0.15))
                .frame(height: 1)
            
            Spacer()
        }
        .frame(height: config.rowHeight, alignment: .top)
    }
    
    // FIXED: Render events with proper multi-column layout
    private func createAllEvents() -> some View {
        let sortedEvents = sessionBlocks.sorted { $0.start < $1.start }
        
        return ForEach(Array(sortedEvents.enumerated()), id: \.element.id) { eventIndex, event in
            createAbsolutePositionedEvent(
                event: event,
                eventIndex: eventIndex
            )
        }
    }
    
    private func createAbsolutePositionedEvent(event: CalendarSessionBlock, eventIndex: Int) -> some View {
        // Calculate absolute position from timeline start (current hour at minute 0)
        let offsetFromStart = event.start.timeIntervalSince(timelineStart)
        let topPosition = max(0, CGFloat(offsetFromStart) / 3600.0 * config.rowHeight)
        
        // Calculate height based on actual duration
        let duration = event.end.timeIntervalSince(event.start)
        let calculatedHeight = max(config.minBlockHeight, CGFloat(duration) / 3600.0 * config.rowHeight)
        
        // FIXED: Use consistent column layout (like the old working version)
        let contentWidth = config.hourWidth - config.hourLabelWidth - (config.padding * 5)
        let blockWidth = contentWidth / CGFloat(config.maxBlocksPerRow) - config.blockSpacing
        
        let columnIndex = eventIndex % config.maxBlocksPerRow
        let rowOffset = eventIndex / config.maxBlocksPerRow
        
        let xPosition = config.hourLabelWidth + (config.padding * 3) + (CGFloat(columnIndex) * (blockWidth + config.blockSpacing))
        let yPosition = topPosition + (CGFloat(rowOffset) * (config.minBlockHeight + config.blockSpacing))
        
        return RoundedRectangle(cornerRadius: config.padding + 2)
            .fill(event.color)
            .frame(width: blockWidth, height: max(calculatedHeight, config.minBlockHeight))
            .overlay(createSessionOverlay(event: event, width: blockWidth))
            .position(
                x: xPosition + blockWidth / 2,
                y: yPosition + max(calculatedHeight, config.minBlockHeight) / 2
            )
    }
    
    private func createSessionOverlay(event: CalendarSessionBlock, width: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(cleanTitle(event.title))
                .font(.system(size: config.fontSize, weight: event.isCurrent ? .bold : .medium))
                .foregroundColor(.white)
                .lineLimit(2)
                .truncationMode(.tail)
            
            Text(shortTimeSpan(event))
                .font(.system(size: config.timeSpanFontSize))
                .foregroundColor(.white.opacity(0.8))
                .lineLimit(1)
        }
        .frame(width: width - config.padding, alignment: .leading)
        .padding(.horizontal, config.padding/2)
        .padding(.vertical, config.padding/4)
    }
    
    private func createCurrentTimeLine() -> some View {
        let lineThickness: CGFloat = config == .compact ? 3 : 4
        let currentTime = Date()
        let offsetFromStart = currentTime.timeIntervalSince(timelineStart)
        let yPosition = CGFloat(offsetFromStart) / 3600.0 * config.rowHeight
        
        return Rectangle()
            .fill(Color.red.opacity(0.9))
            .frame(width: config.hourWidth - config.hourLabelWidth - 10, height: lineThickness)
            .position(
                x: config.hourLabelWidth + (config.hourWidth - config.hourLabelWidth) / 2,
                y: max(0, yPosition)
            )
            .shadow(color: .red.opacity(0.5), radius: config == .compact ? 1 : 2)
    }

    // MARK: - Helper Functions
    
    private func hourLabel(for h24: Int) -> String {
        let h12 = (h24 == 0 || h24 == 12) ? 12 : h24 % 12
        let ampm = h24 < 12 ? "AM" : "PM"
        return "\(h12) \(ampm)"
    }
    
    private func cleanTitle(_ title: String) -> String {
        return title.replacingOccurrences(of: ", Session \\d+", with: "", options: .regularExpression)
    }
    
    private func shortTimeSpan(_ event: CalendarSessionBlock) -> String {
        let f = DateFormatter()
        f.dateFormat = "h:mm"
        return "\(f.string(from: event.start))-\(f.string(from: event.end))"
    }
}

// MARK: - Config Equality for comparison
extension UnifiedCalendarView.CalendarConfig: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.rowHeight == rhs.rowHeight &&
               lhs.hourWidth == rhs.hourWidth &&
               lhs.hourLabelWidth == rhs.hourLabelWidth
    }
}
