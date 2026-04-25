//
//  PatrolFormView.swift
//  GunplaRadar
//
//  Created by almashY on 2026/04/19.
//

import SwiftUI

struct PatrolFormView: View {
    @Environment(\.dismiss) private var dismiss
    let viewModel: PatrolViewModel
    let editingPlan: PatrolPlan?

    @State private var selectedStoreId: String = ""
    @State private var patrolDate: Date = Date()
    @State private var patrolTime: Date = Date()
    @State private var selectedItemIds: Set<String> = []
    @State private var selectedOffsets: Set<Int> = []

    init(viewModel: PatrolViewModel, editingPlan: PatrolPlan? = nil) {
        self.viewModel = viewModel
        self.editingPlan = editingPlan
    }

    private var isEditing: Bool { editingPlan != nil }

    private var canSave: Bool {
        viewModel.stores.contains(where: { $0.id == selectedStoreId })
    }

    var body: some View {
        NavigationStack {
            Form {
                storeSection
                dateSection
                itemSection
                notifySection
            }
            .navigationTitle(isEditing ? "巡回予定を編集" : "巡回予定作成")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { loadIfEditing() }
            .onChange(of: patrolDate) { _, newDate in
                let validIds = Set(viewModel.filteredItems(for: newDate).map { $0.id })
                selectedItemIds = selectedItemIds.intersection(validIds)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") { save() }.disabled(!canSave)
                }
            }
        }
    }

    private func loadIfEditing() {
        guard let plan = editingPlan else { return }
        selectedStoreId = plan.storeId
        patrolDate = plan.date
        patrolTime = plan.time
        selectedItemIds = Set(plan.targetItemIdList)
        selectedOffsets = Set(plan.notifyOffsetList)
    }

    private var storeSection: some View {
        Section("店舗選択") {
            Picker("店舗", selection: $selectedStoreId) {
                Text("選択してください").tag("")
                ForEach(viewModel.stores, id: \.id) { store in
                    Text(store.name).tag(store.id)
                }
            }
        }
    }

    private var dateSection: some View {
        Section("日時") {
            DatePicker("日付", selection: $patrolDate, displayedComponents: .date)
            DatePicker("時間", selection: $patrolTime, displayedComponents: .hourAndMinute)
        }
    }

    private var itemSection: some View {
        let filtered = viewModel.filteredItems(for: patrolDate)
        return Section("対象アイテム（前後1ヶ月の再販予定）") {
            if filtered.isEmpty {
                Text("前後1ヶ月に再販予定のアイテムがありません").foregroundStyle(.secondary)
            } else {
                ForEach(filtered, id: \.id) { item in
                    itemRow(item)
                }
            }
        }
    }

    private func itemRow(_ item: GunplaItem) -> some View {
        HStack {
            Text("\(item.grade)：\(item.name)")
            Spacer()
            if selectedItemIds.contains(item.id) {
                Image(systemName: "checkmark").foregroundStyle(Color.accentColor)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if selectedItemIds.contains(item.id) {
                selectedItemIds.remove(item.id)
            } else {
                selectedItemIds.insert(item.id)
            }
        }
    }

    private var notifyLabel: String {
        if selectedOffsets.isEmpty { return "設定なし" }
        return selectedOffsets.sorted().map { min in
            min >= 60 ? "\(min / 60)時間前" : "\(min)分前"
        }.joined(separator: "・")
    }

    private var notifySection: some View {
        Section {
            NavigationLink(destination: PatrolNotificationSettingView(selectedOffsets: $selectedOffsets)) {
                LabeledContent("通知アラーム", value: notifyLabel)
            }
        }
    }

    private func save() {
        guard canSave else { return }
        if let plan = editingPlan {
            viewModel.updatePlan(
                plan,
                date: patrolDate,
                time: patrolTime,
                storeId: selectedStoreId,
                targetItemIds: Array(selectedItemIds),
                notifyOffsets: Array(selectedOffsets)
            )
        } else {
            viewModel.insertPlan(
                date: patrolDate,
                time: patrolTime,
                storeId: selectedStoreId,
                targetItemIds: Array(selectedItemIds),
                notifyOffsets: Array(selectedOffsets)
            )
        }
        dismiss()
    }
}
