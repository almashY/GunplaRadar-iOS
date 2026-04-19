//
//  LocationSearchCompleter.swift
//  GunplaRadar
//
//  Created by almashY on 2026/04/19.
//

import Foundation
import MapKit
import SwiftUI

@Observable
class LocationSearchCompleter: NSObject, MKLocalSearchCompleterDelegate {
    var suggestions: [MKLocalSearchCompletion] = []
    var queryFragment: String = "" {
        didSet { completer.queryFragment = queryFragment }
    }

    private let completer = MKLocalSearchCompleter()

    override init() {
        super.init()
        completer.delegate = self
        completer.resultTypes = [.address, .pointOfInterest]
    }

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        suggestions = completer.results
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        suggestions = []
    }

    /// 候補からMKMapItemを取得（名前・住所・電話・URLを含む）
    func fetchMapItem(for completion: MKLocalSearchCompletion) async -> MKMapItem? {
        let request = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: request)
        let response = try? await search.start()
        return response?.mapItems.first
    }

    /// MapFeatureからMKMapItemを取得
    func fetchMapItem(for feature: MapFeature) async -> MKMapItem? {
        guard let title = feature.title else { return nil }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = title
        request.region = MKCoordinateRegion(
            center: feature.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
        request.resultTypes = .pointOfInterest
        let search = MKLocalSearch(request: request)
        let response = try? await search.start()
        // 座標が近いものを優先
        return response?.mapItems.min(by: {
            $0.placemark.coordinate.distance(to: feature.coordinate) <
            $1.placemark.coordinate.distance(to: feature.coordinate)
        })
    }
}

extension CLLocationCoordinate2D {
    func distance(to other: CLLocationCoordinate2D) -> Double {
        let loc1 = CLLocation(latitude: latitude, longitude: longitude)
        let loc2 = CLLocation(latitude: other.latitude, longitude: other.longitude)
        return loc1.distance(from: loc2)
    }
}
