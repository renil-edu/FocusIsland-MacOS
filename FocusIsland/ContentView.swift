//
//  ContentView.swift
//  FocusIsland
//
//  Created by UT Austin on 8/2/25.
//







import SwiftUI

struct ContentView: View {
    var body: some View {
        Text("🎉 R is quite a genius! 🎉")
            .font(.title)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(.sRGB, white: 0.15, opacity: 0.96))
            )
            .foregroundColor(.white)
    }
}
