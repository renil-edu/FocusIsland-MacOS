//
//  EditGoalsView.swift
//  FocusIsland
//
//  Created by UT Austin on 8/4/25.
//

import SwiftUI

/// Simple CRUD interface for Goals with explicit reorder buttons.
/// Uses proper state mutation methods to ensure changes propagate.
struct EditGoalsView: View {
    @ObservedObject var state: FocusIslandState

    @State private var editingID: UUID?
    @State private var title = ""
    @State private var minutes = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Edit Goals")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                Button("Done") {
                    state.expandedViewMode = .normal
                }
                .buttonStyle(.borderedProminent)
            }

            ScrollView {
                VStack(spacing: 14) {
                    ForEach(state.goals) { goal in
                        goalRow(goal)
                    }

                    if editingID == nil {
                        addRow
                    }
                }
            }
            .frame(maxHeight: 340)
            Spacer()
        }
        .padding(40)
        .frame(minWidth: 540)
        .background(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(Color(.sRGB, white: 0.12, opacity: 0.97))
        )
    }

    @ViewBuilder
    private func goalRow(_ goal: Goal) -> some View {
        if editingID == goal.id {
            HStack {
                TextField("Edit Title", text: $title)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Minutes", text: $minutes)
                    .frame(width: 60)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Save") {
                    saveGoal(goal.id)
                }
                .buttonStyle(.borderedProminent)
                Button("Cancel") {
                    cancelEdit()
                }
                .buttonStyle(.bordered)
            }
        } else {
            HStack {
                Text(goal.title)
                    .foregroundColor(.white)
                Spacer()
                Text("\(goal.minutes) min")
                    .foregroundColor(.orange)
                Button {
                    startEdit(goal)
                } label: {
                    Image(systemName: "pencil")
                }
                .buttonStyle(.plain)
                Button {
                    print("🔍 DEBUG: Removing goal: \(goal.title)")
                    state.removeGoal(id: goal.id)
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
                Button {
                    state.moveGoalUp(id: goal.id)
                } label: {
                    Image(systemName: "arrow.up")
                }
                .buttonStyle(.plain)
                .disabled(state.isFirst(goal))
                Button {
                    state.moveGoalDown(id: goal.id)
                } label: {
                    Image(systemName: "arrow.down")
                }
                .buttonStyle(.plain)
                .disabled(state.isLast(goal))
            }
            .padding(.vertical, 2)
        }
    }

    private var addRow: some View {
        HStack {
            TextField("New goal title", text: $title)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("Minutes", text: $minutes)
                .frame(width: 60)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Button("Add") {
                addGoal()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.top, 8)
    }

    // MARK: - Helper Methods (FIXED WITH DEBUGGING)
    
    private func startEdit(_ goal: Goal) {
        print("🔍 DEBUG: Starting edit for goal: \(goal.title)")
        editingID = goal.id
        title = goal.title
        minutes = String(goal.minutes)
    }

    private func addGoal() {
        guard let m = Int(minutes), m > 0,
              !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            print("🔍 DEBUG: Invalid input for new goal")
            return
        }
        
        print("🔍 DEBUG: Adding new goal: \(title), \(m) minutes")
        state.addGoal(title: title, minutes: m)
        title = ""
        minutes = ""
    }

    private func saveGoal(_ id: UUID) {
        guard let m = Int(minutes), m > 0,
              !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            print("🔍 DEBUG: Invalid input for goal update")
            return
        }
        
        print("🔍 DEBUG: Saving goal changes: \(title), \(m) minutes")
        
        // FIXED: Call state update method which now properly propagates changes
        state.updateGoal(id: id, title: title, minutes: m)
        
        // Clear editing state
        editingID = nil
        title = ""
        minutes = ""
        
        print("🔍 DEBUG: Goal update completed and state cleared")
    }

    private func cancelEdit() {
        print("🔍 DEBUG: Canceling goal edit")
        editingID = nil
        title = ""
        minutes = ""
    }
}
