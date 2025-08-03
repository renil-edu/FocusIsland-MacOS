//
//  ExpandedNotchView.swift
//  FocusIsland
//
//  Created by UT Austin on 8/2/25.
//


import SwiftUI

struct ExpandedNotchView: View {
    // Adjust this as needed for your max-expected session title
    private let maxTitleWidth: CGFloat = 260
    var sessionTitle: String = "Homework 1 - Math Review"

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            // Left block (centered session info)
            VStack(alignment: .center, spacing: 14) {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 24, weight: .bold))
                    Text(sessionTitle)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .layoutPriority(1)
                        .frame(maxWidth: maxTitleWidth, alignment: .center)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                Text("Current session in progress…")
                    .foregroundColor(.white.opacity(0.7))
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .frame(width: maxTitleWidth + 40, alignment: .center)

            Divider()
                .frame(width: 1)
                .background(.white.opacity(0.12))
                .padding(.vertical, 10)

            // Center: Timeline/Task List
            VStack(alignment: .leading, spacing: 8) {
                Text("Upcoming Timeline")
                    .font(.caption)
                    .foregroundColor(.gray)
                ForEach(1..<5) { idx in
                    HStack {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 10))
                            .foregroundColor(idx == 1 ? .orange : .gray)
                        Text("Task \(idx): Placeholder")
                            .foregroundColor(.white)
                            .fontWeight(idx == 1 ? .semibold : .regular)
                    }
                }
                Spacer(minLength: 8)
            }
            .frame(width: 180, alignment: .leading)
            .padding(.horizontal, 10)

            Divider()
                .frame(width: 1)
                .background(.white.opacity(0.12))
                .padding(.vertical, 10)

            // Right: Timer and controls
            VStack(alignment: .center, spacing: 14) {
                Text("19:42")
                    .font(.system(size: 27, weight: .bold).monospacedDigit())
                    .foregroundColor(.orange)
                Button(action: {}) {
                    Image(systemName: "pause.fill")
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Circle().fill(Color.red))
                }
                .buttonStyle(.plain)
                Text("Pause Session")
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.76))
            }
            .frame(width: 110)
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 24)
        .frame(
            minWidth: 580,
            idealWidth: 680,
            maxWidth: .infinity,
            minHeight: 110,
            idealHeight: 140
        )
        .transition(.scale.combined(with: .opacity))
        .onAppear {
            print("Expanded view APPEARED")
        }
    }
}
