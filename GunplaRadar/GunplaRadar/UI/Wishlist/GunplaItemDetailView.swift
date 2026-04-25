//
//  GunplaItemDetailView.swift
//  GunplaRadar
//
//  Created by almashY on 2026/04/19.
//

import SwiftUI

struct GunplaItemDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let item: GunplaItem
    let repository: GunplaRepository
    let onDelete: () -> Void

    @State private var showingEdit = false
    @State private var showingDeleteConfirm = false

    private let priorityLabels = ["低", "中", "高", "最高"]

    private var priorityColor: Color {
        switch item.priority {
        case 3: return .red
        case 2: return .orange
        case 1: return .green
        default: return .blue
        }
    }

    var body: some View {
        GeometryReader { geometry in
            List {
                Section {
                    HStack {
                        Rectangle()
                            .fill(priorityColor)
                            .frame(width: 6)
                            .clipShape(RoundedRectangle(cornerRadius: 3))
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.name)
                                .font(.title2.bold())
                            Text(item.grade)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.leading, 4)
                    }
                    .padding(.vertical, 4)
                }

                Section("詳細情報") {
                    if let price = item.price {
                        LabeledContent("価格", value: "¥\(price)")
                    }
                    LabeledContent("優先度", value: priorityLabels[safe: item.priority] ?? "-")
                    if let releaseDate = item.releaseDate {
                        LabeledContent("発売日", value: releaseDate.japaneseDate)
                    }
                    if let restockDate = item.restockDate {
                        LabeledContent("再販日", value: restockDate.japaneseDate)
                    }
                    if let purchasedDate = item.purchasedDate {
                        LabeledContent("購入日", value: purchasedDate.japaneseDate)
                    }
                }

                // 画像セクション（詳細情報の下・画面幅の80%・見切れなし・中央揃え）
                if let data = item.imageData, let uiImage = UIImage(data: data) {
                    Section("画像") {
                        HStack {
                            Spacer()
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: geometry.size.width * 0.80)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            Spacer()
                        }
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    }
                }

                if let urlString = item.url, let url = URL(string: urlString) {
                    Section("リンク") {
                        Link(destination: url) {
                            HStack {
                                Image(systemName: "safari")
                                    .foregroundStyle(Color.accentColor)
                                Text(urlString)
                                    .font(.footnote)
                                    .foregroundStyle(Color.accentColor)
                                    .lineLimit(2)
                            }
                        }
                    }
                }

                Section {
                    Button(role: .destructive) {
                        showingDeleteConfirm = true
                    } label: {
                        Label("削除", systemImage: "trash")
                            .foregroundStyle(.red)
                    }
                }
            }
        }
        .navigationTitle(item.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("編集") { showingEdit = true }
            }
        }
        .sheet(isPresented: $showingEdit) {
            GunplaFormView(repository: repository, editingItem: item)
        }
        .confirmationDialog("削除しますか？", isPresented: $showingDeleteConfirm, titleVisibility: .visible) {
            Button("削除", role: .destructive) {
                repository.deleteItem(item)
                onDelete()
                dismiss()
            }
            Button("キャンセル", role: .cancel) {}
        }
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
