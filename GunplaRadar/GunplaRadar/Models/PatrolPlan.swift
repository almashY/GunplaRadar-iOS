//
//  PatrolPlan.swift
//  GunplaRadar
//
//  Created by almashY on 2026/04/19.
//

import Foundation
import SwiftData

@Model
class PatrolPlan {
    @Attribute(.unique) var id: String
    var date: Date
    var time: Date
    var storeId: String
    var targetItemIds: String  // カンマ区切り
    var notifyEnabled: Bool

    init(
        id: String = UUID().uuidString,
        date: Date,
        time: Date,
        storeId: String,
        targetItemIds: String = "",
        notifyEnabled: Bool = true
    ) {
        self.id = id
        self.date = date
        self.time = time
        self.storeId = storeId
        self.targetItemIds = targetItemIds
        self.notifyEnabled = notifyEnabled
    }

    var targetItemIdList: [String] {
        targetItemIds.split(separator: ",").map(String.init).filter { !$0.isEmpty }
    }
}
