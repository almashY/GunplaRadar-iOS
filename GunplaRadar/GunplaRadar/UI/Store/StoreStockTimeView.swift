//
//  StoreStockTimeView.swift
//  GunplaRadar
//
//  Created by almashY on 2026/04/19.
//

import SwiftUI

struct StoreStockTimeView: View {
    let store: GunplaStore
    let repository: GunplaRepository

    @State private var editMode: EditMode = .inactive
    @State private var showingAddPicker = false
    @State private var newTime = Date()

    private let maxCount = 5

    private let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }()

    var body: some View {
        List {
            Section {
                let times = store.stockTimes ?? []
                ForEach(times.indices, id: \.self) { index in
                    HStack {
                        Image(systemName: "clock")
                            .foregroundStyle(.secondary)
                        Text(timeFormatter.string(from: times[index]))
                            .font(.body.monospacedDigit())
                    }
                }
                .onDelete { offsets in
                    var t = store.stockTimes ?? []
                    t.remove(atOffsets: offsets)
                    store.stockTimes = t
                    repository.updateStore()
                }

                if editMode == .active && (store.stockTimes ?? []).count < maxCount {
                    Button {
                        showingAddPicker = true
                    } label: {
                        Label("時刻を追加", systemImage: "plus.circle.fill")
                    }
                }
            } header: {
                Text("品出し時刻（\((store.stockTimes ?? []).count) / \(maxCount)件）")
            } footer: {
                if (store.stockTimes ?? []).isEmpty {
                    Text("編集ボタンをタップして品出し時刻を記録してください")
                }
            }
        }
        .navigationTitle(store.name)
        .navigationBarTitleDisplayMode(.inline)
        .environment(\.editMode, $editMode)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(editMode == .active ? "完了" : "編集") {
                    withAnimation {
                        editMode = editMode == .active ? .inactive : .active
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddPicker) {
            NavigationStack {
                Form {
                    Section("時刻を選択") {
                        DatePicker("", selection: $newTime, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                    }
                }
                .navigationTitle("品出し時刻を追加")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("キャンセル") { showingAddPicker = false }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("追加") {
                            var t = store.stockTimes ?? []
                            t.append(newTime)
                            store.stockTimes = t
                            repository.updateStore()
                            showingAddPicker = false
                        }
                    }
                }
            }
            .presentationDetents([.medium])
        }
    }
}
