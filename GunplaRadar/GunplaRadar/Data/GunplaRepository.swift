//
//  GunplaRepository.swift
//  GunplaRadar
//
//  Created by almashY on 2026/04/19.
//

import Foundation
import SwiftData

@Observable
class GunplaRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - GunplaItem

    func fetchAllItems() -> [GunplaItem] {
        let descriptor = FetchDescriptor<GunplaItem>(
            sortBy: [SortDescriptor(\.priority), SortDescriptor(\.name)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func fetchUnpurchasedItems() -> [GunplaItem] {
        var descriptor = FetchDescriptor<GunplaItem>(
            predicate: #Predicate { $0.purchasedDate == nil },
            sortBy: [SortDescriptor(\.priority), SortDescriptor(\.name)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func fetchItemsWithRestockDate() -> [GunplaItem] {
        var descriptor = FetchDescriptor<GunplaItem>(
            predicate: #Predicate { $0.restockDate != nil }
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func fetchItem(id: String) -> GunplaItem? {
        var descriptor = FetchDescriptor<GunplaItem>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1
        return (try? modelContext.fetch(descriptor))?.first
    }

    func insertItem(_ item: GunplaItem) {
        modelContext.insert(item)
        save()
    }

    func updateItem() {
        save()
    }

    func deleteItem(_ item: GunplaItem) {
        modelContext.delete(item)
        save()
    }

    func deleteAllItems() {
        let items = fetchAllItems()
        items.forEach { modelContext.delete($0) }
        save()
    }

    // MARK: - GunplaStore

    func fetchAllStores() -> [GunplaStore] {
        let descriptor = FetchDescriptor<GunplaStore>(
            sortBy: [SortDescriptor(\.name)]
        )
        let stores = (try? modelContext.fetch(descriptor)) ?? []
        return stores.sorted { $0.isFavorite && !$1.isFavorite }
    }

    func fetchFavoriteStores() -> [GunplaStore] {
        let descriptor = FetchDescriptor<GunplaStore>(
            predicate: #Predicate { $0.isFavorite == true }
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func fetchStore(id: String) -> GunplaStore? {
        var descriptor = FetchDescriptor<GunplaStore>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1
        return (try? modelContext.fetch(descriptor))?.first
    }

    func insertStore(_ store: GunplaStore) {
        modelContext.insert(store)
        save()
    }

    func updateStore() {
        save()
    }

    func deleteStore(_ store: GunplaStore) {
        modelContext.delete(store)
        save()
    }

    func deleteAllStores() {
        let stores = fetchAllStores()
        stores.forEach { modelContext.delete($0) }
        save()
    }

    // MARK: - PatrolPlan

    func fetchAllPlans() -> [PatrolPlan] {
        let descriptor = FetchDescriptor<PatrolPlan>(
            sortBy: [SortDescriptor(\.date), SortDescriptor(\.time)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func fetchPlan(id: String) -> PatrolPlan? {
        var descriptor = FetchDescriptor<PatrolPlan>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1
        return (try? modelContext.fetch(descriptor))?.first
    }

    func fetchPlans(for date: Date) -> [PatrolPlan] {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: date)
        guard let end = calendar.date(byAdding: .day, value: 1, to: start) else { return [] }
        let descriptor = FetchDescriptor<PatrolPlan>(
            predicate: #Predicate { $0.date >= start && $0.date < end }
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func insertPlan(_ plan: PatrolPlan) {
        modelContext.insert(plan)
        save()
    }

    func updatePlan() {
        save()
    }

    func deletePlan(_ plan: PatrolPlan) {
        modelContext.delete(plan)
        save()
    }

    func deleteAllPlans() {
        let plans = fetchAllPlans()
        plans.forEach { modelContext.delete($0) }
        save()
    }

    // MARK: - StockDelayRecord

    func fetchAllRecords() -> [StockDelayRecord] {
        let descriptor = FetchDescriptor<StockDelayRecord>()
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func fetchRecords(storeId: String) -> [StockDelayRecord] {
        let descriptor = FetchDescriptor<StockDelayRecord>(
            predicate: #Predicate { $0.storeId == storeId }
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func averageDelayHours(storeId: String) -> Double {
        let records = fetchRecords(storeId: storeId)
        guard !records.isEmpty else { return 0.0 }
        return records.map { $0.delayHours }.reduce(0, +) / Double(records.count)
    }

    func insertRecord(_ record: StockDelayRecord) {
        modelContext.insert(record)
        save()
    }

    func deleteAllRecords() {
        let records = fetchAllRecords()
        records.forEach { modelContext.delete($0) }
        save()
    }

    // MARK: - Bulk delete

    func deleteAllData() {
        deleteAllItems()
        deleteAllStores()
        deleteAllPlans()
        deleteAllRecords()
    }

    // MARK: - Private

    private func save() {
        try? modelContext.save()
    }
}
