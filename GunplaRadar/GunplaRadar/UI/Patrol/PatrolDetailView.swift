//
//  PatrolDetailView.swift
//  GunplaRadar
//
//  Created by almashY on 2026/04/19.
//

import SwiftUI

struct PatrolDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let plan: PatrolPlan
    let viewModel: PatrolViewModel
    @State private var showingDeleteConfirm = false
    @State private var showingEdit = false

    var body: some View {
        List {
            Section("巡回情報") {
                if let store = viewModel.store(for: plan.storeId) {
                    NavigationLink(destination: StoreStockTimeView(store: store, repository: viewModel.repositoryRef)) {
                        LabeledContent("店舗", value: store.name)
                    }
                } else {
                    LabeledContent("店舗", value: viewModel.storeName(for: plan.storeId))
                }
                LabeledContent("日付", value: plan.date.formatted(.dateTime.year().month().day()))
                LabeledContent("時間", value: plan.time.formatted(.dateTime.hour().minute()))
                LabeledContent("通知アラーム", value: plan.notifyOffsetList.isEmpty ? "設定なし" :
                    plan.notifyOffsetList.map { min in
                        min >= 60 ? "\(min / 60)時間前" : "\(min)分前"
                    }.joined(separator: "・")
                )
            }

            let targets = viewModel.targetItems(for: plan)
            if !targets.isEmpty {
                Section("対象アイテム (\(targets.count)件)") {
                    ForEach(targets, id: \.id) { item in
                        HStack {
                            Text(item.name)
                            Spacer()
                            Text(item.grade)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            Section {
                Button(role: .destructive) {
                    showingDeleteConfirm = true
                } label: {
                    Label("この巡回予定を削除", systemImage: "trash")
                            .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle("巡回詳細")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("編集") { showingEdit = true }
            }
        }
        .sheet(isPresented: $showingEdit) {
            PatrolFormView(viewModel: viewModel, editingPlan: plan)
        }
        .confirmationDialog("削除しますか？", isPresented: $showingDeleteConfirm, titleVisibility: .visible) {
            Button("削除", role: .destructive) {
                viewModel.deletePlan(plan)
                dismiss()
            }
            Button("キャンセル", role: .cancel) {}
        }
    }
}
