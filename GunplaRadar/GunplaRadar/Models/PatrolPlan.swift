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
    var notifyOffsets: String?  // カンマ区切り分数（例: "60,30,5"）nil=通知なし

    init(
        id: String = UUID().uuidString,
        date: Date,
        time: Date,
        storeId: String,
        targetItemIds: String = "",
        notifyOffsets: String? = nil
    ) {
        self.id = id
        self.date = date
        self.time = time
        self.storeId = storeId
        self.targetItemIds = targetItemIds
        self.notifyOffsets = notifyOffsets
        self.notifyEnabled = notifyOffsets != nil && !notifyOffsets!.isEmpty
    }

    var targetItemIdList: [String] {
        targetItemIds.split(separator: ",").map(String.init).filter { !$0.isEmpty }
    }

    var notifyOffsetList: [Int] {
        guard let offsets = notifyOffsets, !offsets.isEmpty else { return [] }
        return offsets.split(separator: ",").compactMap { Int($0) }.sorted()
    }
}
