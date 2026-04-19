//
//  SettingsViewModel.swift
//  GunplaRadar
//
//  Created by almashY on 2026/04/19.
//

import Foundation

@Observable
class SettingsViewModel {
    var notificationsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(notificationsEnabled, forKey: "notifications_enabled")
        }
    }

    private let repository: GunplaRepository

    init(repository: GunplaRepository) {
        self.repository = repository
        self.notificationsEnabled = UserDefaults.standard.bool(forKey: "notifications_enabled")
    }

    func setNotificationsEnabled(_ enabled: Bool) {
        notificationsEnabled = enabled
    }

    func deleteAllData() {
        repository.deleteAllData()
    }
}
