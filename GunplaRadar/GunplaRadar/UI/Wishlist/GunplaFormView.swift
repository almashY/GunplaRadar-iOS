//
//  GunplaFormView.swift
//  GunplaRadar
//
//  Created by almashY on 2026/04/19.
//

import SwiftUI
import PhotosUI

struct GunplaFormView: View {
    @Environment(\.dismiss) private var dismiss

    let repository: GunplaRepository
    let editingItem: GunplaItem?

    private let gradeOptions = ["RE", "PG", "MG", "RG", "HG", "EG", "その他"]

    @State private var name: String = ""
    @State private var selectedGrade: String = "HG"
    @State private var customGrade: String = ""
    @State private var priceText: String = ""
    @State private var urlText: String = ""
    @State private var hasReleaseDate: Bool = false
    @State private var releaseDate: Date = Date()
    @State private var hasRestockDate: Bool = false
    @State private var restockDate: Date = Date()
    @State private var priority: Int = 1
    @State private var tagColor: Int = 0
    @State private var nameError: String? = nil
    @State private var gradeError: String? = nil
    @State private var imageData: Data? = nil
    @State private var selectedPhotoItem: PhotosPickerItem? = nil

    private let priorityLabels = ["低", "中", "高", "最高"]
    private let tagColors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple]

    init(repository: GunplaRepository, editingItem: GunplaItem? = nil) {
        self.repository = repository
        self.editingItem = editingItem
    }

    var isEditing: Bool { editingItem != nil }

    var body: some View {
        NavigationStack {
            Form {
                basicInfoSection
                Section("画像") { imagePickerSection }
                dateSection
                prioritySection
                tagColorSection
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
            .onChange(of: selectedPhotoItem) { _, newItem in
                Task {
                    guard let newItem,
                          let data = try? await newItem.loadTransferable(type: Data.self) else { return }
                    imageData = ImageProcessor.compress(data)
                }
            }
        }
    }

    private var basicInfoSection: some View {
        Section("基本情報") {
            VStack(alignment: .leading, spacing: 4) {
                TextField("名前 *", text: $name)
                if let error = nameError {
                    Text(error).font(.caption).foregroundStyle(.red)
                }
            }
            Picker("グレード", selection: $selectedGrade) {
                ForEach(gradeOptions, id: \.self) { Text($0).tag($0) }
            }
            if selectedGrade == "その他" {
                VStack(alignment: .leading, spacing: 4) {
                    TextField("グレードを入力", text: $customGrade)
                    if let error = gradeError {
                        Text(error).font(.caption).foregroundStyle(.red)
                    }
                }
            }
            TextField("価格", text: $priceText)
                .keyboardType(.numberPad)
            TextField("URL", text: $urlText)
                .keyboardType(.URL)
                .autocorrectionDisabled()
        }
    }

    private var dateSection: some View {
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
    }

    private var prioritySection: some View {
        Section("優先度") {
            Picker("優先度", selection: $priority) {
                ForEach(0..<4) { i in
                    Text(priorityLabels[i]).tag(i)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    private var tagColorSection: some View {
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

    @ViewBuilder
    private var imagePickerSection: some View {
        GeometryReader { geometry in
            HStack {
                Spacer()
                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    if let data = imageData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: geometry.size.width * 0.8)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    } else {
                        VStack(spacing: 6) {
                            Image(systemName: "photo.badge.plus")
                                .font(.largeTitle)
                            Text("画像を選択")
                                .font(.caption)
                        }
                        .foregroundStyle(Color.accentColor)
                        .frame(width: geometry.size.width * 0.8, height: 80)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                Spacer()
            }
        }
        .frame(minHeight: 100)
        if imageData != nil {
            Button(role: .destructive) {
                imageData = nil
                selectedPhotoItem = nil
            } label: {
                Label("画像を削除", systemImage: "trash")
            }
        }
    }

    private var resolvedGrade: String {
        selectedGrade == "その他" ? customGrade.trimmingCharacters(in: .whitespaces) : selectedGrade
    }

    private func loadIfEditing() {
        guard let item = editingItem else { return }
        name = item.name
        if gradeOptions.contains(item.grade) {
            selectedGrade = item.grade
        } else {
            selectedGrade = "その他"
            customGrade = item.grade
        }
        priceText = item.price.map { String($0) } ?? ""
        urlText = item.url ?? ""
        if let d = item.releaseDate { hasReleaseDate = true; releaseDate = d }
        if let d = item.restockDate { hasRestockDate = true; restockDate = d }
        priority = item.priority
        tagColor = item.tagColor
        imageData = item.imageData
    }

    private func validate() -> Bool {
        nameError = name.trimmingCharacters(in: .whitespaces).isEmpty ? "名前は必須です" : nil
        gradeError = resolvedGrade.isEmpty ? "グレードを入力してください" : nil
        return nameError == nil && gradeError == nil
    }

    private func save() {
        guard validate() else { return }
        let price = Int(priceText)
        if let item = editingItem {
            item.name = name.trimmingCharacters(in: .whitespaces)
            item.grade = resolvedGrade
            item.price = price
            item.imageData = imageData
            item.url = urlText.isEmpty ? nil : urlText
            item.releaseDate = hasReleaseDate ? releaseDate : nil
            item.restockDate = hasRestockDate ? restockDate : nil
            item.priority = priority
            item.tagColor = tagColor
            repository.updateItem()
        } else {
            let item = GunplaItem(
                name: name.trimmingCharacters(in: .whitespaces),
                grade: resolvedGrade,
                price: price,
                imageData: imageData,
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
