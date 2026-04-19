//
//  StockDelayRecord.swift
//  GunplaRadar
//
//  Created by almashY on 2026/04/19.
//

import Foundation
import SwiftData

@Model
class StockDelayRecord {
    @Attribute(.unique) var id: String
    var storeId: String
    var itemId: String
    var restockDate: Date
    var actualStockDate: Date
    var delayHours: Double

    init(
        id: String = UUID().uuidString,
        storeId: String,
        itemId: String,
        restockDate: Date,
        actualStockDate: Date,
        delayHours: Double
    ) {
        self.id = id
        self.storeId = storeId
        self.itemId = itemId
        self.restockDate = restockDate
        self.actualStockDate = actualStockDate
        self.delayHours = delayHours
    }
}
