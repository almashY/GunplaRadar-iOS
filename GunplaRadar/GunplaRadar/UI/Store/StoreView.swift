//
//  StoreView.swift
//  GunplaRadar
//
//  Created by almashY on 2026/04/19.
//

import SwiftUI
import MapKit

struct StoreView: View {
    @State private var viewModel: StoreViewModel
    @State private var showingList = false
    @State private var showingAddStore = false
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 35.6812, longitude: 139.7671),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
    )

    init(repository: GunplaRepository) {
        _viewModel = State(initialValue: StoreViewModel(repository: repository))
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                Map(position: $cameraPosition) {
                    ForEach(viewModel.stores, id: \.id) { store in
                        Annotation(
                            store.name,
                            coordinate: CLLocationCoordinate2D(
                                latitude: store.latitude,
                                longitude: store.longitude
                            ),
                            anchor: .bottom
                        ) {
                            VStack(spacing: 2) {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundStyle(store.isFavorite ? .yellow : .red)
                                    .font(.title2)
                                if store.averageDelayHours > 0 {
                                    Text(String(format: "%.1fh", store.averageDelayHours))
                                        .font(.caption2)
                                        .padding(2)
                                        .background(Color.white.opacity(0.8))
                                        .clipShape(RoundedRectangle(cornerRadius: 4))
                                }
                            }
                        }
                    }
                }

                VStack(spacing: 12) {
                    Button(action: { showingList = true }) {
                        Image(systemName: "list.bullet")
                            .padding(12)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    Button(action: { showingAddStore = true }) {
                        Image(systemName: "plus")
                            .padding(12)
                            .background(Color.accentColor)
                            .foregroundStyle(.white)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                }
                .padding()
            }
            .navigationTitle("店舗分析")
            .navigationDestination(isPresented: $showingList) {
                StoreListView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingAddStore, onDismiss: { viewModel.loadStores() }) {
                AddStoreSheet(viewModel: viewModel)
            }
            .onAppear { viewModel.loadStores() }
        }
    }
}

private struct AddStoreSheet: View {
    @Environment(\.dismiss) private var dismiss
    let viewModel: StoreViewModel

    @State private var name = ""
    @State private var latText = ""
    @State private var lonText = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("店舗情報") {
                    TextField("店舗名", text: $name)
                    TextField("緯度", text: $latText)
                        .keyboardType(.decimalPad)
                    TextField("経度", text: $lonText)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("店舗追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("追加") { add() }
                        .disabled(name.isEmpty || latText.isEmpty || lonText.isEmpty)
                }
            }
        }
    }

    private func add() {
        guard let lat = Double(latText), let lon = Double(lonText) else { return }
        viewModel.addStore(name: name, latitude: lat, longitude: lon)
        dismiss()
    }
}
