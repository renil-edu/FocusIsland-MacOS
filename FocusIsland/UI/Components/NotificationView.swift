//
//  NotificationView.swift
//  FocusIsland
//
//  Created by UT Austin on 8/6/25.
//


//
//  NotificationView.swift
//  FocusIsland
//
//  Created by UT Austin on 8/6/25.
//

import SwiftUI

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
        .shadow(color: Color.black.opacity(0.22), radius: 12, y: 4)
        .onHover { hovering in
            if hovering {
                onHover?()
            }
        }
    }
}
