//
//  CalendarViewModel.swift
//  GunplaRadar
//
//  Created by almashY on 2026/04/19.
//

import Foundation
import SwiftData

@Observable
class CalendarViewModel {
    var itemsWithRestock: [GunplaItem] = []
    var patrolPlans: [PatrolPlan] = []
    var currentYear: Int
    var currentMonth: Int
    var selectedDate: Date? = nil

    private let repository: GunplaRepository

    init(repository: GunplaRepository) {
        self.repository = repository
        let cal = Calendar.current
        let now = Date()
        currentYear = cal.component(.year, from: now)
        currentMonth = cal.component(.month, from: now)
    }

    var repositoryRef: GunplaRepository { repository }

    var currentMonthDate: Date {
        var comps = DateComponents()
        comps.year = currentYear
        comps.month = currentMonth
        comps.day = 1
        return Calendar.current.date(from: comps) ?? Date()
    }

    func previousMonth() {
        var comps = DateComponents()
        comps.month = -1
        if let newDate = Calendar.current.date(byAdding: comps, to: currentMonthDate) {
            let cal = Calendar.current
            currentYear = cal.component(.year, from: newDate)
            currentMonth = cal.component(.month, from: newDate)
        }
    }

    func nextMonth() {
        var comps = DateComponents()
        comps.month = 1
        if let newDate = Calendar.current.date(byAdding: comps, to: currentMonthDate) {
            let cal = Calendar.current
            currentYear = cal.component(.year, from: newDate)
            currentMonth = cal.component(.month, from: newDate)
        }
    }

    func loadData() {
        itemsWithRestock = repository.fetchItemsWithRestockDate()
        patrolPlans = repository.fetchAllPlans()
    }

    func restockDates() -> Set<String> {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return Set(itemsWithRestock.compactMap { $0.restockDate }.map { formatter.string(from: $0) })
    }

    func patrolDates() -> Set<String> {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return Set(patrolPlans.map { formatter.string(from: $0.date) })
    }

    func insertStockDelayRecord(item: GunplaItem, store: GunplaStore, actualStockDate: Date) {
        guard let restockDate = item.restockDate else { return }
        let delayHours = actualStockDate.timeIntervalSince(restockDate) / 3600.0
        let record = StockDelayRecord(
            storeId: store.id,
            itemId: item.id,
            restockDate: restockDate,
            actualStockDate: actualStockDate,
            delayHours: delayHours
        )
        repository.insertRecord(record)
        let avg = repository.averageDelayHours(storeId: store.id)
        store.averageDelayHours = avg
        repository.updateStore()
    }
}
