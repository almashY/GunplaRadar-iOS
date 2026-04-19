//
//  PlaceDetailSheet.swift
//  GunplaRadar
//
//  Created by almashY on 2026/04/19.
//

import SwiftUI
import MapKit

struct PlaceDetailSheet: View {
    let mapItem: MKMapItem
    let viewModel: StoreViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingAddConfirm = false
    @State private var added = false

    private var name: String { mapItem.name ?? "不明" }
    private var address: String {
        let p = mapItem.placemark
        let parts = [p.thoroughfare, p.subThoroughfare, p.locality, p.administrativeArea]
        return parts.compactMap { $0 }.joined(separator: " ")
    }
    private var isAlreadyRegistered: Bool {
        viewModel.stores.contains {
            abs($0.latitude - mapItem.placemark.coordinate.latitude) < 0.0001 &&
            abs($0.longitude - mapItem.placemark.coordinate.longitude) < 0.0001
        }
    }

    var body: some View {
        NavigationStack {
            List {
                // ミニマップ
                Section {
                    Map(position: .constant(.region(MKCoordinateRegion(
                        center: mapItem.placemark.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                    )))) {
                        Marker(name, coordinate: mapItem.placemark.coordinate)
                    }
                    .frame(height: 160)
                    .listRowInsets(EdgeInsets())
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }

                Section("基本情報") {
                    LabeledContent("名前", value: name)
                    if !address.isEmpty {
                        LabeledContent("住所", value: address)
                    }
                    if let phone = mapItem.phoneNumber, !phone.isEmpty {
                        LabeledContent("電話", value: phone)
                        Button(action: { callPhone(phone) }) {
                            Label("電話する", systemImage: "phone")
                        }
                    }
                    if let url = mapItem.url {
                        Link(destination: url) {
                            Label("Webサイトを開く", systemImage: "safari")
                        }
                    }
                }

                Section {
                    if added || isAlreadyRegistered {
                        Label(
                            added ? "店舗に追加しました" : "登録済みの店舗です",
                            systemImage: added ? "checkmark.circle.fill" : "checkmark.circle"
                        )
                        .foregroundStyle(.green)
                    } else {
                        Button(action: { showingAddConfirm = true }) {
                            Label("ガンプラ巡回店舗に追加", systemImage: "plus.circle")
                                .foregroundStyle(Color.accentColor)
                        }
                    }
                }
            }
            .navigationTitle(name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("閉じる") { dismiss() }
                }
            }
            .confirmationDialog("\(name)を店舗リストに追加しますか？", isPresented: $showingAddConfirm, titleVisibility: .visible) {
                Button("追加") { addStore() }
                Button("キャンセル", role: .cancel) {}
            }
        }
    }

    private func addStore() {
        let coord = mapItem.placemark.coordinate
        viewModel.addStore(name: name, latitude: coord.latitude, longitude: coord.longitude)
        added = true
    }

    private func callPhone(_ phone: String) {
        let cleaned = phone.replacingOccurrences(of: "-", with: "").replacingOccurrences(of: " ", with: "")
        if let url = URL(string: "tel://\(cleaned)") {
            UIApplication.shared.open(url)
        }
    }
}
