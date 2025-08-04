//
//  SettingsView.swift
//  FocusIsland
//
//  Created by UT Austin on 8/4/25.
//

import SwiftUI

/// Notch-style overlay for editing FocusSettings.
struct SettingsView: View {
    @ObservedObject var settings: FocusSettings
    @Binding var mode: ExpandedViewMode
    
    // Local state to prevent excessive updates
    @State private var localFocusMinutes: Int = 20
    @State private var localBreakMinutes: Int = 10
    @State private var localScalingFactor: String = "0.17"

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack {
                Text("Focus Settings")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                Button("Done") {
                    saveSettings()
                    mode = .normal
                }
                .buttonStyle(.borderedProminent)
            }

            settingRow(title: "Focus Session Length",
                       value: $localFocusMinutes,
                       range: 5...90,
                       suffix: "min")

            settingRow(title: "Standard Break Length",
                       value: $localBreakMinutes,
                       range: 5...60,
                       suffix: "min")

            VStack(alignment: .leading, spacing: 8) {
                Text("Post-Goal Break Scaling Factor")
                    .foregroundColor(.white)
                    .font(.system(size: 16))
                
                HStack(spacing: 12) {
                    Button("-") {
                        adjustScalingFactor(by: -0.05)
                    }
                    .buttonStyle(.bordered)
                    .frame(width: 32, height: 28)
                    
                    TextField("Factor", text: $localScalingFactor)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 80)
                        .onSubmit {
                            validateScalingFactor()
                        }
                    
                    Button("+") {
                        adjustScalingFactor(by: 0.05)
                    }
                    .buttonStyle(.bordered)
                    .frame(width: 32, height: 28)
                    
                    Text("(0.05 - 0.50)")
                        .foregroundColor(.gray)
                        .font(.caption)
                }
            }

            Spacer()
        }
        .padding(40)
        .frame(minWidth: 420, maxWidth: 520, minHeight: 240)
        .background(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(Color(.sRGB, white: 0.12, opacity: 0.97))
        )
        .onAppear {
            loadCurrentSettings()
        }
    }

    @ViewBuilder
    private func settingRow(title: String,
                            value: Binding<Int>,
                            range: ClosedRange<Int>,
                            suffix: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .foregroundColor(.white)
                .font(.system(size: 16))
            
            HStack(spacing: 12) {
                Button("-") {
                    if value.wrappedValue > range.lowerBound {
                        value.wrappedValue -= 1
                    }
                }
                .buttonStyle(.bordered)
                .frame(width: 32, height: 28)
                
                Text("\(value.wrappedValue) \(suffix)")
                    .foregroundColor(.orange)
                    .font(.system(size: 16, weight: .medium))
                    .frame(width: 80, alignment: .center)
                
                Button("+") {
                    if value.wrappedValue < range.upperBound {
                        value.wrappedValue += 1
                    }
                }
                .buttonStyle(.bordered)
                .frame(width: 32, height: 28)
            }
        }
    }
    
    // MARK: - Helper functions
    private func loadCurrentSettings() {
        localFocusMinutes = settings.focusMinutes
        localBreakMinutes = settings.standardBreakMinutes
        localScalingFactor = String(format: "%.2f", settings.scalingFactor)
    }
    
    private func saveSettings() {
        settings.focusMinutes = localFocusMinutes
        settings.standardBreakMinutes = localBreakMinutes
        settings.scalingFactor = Double(localScalingFactor) ?? 0.17
    }
    
    private func adjustScalingFactor(by amount: Double) {
        let currentValue = Double(localScalingFactor) ?? 0.17
        let newValue = max(0.05, min(0.50, currentValue + amount))
        localScalingFactor = String(format: "%.2f", newValue)
    }
    
    private func validateScalingFactor() {
        let value = Double(localScalingFactor) ?? 0.17
        let clampedValue = max(0.05, min(0.50, value))
        localScalingFactor = String(format: "%.2f", clampedValue)
    }
}
