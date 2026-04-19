//
//  WishlistViewModel.swift
//  GunplaRadar
//
//  Created by almashY on 2026/04/19.
//

import Foundation
import SwiftData

enum SortOrder: String, CaseIterable {
    case priority = "優先度"
    case name = "名前"
    case priceAsc = "価格(安い順)"
    case priceDesc = "価格(高い順)"
    case releaseDate = "発売日"
}

@Observable
class WishlistViewModel {
    var items: [GunplaItem] = []
    var searchQuery: String = ""
    var sortOrder: SortOrder = .priority
    var isLoading: Bool = false

    let repositoryRef: GunplaRepository
    private var repository: GunplaRepository { repositoryRef }

    init(repository: GunplaRepository) {
        self.repositoryRef = repository
    }

    var filteredItems: [GunplaItem] {
        let base = items.filter { $0.purchasedDate == nil }
        let searched: [GunplaItem]
        if searchQuery.isEmpty {
            searched = base
        } else {
            searched = base.filter {
                $0.name.localizedCaseInsensitiveContains(searchQuery) ||
                $0.grade.localizedCaseInsensitiveContains(searchQuery)
            }
        }
        return searched.sorted { lhs, rhs in
            switch sortOrder {
            case .priority:
                return lhs.priority < rhs.priority
            case .name:
                return lhs.name < rhs.name
            case .priceAsc:
                return (lhs.price ?? Int.max) < (rhs.price ?? Int.max)
            case .priceDesc:
                return (lhs.price ?? 0) > (rhs.price ?? 0)
            case .releaseDate:
                let l = lhs.releaseDate ?? Date.distantFuture
                let r = rhs.releaseDate ?? Date.distantFuture
                return l < r
            }
        }
    }

    func loadItems() {
        items = repository.fetchAllItems()
    }

    func deleteItem(_ item: GunplaItem) {
        repository.deleteItem(item)
        loadItems()
    }

    func markAsPurchased(_ item: GunplaItem, storeId: String?) {
        item.purchasedDate = Date()
        item.purchaseStoreId = storeId
        repository.updateItem()
        loadItems()
    }
}
