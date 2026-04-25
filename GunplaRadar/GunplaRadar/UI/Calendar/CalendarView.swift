//
//  CalendarView.swift
//  GunplaRadar
//
//  Created by almashY on 2026/04/19.
//

import SwiftUI

struct CalendarView: View {
    @State private var viewModel: CalendarViewModel
    @State private var stockDiffItem: GunplaItem? = nil
    @AppStorage("restock_priority_mask") private var priorityMask: Int = 15

    init(repository: GunplaRepository) {
        _viewModel = State(initialValue: CalendarViewModel(repository: repository))
    }

    private let weekdays = ["日", "月", "火", "水", "木", "金", "土"]
    private let calendar = Calendar.current

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 月ナビゲーション
                HStack {
                    Button(action: { viewModel.previousMonth() }) {
                        Image(systemName: "chevron.left")
                    }
                    Spacer()
                    Text("\(viewModel.currentYear)年\(viewModel.currentMonth)月")
                        .font(.headline)
                    Spacer()
                    Button(action: { viewModel.nextMonth() }) {
                        Image(systemName: "chevron.right")
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)

                // 曜日ヘッダー
                HStack {
                    ForEach(weekdays, id: \.self) { day in
                        Text(day)
                            .font(.caption)
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(day == "日" ? .red : day == "土" ? .blue : .primary)
                    }
                }
                .padding(.horizontal, 8)

                // カレンダーグリッド
                let days = daysInMonth()
                let restockColors = viewModel.restockPriorityColors()
                let patrolSet = viewModel.patrolDates()

                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 4) {
                    ForEach(days, id: \.self) { date in
                        if let date = date {
                            CalendarDayCell(
                                date: date,
                                isSelected: viewModel.selectedDate.map { calendar.isDate($0, inSameDayAs: date) } ?? false,
                                restockTagColors: restockColors[dateKey(date)] ?? [],
                                hasPatrol: patrolSet.contains(dateKey(date)),
                                isToday: calendar.isDateInToday(date)
                            )
                            .onTapGesture {
                                viewModel.selectedDate = date
                            }
                        } else {
                            Color.clear.frame(height: 44)
                        }
                    }
                }
                .padding(.horizontal, 8)

                // 月合計金額
                if let total = viewModel.monthlyTotal(priorityMask: priorityMask) {
                    HStack {
                        Spacer()
                        Text("今月の購入予定金額 ¥\(total)")
                            .font(.caption.bold())
                            .foregroundStyle(.secondary)
                            .padding(.trailing, 8)
                            .padding(.top, 4)
                            .padding(.bottom, 4)
                    }
                }

                // 選択日のアイテム
                if let selected = viewModel.selectedDate {
                    selectedDateDetail(date: selected)
                } else {
                    Spacer()
                }
            }
            .navigationTitle("カレンダー")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $stockDiffItem, onDismiss: { viewModel.loadData() }) { item in
                StockDiffView(viewModel: viewModel, preselectedItem: item)
            }
            .onAppear { viewModel.loadData() }
            .navigationDestination(for: GunplaItem.self) { item in
                GunplaItemDetailView(
                    item: item,
                    repository: viewModel.repositoryRef,
                    onDelete: { viewModel.loadData() }
                )
            }
        }
    }

    private func selectedDateDetail(date: Date) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Divider()
            Text(date.japaneseDate)
                .font(.subheadline.bold())
                .padding(.horizontal)

            let restockItems = viewModel.itemsWithRestock.filter {
                guard let rd = $0.restockDate else { return false }
                return calendar.isDate(rd, inSameDayAs: date)
            }
            let plans = viewModel.patrolPlans.filter { calendar.isDate($0.date, inSameDayAs: date) }

            ScrollView {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(restockItems, id: \.id) { item in
                        HStack(spacing: 0) {
                            NavigationLink(value: item) {
                                CalendarItemRow(item: item)
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.plain)

                            Button {
                                stockDiffItem = item
                            } label: {
                                VStack(spacing: 3) {
                                    Image(systemName: "clock")
                                        .font(.subheadline)
                                    Text("品出し記録")
                                        .font(.caption2.bold())
                                }
                                .foregroundStyle(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 8)
                                .background(Color.orange)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            .padding(.trailing, 12)
                        }
                    }
                    ForEach(plans, id: \.id) { plan in
                        Label("巡回予定", systemImage: "figure.walk")
                            .font(.caption)
                            .padding(.horizontal)
                    }
                }
            }
        }
    }

    private func daysInMonth() -> [Date?] {
        var comps = DateComponents()
        comps.year = viewModel.currentYear
        comps.month = viewModel.currentMonth
        comps.day = 1
        guard let firstDay = calendar.date(from: comps) else { return [] }

        let weekday = calendar.component(.weekday, from: firstDay) - 1
        let range = calendar.range(of: .day, in: .month, for: firstDay)!
        var days: [Date?] = Array(repeating: nil, count: weekday)
        for day in range {
            comps.day = day
            days.append(calendar.date(from: comps))
        }
        let remainder = days.count % 7
        if remainder != 0 {
            days += Array(repeating: nil, count: 7 - remainder)
        }
        return days
    }

    private func dateKey(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

// MARK: - カレンダー用アイテム行

private struct CalendarItemRow: View {
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
        HStack(spacing: 10) {
            Rectangle()
                .fill(priorityColor)
                .frame(width: 4)
                .clipShape(RoundedRectangle(cornerRadius: 2))

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(item.name)
                        .font(.subheadline.bold())
                        .foregroundStyle(.primary)
                    Spacer()
                    Circle()
                        .fill(priorityColor)
                        .frame(width: 8, height: 8)
                }
                Text(item.grade)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if let data = item.imageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 6)
        .background(Color(.systemBackground))
    }
}

// MARK: - カレンダー日付セル

private struct CalendarDayCell: View {
    let date: Date
    let isSelected: Bool
    let restockTagColors: [Int]
    let hasPatrol: Bool
    let isToday: Bool

    private func priorityColor(_ priority: Int) -> Color {
        switch priority {
        case 3: return .red
        case 2: return .orange
        case 1: return .green
        default: return .blue
        }
    }

    private var dayNumber: Int {
        Calendar.current.component(.day, from: date)
    }

    var body: some View {
        VStack(spacing: 2) {
            let hasRestock = !restockTagColors.isEmpty
            Text("\(dayNumber)")
                .font(hasPatrol ? .callout.bold() : .callout)
                .frame(width: 32, height: 32)
                .background(isSelected ? Color.accentColor : isToday ? Color.accentColor.opacity(0.2) : Color.clear)
                .foregroundStyle(isSelected ? .white : hasRestock ? .red : .primary)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.red, lineWidth: hasRestock ? 2 : 0)
                )
            // 優先度カラーのドット（最大3つ表示）
            HStack(spacing: 2) {
                ForEach(Array(restockTagColors.prefix(3).enumerated()), id: \.offset) { _, priority in
                    Circle()
                        .fill(priorityColor(priority))
                        .frame(width: 5, height: 5)
                }
                if restockTagColors.isEmpty {
                    Color.clear.frame(width: 5, height: 5)
                }
            }
        }
        .frame(height: 44)
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
