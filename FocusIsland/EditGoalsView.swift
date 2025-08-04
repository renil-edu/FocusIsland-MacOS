//
//  EditGoalsView.swift
//  FocusIsland
//
//  Created by UT Austin on 8/3/25.
//


//
//  EditGoalsView.swift
//  FocusIsland
//
//  Created by UT Austin on 8/4/25.
//

import SwiftUI

/// Simple CRUD interface for Goals (mirrors old EditSessionsView style).
struct EditGoalsView: View {
    @ObservedObject var state: FocusIslandState

    @State private var editingID: UUID? = nil
    @State private var title     = ""
    @State private var minutes   = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Edit Goals")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                Button("Done") { state.expandedViewMode = .normal }
                    .buttonStyle(.borderedProminent)
            }

            ScrollView {
                VStack(spacing: 14) {
                    ForEach(state.goals) { g in
                        goalRow(g)
                    }

                    // ADD NEW
                    if editingID == nil {
                        HStack {
                            TextField("Goal title", text: $title)
                                .textFieldStyle(.roundedBorder)
                            TextField("Minutes", text: $minutes)
                                .frame(width: 60)
                                .textFieldStyle(.roundedBorder)
                            Button("Add") {
                                addGoal()
                            }
                            .buttonStyle(.borderedProminent)
                        }
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

    // MARK: – Helpers
    @ViewBuilder
    private func goalRow(_ g: Goal) -> some View {
        if editingID == g.id {
            HStack {
                TextField("Goal title", text: $title)
                    .textFieldStyle(.roundedBorder)
                TextField("Minutes", text: $minutes)
                    .frame(width: 60)
                    .textFieldStyle(.roundedBorder)
                Button("Save") {
                    saveGoal(g.id)
                }.buttonStyle(.borderedProminent)
                Button("Cancel") { editingID = nil }
            }
        } else {
            HStack {
                Text(g.title)
                    .foregroundColor(.white)
                Spacer()
                Text("\(g.minutes) min")
                    .foregroundColor(.orange)
                Button {
                    title   = g.title
                    minutes = String(g.minutes)
                    editingID = g.id
                } label: { Image(systemName: "pencil") }
                    .buttonStyle(.plain)
                Button {
                    state.removeGoal(id: g.id)
                } label: {
                    Image(systemName: "trash").foregroundColor(.red)
                }.buttonStyle(.plain)
            }
        }
    }

    private func addGoal() {
        guard let m = Int(minutes), m > 0, !title.isEmpty else { return }
        state.addGoal(title: title, minutes: m)
        title   = ""
        minutes = ""
    }
    private func saveGoal(_ id: UUID) {
        guard let m = Int(minutes), m > 0, !title.isEmpty else { return }
        state.updateGoal(id: id, title: title, minutes: m)
        editingID = nil
    }
}
