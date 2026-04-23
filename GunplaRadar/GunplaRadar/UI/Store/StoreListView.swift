//
//  StoreListView.swift
//  GunplaRadar
//
//  Created by almashY on 2026/04/19.
//

import SwiftUI

struct StoreListView: View {
    @Bindable var viewModel: StoreViewModel

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("店舗名で検索", text: $viewModel.searchQuery)
                    .textFieldStyle(.plain)
                if !viewModel.searchQuery.isEmpty {
                    Button(action: { viewModel.searchQuery = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(10)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding()

            if viewModel.filteredStores.isEmpty {
                ContentUnavailableView("店舗がありません", systemImage: "map")
            } else {
                List {
                    ForEach(viewModel.filteredStores, id: \.id) { store in
                        NavigationLink(destination: StoreStockTimeView(store: store, repository: viewModel.repositoryRef)) {
                            StoreRow(store: store, onToggleFavorite: {
                                viewModel.toggleFavorite(store)
                            })
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                viewModel.deleteStore(store)
                            } label: {
                                Label("削除", systemImage: "trash")
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("店舗一覧")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { viewModel.loadStores() }
    }
}

private struct StoreRow: View {
    let store: GunplaStore
    let onToggleFavorite: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(store.name)
                    .font(.headline)
                Text(String(format: "%.4f, %.4f", store.latitude, store.longitude))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if store.averageDelayHours > 0 {
                    Text(String(format: "平均遅延: %.1f時間", store.averageDelayHours))
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            }
            Spacer()
            Button(action: onToggleFavorite) {
                Image(systemName: store.isFavorite ? "star.fill" : "star")
                    .foregroundStyle(store.isFavorite ? .yellow : .gray)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
    }
}
