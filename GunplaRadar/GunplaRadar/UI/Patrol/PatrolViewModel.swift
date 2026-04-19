//
//  PatrolViewModel.swift
//  GunplaRadar
//
//  Created by almashY on 2026/04/19.
//

import Foundation
import SwiftData

@Observable
class PatrolViewModel {
    var plans: [PatrolPlan] = []
    var stores: [GunplaStore] = []
    var items: [GunplaItem] = []

    private let repository: GunplaRepository

    init(repository: GunplaRepository) {
        self.repository = repository
    }

    var repositoryRef: GunplaRepository { repository }

    func loadData() {
        plans = repository.fetchAllPlans()
        stores = repository.fetchAllStores()
        items = repository.fetchAllItems()
    }

    func storeName(for storeId: String) -> String {
        stores.first { $0.id == storeId }?.name ?? "不明な店舗"
    }

    func targetItems(for plan: PatrolPlan) -> [GunplaItem] {
        plan.targetItemIdList.compactMap { id in items.first { $0.id == id } }
    }

    func insertPlan(date: Date, time: Date, storeId: String, targetItemIds: [String], notifyEnabled: Bool) {
        let plan = PatrolPlan(
            date: date,
            time: time,
            storeId: storeId,
            targetItemIds: targetItemIds.joined(separator: ","),
            notifyEnabled: notifyEnabled
        )
        repository.insertPlan(plan)
        if notifyEnabled, let store = stores.first(where: { $0.id == storeId }) {
            NotificationManager.shared.schedulePatrolNotification(plan: plan, storeName: store.name)
        }
        loadData()
    }

    func deletePlan(_ plan: PatrolPlan) {
        NotificationManager.shared.cancelNotification(planId: plan.id)
        repository.deletePlan(plan)
        loadData()
    }
}
