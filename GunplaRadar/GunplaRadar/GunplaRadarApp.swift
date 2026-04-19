//
//  GunplaRadarApp.swift
//  GunplaRadar
//
//  Created by almashY on 2026/04/19.
//

import SwiftUI
import SwiftData

@main
struct GunplaRadarApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(for: [
            GunplaItem.self,
            GunplaStore.self,
            PatrolPlan.self,
            StockDelayRecord.self
        ])
    }
}
