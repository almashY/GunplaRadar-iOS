//
//  SettingsView.swift
//  GunplaRadar
//
//  Created by almashY on 2026/04/19.
//

import SwiftUI

struct SettingsView: View {
    @State private var viewModel: SettingsViewModel
    @State private var showingDeleteConfirm = false

    init(repository: GunplaRepository) {
        _viewModel = State(initialValue: SettingsViewModel(repository: repository))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("通知") {
                    Toggle("巡回通知を有効にする", isOn: $viewModel.notificationsEnabled)
                }

                Section("データ管理") {
                    Button(role: .destructive) {
                        showingDeleteConfirm = true
                    } label: {
                        Label("すべてのデータを削除", systemImage: "trash")
                    }
                }

                Section("アプリ情報") {
                    LabeledContent("バージョン", value: "1.0.0")
                    LabeledContent("アプリ名", value: "GunplaRadar")
                }
            }
            .navigationTitle("設定")
            .confirmationDialog("全データを削除しますか？", isPresented: $showingDeleteConfirm, titleVisibility: .visible) {
                Button("削除", role: .destructive) {
                    viewModel.deleteAllData()
                }
                Button("キャンセル", role: .cancel) {}
            } message: {
                Text("この操作は取り消せません")
            }
        }
    }
}
