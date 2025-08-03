//
//  OverlayNotchView.swift
//  FocusIsland
//
//  Created by UT Austin on 8/2/25.
//


import SwiftUI

struct OverlayNotchView: View {
    // Adjust this to your actual Mac's notch width, usually ~90-120
    let notchWidth: CGFloat = 90
    let gapPadding: CGFloat = 16

    @State private var isHovering = false
    @State private var paused = false

    var body: some View {
        HStack(spacing: 0) {
            // Left: Session
            HStack(spacing: 10) {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(.blue)
                    .font(.system(size: 18, weight: .bold))
                Text("Homework 1")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
            }
            .padding(.leading, 20)
            .padding(.trailing, gapPadding / 2)
            .frame(minWidth: 110, maxWidth: .infinity, alignment: .trailing)

            // Center: Notch "gap"
            Color.clear
                .frame(width: notchWidth)

            // Right: Timer/Pause
            HStack(spacing: 12) {
                Text("19:42")
                    .font(.system(size: 15, weight: .semibold).monospacedDigit())
                    .foregroundColor(.orange)
                Button(action: { paused.toggle() }) {
                    Image(systemName: paused ? "play.fill" : "pause.fill")
                        .foregroundColor(.white)
                        .padding(6)
                        .background(
                            Circle()
                                .fill(paused ? Color.green : Color.red)
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(.leading, gapPadding / 2)
            .padding(.trailing, 20)
            .frame(minWidth: 100, maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color(.sRGB, white: 0.10, opacity: 0.97), Color(.sRGB, white: 0.19, opacity: 0.97)]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .shadow(radius: 16)
        )
        .frame(
            minWidth: 295 + notchWidth + gapPadding,
            maxWidth: 350 + notchWidth + gapPadding,
            minHeight: 44,
            maxHeight: 54
        )
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.13)) {
                isHovering = hovering
            }
        }
        .scaleEffect(isHovering ? 1.05 : 1)
        .animation(.spring(response: 0.28, dampingFraction: 0.8), value: isHovering)
    }
}
