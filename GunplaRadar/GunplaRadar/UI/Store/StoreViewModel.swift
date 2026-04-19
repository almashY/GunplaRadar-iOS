//
//  StoreViewModel.swift
//  GunplaRadar
//
//  Created by almashY on 2026/04/19.
//

import Foundation
import SwiftData

@Observable
class StoreViewModel {
    var stores: [GunplaStore] = []
    var searchQuery: String = ""

    private let repository: GunplaRepository

    init(repository: GunplaRepository) {
        self.repository = repository
    }

    var repositoryRef: GunplaRepository { repository }

    var filteredStores: [GunplaStore] {
        if searchQuery.isEmpty { return stores }
        return stores.filter { $0.name.localizedCaseInsensitiveContains(searchQuery) }
    }

    func loadStores() {
        stores = repository.fetchAllStores()
    }

    func addStore(name: String, latitude: Double, longitude: Double) {
        let store = GunplaStore(name: name, latitude: latitude, longitude: longitude)
        repository.insertStore(store)
        loadStores()
    }

    func deleteStore(_ store: GunplaStore) {
        repository.deleteStore(store)
        loadStores()
    }

    func toggleFavorite(_ store: GunplaStore) {
        store.isFavorite.toggle()
        repository.updateStore()
        loadStores()
    }
}
