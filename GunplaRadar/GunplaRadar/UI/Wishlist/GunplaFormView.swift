//
//  GunplaFormView.swift
//  GunplaRadar
//
//  Created by almashY on 2026/04/19.
//

import SwiftUI

struct GunplaFormView: View {
    @Environment(\.dismiss) private var dismiss

    let repository: GunplaRepository
    let editingItem: GunplaItem?

    @State private var name: String = ""
    @State private var grade: String = ""
    @State private var priceText: String = ""
    @State private var urlText: String = ""
    @State private var hasReleaseDate: Bool = false
    @State private var releaseDate: Date = Date()
    @State private var hasRestockDate: Bool = false
    @State private var restockDate: Date = Date()
    @State private var priority: Int = 2
    @State private var tagColor: Int = 0
    @State private var nameError: String? = nil
    @State private var gradeError: String? = nil

    private let priorityLabels = ["最高", "高", "中", "低"]
    private let tagColors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple]

    init(repository: GunplaRepository, editingItem: GunplaItem? = nil) {
        self.repository = repository
        self.editingItem = editingItem
    }

    var isEditing: Bool { editingItem != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section("基本情報") {
                    VStack(alignment: .leading, spacing: 4) {
                        TextField("名前 *", text: $name)
                        if let error = nameError {
                            Text(error).font(.caption).foregroundStyle(.red)
                        }
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        TextField("グレード *", text: $grade)
                        if let error = gradeError {
                            Text(error).font(.caption).foregroundStyle(.red)
                        }
                    }
                    TextField("価格", text: $priceText)
                        .keyboardType(.numberPad)
                    TextField("URL", text: $urlText)
                        .keyboardType(.URL)
                        .autocorrectionDisabled()
                }

                Section("日付") {
                    Toggle("発売日", isOn: $hasReleaseDate)
                    if hasReleaseDate {
                        DatePicker("", selection: $releaseDate, displayedComponents: .date)
                            .labelsHidden()
                    }
                    Toggle("再販日", isOn: $hasRestockDate)
                    if hasRestockDate {
                        DatePicker("", selection: $restockDate, displayedComponents: .date)
                            .labelsHidden()
                    }
                }

                Section("優先度") {
                    Picker("優先度", selection: $priority) {
                        ForEach(0..<4) { i in
                            Text(priorityLabels[i]).tag(i)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("タグカラー") {
                    HStack(spacing: 16) {
                        ForEach(0..<6) { i in
                            Circle()
                                .fill(tagColors[i])
                                .frame(width: 30, height: 30)
                                .overlay(
                                    Circle()
                                        .stroke(Color.primary, lineWidth: tagColor == i ? 2 : 0)
                                )
                                .onTapGesture { tagColor = i }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle(isEditing ? "編集" : "ガンプラ追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") { save() }
                }
            }
            .onAppear { loadIfEditing() }
        }
    }

    private func loadIfEditing() {
        guard let item = editingItem else { return }
        name = item.name
        grade = item.grade
        priceText = item.price.map { String($0) } ?? ""
        urlText = item.url ?? ""
        if let d = item.releaseDate { hasReleaseDate = true; releaseDate = d }
        if let d = item.restockDate { hasRestockDate = true; restockDate = d }
        priority = item.priority
        tagColor = item.tagColor
    }

    private func validate() -> Bool {
        nameError = name.trimmingCharacters(in: .whitespaces).isEmpty ? "名前は必須です" : nil
        gradeError = grade.trimmingCharacters(in: .whitespaces).isEmpty ? "グレードは必須です" : nil
        return nameError == nil && gradeError == nil
    }

    private func save() {
        guard validate() else { return }
        let price = Int(priceText)
        if let item = editingItem {
            item.name = name.trimmingCharacters(in: .whitespaces)
            item.grade = grade.trimmingCharacters(in: .whitespaces)
            item.price = price
            item.url = urlText.isEmpty ? nil : urlText
            item.releaseDate = hasReleaseDate ? releaseDate : nil
            item.restockDate = hasRestockDate ? restockDate : nil
            item.priority = priority
            item.tagColor = tagColor
            repository.updateItem()
        } else {
            let item = GunplaItem(
                name: name.trimmingCharacters(in: .whitespaces),
                grade: grade.trimmingCharacters(in: .whitespaces),
                price: price,
                url: urlText.isEmpty ? nil : urlText,
                releaseDate: hasReleaseDate ? releaseDate : nil,
                restockDate: hasRestockDate ? restockDate : nil,
                priority: priority,
                tagColor: tagColor
            )
            repository.insertItem(item)
        }
        dismiss()
    }
}
