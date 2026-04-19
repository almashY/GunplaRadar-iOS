//
//  MainTabView.swift
//  GunplaRadar
//
//  Created by almashY on 2026/04/19.
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var repository: GunplaRepository?

    var body: some View {
        Group {
            if let repo = repository {
                TabView {
                    WishlistView(repository: repo)
                        .tabItem {
                            Label("ほしい物", systemImage: "list.bullet")
                        }
                    CalendarView(repository: repo)
                        .tabItem {
                            Label("カレンダー", systemImage: "calendar")
                        }
                    StoreView(repository: repo)
                        .tabItem {
                            Label("店舗", systemImage: "location.fill")
                        }
                    PatrolView(repository: repo)
                        .tabItem {
                            Label("巡回", systemImage: "figure.walk")
                        }
                    SettingsView(repository: repo)
                        .tabItem {
                            Label("設定", systemImage: "gearshape")
                        }
                }
            }
        }
        .onAppear {
            repository = GunplaRepository(modelContext: modelContext)
            Task {
                await NotificationManager.shared.requestPermission()
            }
        }
    }
}
