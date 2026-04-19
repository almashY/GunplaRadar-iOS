//
//  GunplaItem.swift
//  GunplaRadar
//
//  Created by almashY on 2026/04/19.
//

import Foundation
import SwiftData

@Model
class GunplaItem {
    @Attribute(.unique) var id: String
    var name: String
    var grade: String
    var price: Int?
    var imageData: Data?
    var url: String?
    var releaseDate: Date?
    var restockDate: Date?
    var purchasedDate: Date?
    var purchaseStoreId: String?
    var priority: Int  // 0:最高, 1:高, 2:中, 3:低
    var tagColor: Int  // 0-5

    init(
        id: String = UUID().uuidString,
        name: String,
        grade: String,
        price: Int? = nil,
        imageData: Data? = nil,
        url: String? = nil,
        releaseDate: Date? = nil,
        restockDate: Date? = nil,
        purchasedDate: Date? = nil,
        purchaseStoreId: String? = nil,
        priority: Int = 2,
        tagColor: Int = 0
    ) {
        self.id = id
        self.name = name
        self.grade = grade
        self.price = price
        self.imageData = imageData
        self.url = url
        self.releaseDate = releaseDate
        self.restockDate = restockDate
        self.purchasedDate = purchasedDate
        self.purchaseStoreId = purchaseStoreId
        self.priority = priority
        self.tagColor = tagColor
    }
}
