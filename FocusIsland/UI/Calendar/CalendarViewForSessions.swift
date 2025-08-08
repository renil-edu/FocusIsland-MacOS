//
//  CalendarViewForSessions.swift
//  FocusIsland
//
//  Created by UT Austin on 8/6/25.
//

import SwiftUI

struct CalendarViewForSessions: View {
    let sessionBlocks: [CalendarSessionBlock]
    let referenceTime: Date

    private let rowH: CGFloat           = 70  // Height per hour
    private let hourWidth: CGFloat      = 340 // Total width
    private let hourLabelWidth: CGFloat = 55  // Width for hour labels
    private let visibleHours            = 6   // Hours to display
    private let blockHeight: CGFloat    = 24  // Fixed height for blocks

    private var currentHour24: Int {
        Calendar.current.component(.hour, from: Date())
    }
    
    private var currentMinute: Int {
        Calendar.current.component(.minute, from: Date())
    }

    var body: some View {
        let calendarScrollView = createScrollView()
        
        return calendarScrollView
            .frame(height: 160)
            .clipped()
    }
    
    // MARK: - Main Components
    
    private func createScrollView() -> some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(0..<visibleHours + 1) { offset in
                    createHourRow(offset: offset)
                }
            }
            .background(Color(.sRGB, white: 0.14, opacity: 0.96))
            .cornerRadius(16)
            .frame(width: hourWidth + 20)
        }
    }
    
    private func createHourRow(offset: Int) -> some View {
        let h24 = (currentHour24 + offset) % 24
        let isCurrentHour = (offset == 0)
        
        return ZStack {
            // Hour label and grid line
            HStack(spacing: 0) {
                Text(hourLabel(for: h24))
                    .frame(width: hourLabelWidth, alignment: .trailing)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray.opacity(0.9))
                    .padding(.trailing, 8)
                
                Rectangle()
                    .fill(Color.white.opacity(0.15))
                    .frame(height: 1)
                
                Spacer()
            }
            .frame(height: rowH, alignment: .top)
            
            // Session blocks for this hour - RESTORED MULTI-COLUMN LAYOUT
            createSessionBlocks(for: h24, hourOffset: offset)
            
            // "Now" red line - more prominent
            if isCurrentHour {
                createRedLine()
            }
        }
        .frame(height: rowH)
    }
    
    private func createSessionBlocks(for hour: Int, hourOffset: Int) -> some View {
        // Get all blocks that intersect with this hour
        let hourBlocks = sessionBlocks.filter { blockIntersectsHour($0, hour: hour) }
        let sortedBlocks = hourBlocks.sorted { $0.start < $1.start }
        
        return ForEach(Array(sortedBlocks.enumerated()), id: \.element.id) { blockIndex, blk in
            createSessionBlock(blk: blk, blockIndex: blockIndex, hourOffset: hourOffset)
        }
    }
    
    private func createSessionBlock(blk: CalendarSessionBlock, blockIndex: Int, hourOffset: Int) -> some View {
        let calendar = Calendar.current
        let currentRowHour = (currentHour24 + hourOffset) % 24
        
        // Calculate vertical position based on time within the hour
        let (relativeTop, _) = calculateVerticalPosition(for: blk, inHour: currentRowHour)
        
        // RESTORED: Multi-column layout to prevent overlap
        let contentWidth = hourWidth - hourLabelWidth - 20
        let maxBlocksPerRow = 3 // Maximum blocks side by side
        let blockWidth = contentWidth / CGFloat(maxBlocksPerRow) - 4
        
        let columnIndex = blockIndex % maxBlocksPerRow
        let rowOffset = blockIndex / maxBlocksPerRow
        
        let xPosition = hourLabelWidth + 15 + (CGFloat(columnIndex) * (blockWidth + 4))
        let yPosition = relativeTop + (CGFloat(rowOffset) * (blockHeight + 2))
        
        return RoundedRectangle(cornerRadius: 6)
            .fill(blk.color)
            .frame(width: blockWidth, height: blockHeight)
            .overlay(createSessionOverlay(blk: blk, width: blockWidth))
            .position(
                x: xPosition + blockWidth / 2,
                y: yPosition + blockHeight / 2
            )
    }
    
    private func createSessionOverlay(blk: CalendarSessionBlock, width: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(cleanTitle(blk.title))
                .font(.system(size: 10, weight: blk.isCurrent ? .bold : .medium))
                .foregroundColor(.white)
                .lineLimit(1)
                .truncationMode(.tail)
            
            Text(shortTimeSpan(blk))
                .font(.system(size: 8))
                .foregroundColor(.white.opacity(0.8))
                .lineLimit(1)
        }
        .frame(width: width - 6, alignment: .leading)
        .padding(.horizontal, 3)
        .padding(.vertical, 1)
    }
    
    private func createRedLine() -> some View {
        Rectangle()
            .fill(Color.red.opacity(0.9))
            .frame(width: hourWidth - hourLabelWidth - 10, height: 3)
            .position(
                x: hourLabelWidth + (hourWidth - hourLabelWidth) / 2,
                y: CGFloat(currentMinute) * (rowH / 60.0)
            )
            .shadow(color: .red.opacity(0.5), radius: 1)
    }

    // MARK: - Layout Calculation Functions
    
    private func blockIntersectsHour(_ block: CalendarSessionBlock, hour: Int) -> Bool {
        let calendar = Calendar.current
        let startHour = calendar.component(.hour, from: block.start)
        let endHour = calendar.component(.hour, from: block.end)
        
        // Handle cross-midnight scenarios
        if endHour < startHour {
            return hour >= startHour || hour <= endHour
        }
        
        // Normal case: block within same day
        return hour >= startHour && hour <= endHour
    }
    
    private func calculateVerticalPosition(for block: CalendarSessionBlock, inHour hour: Int) -> (CGFloat, CGFloat) {
        let calendar = Calendar.current
        let blockStartHour = calendar.component(.hour, from: block.start)
        let blockEndHour = calendar.component(.hour, from: block.end)
        
        // Determine the portion of the block that appears in this hour
        let startMinute: Int
        let endMinute: Int
        
        if blockStartHour == hour {
            startMinute = calendar.component(.minute, from: block.start)
        } else {
            startMinute = 0
        }
        
        if blockEndHour == hour {
            endMinute = calendar.component(.minute, from: block.end)
        } else {
            endMinute = 60
        }
        
        let top = CGFloat(startMinute) * (rowH / 60.0)
        let height = CGFloat(endMinute - startMinute) * (rowH / 60.0)
        
        return (top, max(height, blockHeight))
    }

    // MARK: - Helper Functions
    
    private func hourLabel(for h24: Int) -> String {
        let h12 = (h24 == 0 || h24 == 12) ? 12 : h24 % 12
        let ampm = h24 < 12 ? "AM" : "PM"
        return "\(h12) \(ampm)"
    }
    
    private func cleanTitle(_ title: String) -> String {
        // Remove "Session X" numbering for cleaner display
        return title.replacingOccurrences(of: ", Session \\d+", with: "", options: .regularExpression)
    }
    
    private func shortTimeSpan(_ block: CalendarSessionBlock) -> String {
        let f = DateFormatter()
        f.dateFormat = "h:mm"
        return "\(f.string(from: block.start))-\(f.string(from: block.end))"
    }
}
