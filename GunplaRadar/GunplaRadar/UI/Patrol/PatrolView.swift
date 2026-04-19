//
//  PatrolView.swift
//  GunplaRadar
//
//  Created by almashY on 2026/04/19.
//

import SwiftUI

struct PatrolView: View {
    @State private var viewModel: PatrolViewModel
    @State private var showingForm = false
    @State private var selectedPlan: PatrolPlan? = nil

    init(repository: GunplaRepository) {
        _viewModel = State(initialValue: PatrolViewModel(repository: repository))
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.plans.isEmpty {
                    ContentUnavailableView(
                        "巡回予定がありません",
                        systemImage: "figure.walk",
                        description: Text("+ボタンから巡回予定を追加してください")
                    )
                } else {
                    List {
                        ForEach(viewModel.plans, id: \.id) { plan in
                            PatrolPlanRow(
                                plan: plan,
                                storeName: viewModel.storeName(for: plan.storeId),
                                itemCount: plan.targetItemIdList.count
                            )
                            .contentShape(Rectangle())
                            .onTapGesture { selectedPlan = plan }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    viewModel.deletePlan(plan)
                                } label: {
                                    Label("削除", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("巡回管理")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingForm = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingForm, onDismiss: { viewModel.loadData() }) {
                PatrolFormView(viewModel: viewModel)
            }
            .navigationDestination(item: $selectedPlan) { plan in
                PatrolDetailView(plan: plan, viewModel: viewModel)
            }
            .onAppear { viewModel.loadData() }
        }
    }
}

private struct PatrolPlanRow: View {
    let plan: PatrolPlan
    let storeName: String
    let itemCount: Int

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(storeName)
                    .font(.headline)
                HStack {
                    Text(plan.date.formatted(.dateTime.year().month().day()))
                    Text(plan.time.formatted(.dateTime.hour().minute()))
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
                HStack {
                    Label("\(itemCount)件", systemImage: "tag")
                        .font(.caption)
                    if plan.notifyEnabled {
                        Label("通知ON", systemImage: "bell.fill")
                            .font(.caption)
                            .foregroundStyle(.blue)
                    }
                }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}
