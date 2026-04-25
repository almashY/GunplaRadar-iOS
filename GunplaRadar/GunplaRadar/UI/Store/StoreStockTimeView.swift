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
    @State private var showingResetConfirm = false
    @State private var deletingIndex: Int? = nil
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
                        Spacer()
                        if editMode == .active {
                            Button {
                                deletingIndex = index
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundStyle(.red)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            var t = store.stockTimes ?? []
                            t.remove(at: index)
                            store.stockTimes = t
                            repository.updateStore()
                        } label: {
                            Label("削除", systemImage: "trash")
                        }
                    }
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
            Section("品出し差分") {
                let avg = store.averageDelayHours
                LabeledContent("平均差分") {
                    Text(avg == 0 ? "記録なし" : String(format: "%+.1f時間", avg))
                        .foregroundStyle(avg == 0 ? .secondary : .primary)
                }
                Button(role: .destructive) {
                    showingResetConfirm = true
                } label: {
                    Label("差分データをリセット", systemImage: "arrow.counterclockwise")
                        .foregroundStyle(.red)
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
        .confirmationDialog("この時刻を削除しますか？", isPresented: Binding(
            get: { deletingIndex != nil },
            set: { if !$0 { deletingIndex = nil } }
        ), titleVisibility: .visible) {
            Button("削除", role: .destructive) {
                if let index = deletingIndex {
                    var t = store.stockTimes ?? []
                    t.remove(at: index)
                    store.stockTimes = t
                    repository.updateStore()
                }
                deletingIndex = nil
            }
            Button("キャンセル", role: .cancel) { deletingIndex = nil }
        }
        .confirmationDialog("差分データをリセットしますか？", isPresented: $showingResetConfirm, titleVisibility: .visible) {
            Button("リセット", role: .destructive) {
                repository.deleteRecords(storeId: store.id)
                store.averageDelayHours = 0.0
                repository.updateStore()
            }
            Button("キャンセル", role: .cancel) {}
        } message: {
            Text("この操作は取り消せません")
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
