//
//  StockDiffView.swift
//  GunplaRadar
//
//  Created by almashY on 2026/04/19.
//

import SwiftUI

struct StockDiffView: View {
    @Environment(\.dismiss) private var dismiss
    let viewModel: CalendarViewModel

    @State private var selectedItemId: String = ""
    @State private var selectedStoreId: String = ""
    @State private var actualStockDate: Date = Date()
    @State private var stores: [GunplaStore] = []
    @State private var items: [GunplaItem] = []

    private var selectedItem: GunplaItem? {
        items.first { $0.id == selectedItemId }
    }

    private var canSave: Bool {
        !selectedItemId.isEmpty && !selectedStoreId.isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                itemSection
                storeSection
                dateSection
                if let item = selectedItem, let rd = item.restockDate {
                    delaySection(restockDate: rd)
                }
            }
            .navigationTitle("品出し差分登録")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") { save() }.disabled(!canSave)
                }
            }
            .onAppear {
                items = viewModel.repositoryRef.fetchItemsWithRestockDate()
                stores = viewModel.repositoryRef.fetchAllStores()
            }
        }
    }

    private var itemSection: some View {
        Section("ガンプラ選択") {
            Picker("アイテム", selection: $selectedItemId) {
                Text("選択してください").tag("")
                ForEach(items, id: \.id) { item in
                    Text(item.name).tag(item.id)
                }
            }
            if let item = selectedItem, let rd = item.restockDate {
                Text("再販予定: \(rd.formatted(.dateTime.year().month().day()))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var storeSection: some View {
        Section("店舗選択") {
            Picker("店舗", selection: $selectedStoreId) {
                Text("選択してください").tag("")
                ForEach(stores, id: \.id) { store in
                    Text(store.name).tag(store.id)
                }
            }
        }
    }

    private var dateSection: some View {
        Section("実際の品出し日") {
            DatePicker("品出し日", selection: $actualStockDate, displayedComponents: .date)
        }
    }

    private func delaySection(restockDate: Date) -> some View {
        let hours = actualStockDate.timeIntervalSince(restockDate) / 3600.0
        return Section("遅延時間") {
            Text(String(format: "%.1f 時間", hours))
                .foregroundStyle(hours > 0 ? Color.orange : Color.green)
        }
    }

    private func save() {
        guard let item = selectedItem,
              let store = stores.first(where: { $0.id == selectedStoreId }) else { return }
        viewModel.insertStockDelayRecord(item: item, store: store, actualStockDate: actualStockDate)
        dismiss()
    }
}
