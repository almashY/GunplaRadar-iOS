//
//  GunplaStore.swift
//  GunplaRadar
//
//  Created by almashY on 2026/04/19.
//

import Foundation
import SwiftData

@Model
class GunplaStore {
    @Attribute(.unique) var id: String
    var name: String
    var latitude: Double
    var longitude: Double
    var isFavorite: Bool
    var averageDelayHours: Double

    init(
        id: String = UUID().uuidString,
        name: String,
        latitude: Double,
        longitude: Double,
        isFavorite: Bool = false,
        averageDelayHours: Double = 0.0
    ) {
        self.id = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.isFavorite = isFavorite
        self.averageDelayHours = averageDelayHours
    }
}
