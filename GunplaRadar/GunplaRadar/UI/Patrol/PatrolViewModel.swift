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

    func store(for storeId: String) -> GunplaStore? {
        stores.first { $0.id == storeId }
    }

    func targetItems(for plan: PatrolPlan) -> [GunplaItem] {
        plan.targetItemIdList.compactMap { id in items.first { $0.id == id } }
    }

    /// 指定日の前月・当月・翌月に再販予定日があるアイテムを返す
    func filteredItems(for date: Date) -> [GunplaItem] {
        let cal = Calendar.current
        guard let prevMonth = cal.date(byAdding: .month, value: -1, to: date),
              let nextMonth = cal.date(byAdding: .month, value:  1, to: date) else {
            return []
        }
        let targets: [(Int, Int)] = [
            (cal.component(.year, from: prevMonth), cal.component(.month, from: prevMonth)),
            (cal.component(.year, from: date),      cal.component(.month, from: date)),
            (cal.component(.year, from: nextMonth), cal.component(.month, from: nextMonth))
        ]
        return items.filter { item in
            guard let rd = item.restockDate else { return false }
            let rdYear  = cal.component(.year,  from: rd)
            let rdMonth = cal.component(.month, from: rd)
            return targets.contains { $0 == rdYear && $1 == rdMonth }
        }
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
