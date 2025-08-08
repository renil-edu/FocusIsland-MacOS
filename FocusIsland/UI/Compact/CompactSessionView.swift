//
//  CompactSessionView.swift
//  FocusIsland
//
//  Created by UT Austin on 8/2/25.
//


import SwiftUI

struct CompactSessionView: View {
    @ObservedObject var state: FocusIslandState

    var body: some View {
        HStack(spacing: 9) {
            Image(systemName: "checkmark.seal.fill")
                .foregroundColor(.blue)
                .font(.system(size: 15, weight: .bold))
            Text(state.currentSession?.title ?? "--")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .lineLimit(1)
        }
        .padding(.leading, 14)
        .padding(.vertical, 2)
        .background(Color.clear)
    }
}
