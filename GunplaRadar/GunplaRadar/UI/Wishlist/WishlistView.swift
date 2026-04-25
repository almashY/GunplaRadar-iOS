//
//  WishlistView.swift
//  GunplaRadar
//
//  Created by almashY on 2026/04/19.
//

import SwiftUI
import SwiftData

struct WishlistView: View {
    @State private var viewModel: WishlistViewModel
    @State private var showingAddForm = false
    @State private var selectedItem: GunplaItem?

    init(repository: GunplaRepository) {
        _viewModel = State(initialValue: WishlistViewModel(repository: repository))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    TextField("名前・グレードで検索", text: $viewModel.searchQuery)
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
                .padding(.horizontal)
                .padding(.top, 8)

                HStack {
                    Text("並び替え:")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Picker("", selection: $viewModel.sortOrder) {
                        ForEach(SortOrder.allCases, id: \.self) { order in
                            Text(order.rawValue).tag(order)
                        }
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 4)

                if viewModel.filteredItems.isEmpty {
                    ContentUnavailableView(
                        "アイテムがありません",
                        systemImage: "list.bullet",
                        description: Text("右上の+ボタンからガンプラを追加してください")
                    )
                } else {
                    List {
                        ForEach(viewModel.filteredItems, id: \.id) { item in
                            NavigationLink(value: item) {
                                GunplaItemCard(item: item)
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    viewModel.deleteItem(item)
                                } label: {
                                    Label("削除", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("ほしい物リスト")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddForm = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .navigationDestination(for: GunplaItem.self) { item in
                GunplaItemDetailView(item: item, repository: viewModel.repositoryRef, onDelete: {
                    viewModel.loadItems()
                })
            }
            .sheet(isPresented: $showingAddForm, onDismiss: { viewModel.loadItems() }) {
                GunplaFormView(repository: viewModel.repositoryRef)
            }
            .onAppear { viewModel.loadItems() }
        }
    }
}

private struct GunplaItemCard: View {
    let item: GunplaItem

    private var priorityColor: Color {
        switch item.priority {
        case 3: return .red
        case 2: return .orange
        case 1: return .green
        default: return .blue
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            Rectangle()
                .fill(priorityColor)
                .frame(width: 4)
                .clipShape(RoundedRectangle(cornerRadius: 2))

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(item.name)
                        .font(.headline)
                    Spacer()
                }
                Text(item.grade)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                HStack {
                    if let price = item.price {
                        Text("¥\(price)")
                            .font(.caption)
                    }
                    if let restockDate = item.restockDate {
                        Text(restockDate.japaneseDate)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            if let data = item.imageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 56, height: 56)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
        }
        .padding(.vertical, 4)
    }
}
