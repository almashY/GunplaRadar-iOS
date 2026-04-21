//
//  StoreView.swift
//  GunplaRadar
//
//  Created by almashY on 2026/04/19.
//

import SwiftUI
import MapKit
import CoreLocation

struct StoreView: View {
    @State private var viewModel: StoreViewModel
    @State private var showingList = false
    @State private var selectedStoreId: String? = nil
    @State private var selectedMapFeature: MapFeature? = nil
    @State private var placeDetailItem: MKMapItem? = nil
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 35.6812, longitude: 139.7671),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
    )
    @State private var searchCompleter = LocationSearchCompleter()
    @State private var searchQuery: String = ""
    @State private var isSearchFocused: Bool = false
    @State private var locationManager = CLLocationManager()

    init(repository: GunplaRepository) {
        _viewModel = State(initialValue: StoreViewModel(repository: repository))
    }

    private var selectedStore: GunplaStore? {
        guard let id = selectedStoreId else { return nil }
        return viewModel.stores.first { $0.id == id }
    }

    private var showSuggestions: Bool {
        isSearchFocused && !searchCompleter.suggestions.isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                mapLayer
                searchLayer
                fabLayer
            }
            .navigationTitle("店舗分析")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $showingList) {
                StoreListView(viewModel: viewModel)
            }
            .sheet(isPresented: Binding(
                get: { selectedStore != nil },
                set: { if !$0 { selectedStoreId = nil } }
            )) {
                if let store = selectedStore {
                    StoreDetailSheet(store: store, viewModel: viewModel)
                        .presentationDetents([.medium, .large])
                }
            }
            .sheet(isPresented: Binding(
                get: { placeDetailItem != nil },
                set: { if !$0 { placeDetailItem = nil; selectedMapFeature = nil } }
            )) {
                if let item = placeDetailItem {
                    PlaceDetailSheet(mapItem: item, viewModel: viewModel)
                        .presentationDetents([.medium, .large])
                        .onDisappear { viewModel.loadStores() }
                }
            }
            .onChange(of: selectedMapFeature) { _, feature in
                guard let feature else { return }
                Task {
                    if let item = await searchCompleter.fetchMapItem(for: feature) {
                        placeDetailItem = item
                    }
                }
            }
            .onAppear {
                viewModel.loadStores()
                locationManager.requestWhenInUseAuthorization()
            }
        }
    }

    // MARK: - Layers

    private var mapLayer: some View {
        Map(position: $cameraPosition, selection: $selectedMapFeature) {
            UserAnnotation()
            ForEach(viewModel.stores, id: \.id) { store in
                Annotation(
                    store.name,
                    coordinate: CLLocationCoordinate2D(
                        latitude: store.latitude,
                        longitude: store.longitude
                    ),
                    anchor: .bottom
                ) {
                    StoreAnnotationView(store: store, isSelected: selectedStoreId == store.id)
                        .onTapGesture {
                            selectedStoreId = store.id
                            selectedMapFeature = nil
                        }
                }
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .onTapGesture {
            dismissKeyboard()
            isSearchFocused = false
        }
    }

    private var searchLayer: some View {
        VStack(spacing: 0) {
            searchBar
            if showSuggestions {
                suggestionList
            }
            Spacer()
        }
    }

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
            TextField("場所・住所・店名を検索", text: $searchQuery)
                .autocorrectionDisabled()
                .onTapGesture { isSearchFocused = true }
                .onChange(of: searchQuery) { _, newValue in
                    searchCompleter.queryFragment = newValue
                    isSearchFocused = true
                }
            if !searchQuery.isEmpty {
                Button(action: {
                    searchQuery = ""
                    searchCompleter.queryFragment = ""
                    isSearchFocused = false
                    dismissKeyboard()
                }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
            }
        }
        .padding(10)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 4)
        .padding(.horizontal)
        .padding(.top, 8)
    }

    private var suggestionList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(searchCompleter.suggestions, id: \.self) { suggestion in
                    Button(action: { selectSuggestion(suggestion) }) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(suggestion.title)
                                .font(.body)
                                .foregroundStyle(.primary)
                            if !suggestion.subtitle.isEmpty {
                                Text(suggestion.subtitle)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    Divider().padding(.leading, 16)
                }
            }
        }
        .frame(maxHeight: 280)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 4)
        .padding(.horizontal)
        .padding(.top, 4)
    }

    private var fabLayer: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                VStack(spacing: 12) {
                    Button(action: moveToCurrentLocation) {
                        Image(systemName: "location.fill")
                            .padding(12)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    Button(action: { showingList = true }) {
                        Image(systemName: "list.bullet")
                            .padding(12)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                }
                .padding()
            }
        }
    }

    // MARK: - Actions

    private func selectSuggestion(_ suggestion: MKLocalSearchCompletion) {
        searchQuery = suggestion.title
        isSearchFocused = false
        dismissKeyboard()
        Task {
            if let item = await searchCompleter.fetchMapItem(for: suggestion) {
                cameraPosition = .region(MKCoordinateRegion(
                    center: item.placemark.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                ))
                placeDetailItem = item
            }
        }
    }

    private func moveToCurrentLocation() {
        cameraPosition = .userLocation(
            followsHeading: false,
            fallback: .region(MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 35.6812, longitude: 139.7671),
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            ))
        )
    }

    private func dismissKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil
        )
    }
}

// MARK: - Annotation View

private struct StoreAnnotationView: View {
    let store: GunplaStore
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 2) {
            Image(systemName: isSelected ? "mappin.circle.fill" : "mappin.circle")
                .foregroundStyle(store.isFavorite ? Color.red : Color.orange)
                .font(isSelected ? .title : .title2)
                .shadow(radius: isSelected ? 4 : 0)
            if store.averageDelayHours > 0 {
                Text(String(format: "%.1fh", store.averageDelayHours))
                    .font(.caption2)
                    .padding(2)
                    .background(Color.white.opacity(0.9))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
        }
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}

// MARK: - Store Detail Sheet（登録済み店舗）

private struct StoreDetailSheet: View {
    let store: GunplaStore
    let viewModel: StoreViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("店舗情報") {
                    LabeledContent("名前", value: store.name)
                    LabeledContent("緯度", value: String(format: "%.6f", store.latitude))
                    LabeledContent("経度", value: String(format: "%.6f", store.longitude))
                    LabeledContent("お気に入り", value: store.isFavorite ? "★ 登録済み" : "未登録")
                    if store.averageDelayHours > 0 {
                        LabeledContent("平均品出し遅延", value: String(format: "%.1f 時間", store.averageDelayHours))
                    }
                }
                Section {
                    Button(action: { viewModel.toggleFavorite(store) }) {
                        Label(
                            store.isFavorite ? "お気に入り解除" : "お気に入り登録",
                            systemImage: store.isFavorite ? "star.slash" : "star"
                        )
                    }
                    Button(role: .destructive, action: {
                        viewModel.deleteStore(store)
                        dismiss()
                    }) {
                        Label("削除", systemImage: "trash")
                    }
                }
            }
            .navigationTitle(store.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("閉じる") { dismiss() }
                }
            }
        }
    }
}

