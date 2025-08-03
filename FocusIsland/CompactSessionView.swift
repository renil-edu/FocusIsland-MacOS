//
//  CompactSessionView.swift
//  FocusIsland
//
//  Created by UT Austin on 8/2/25.
//


import SwiftUI

struct CompactSessionView: View {
    var sessionTitle: String = "Homework 1 Just Making the Title Really Long"
    var body: some View {
        HStack(spacing: 9) {
            Image(systemName: "checkmark.seal.fill")
                .foregroundColor(.blue)
                .font(.system(size: 15, weight: .bold))
            Text(sessionTitle)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .lineLimit(1)
        }
        .padding(.leading, 14)
        .padding(.vertical, 2)
        .background(Color.clear)
    }
}
