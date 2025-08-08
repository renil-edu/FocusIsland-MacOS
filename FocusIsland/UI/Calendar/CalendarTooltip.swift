//
//  CalendarTooltip.swift
//  FocusIsland
//
//  Created by UT Austin on 8/6/25.
//

import SwiftUI

struct CalendarTooltip: View {
    let title: String
    let timeSpan: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            Text(timeSpan)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.black.opacity(0.88))
                .shadow(color: .black.opacity(0.4), radius: 6, y: 3)
        )
        .fixedSize()
    }
}
