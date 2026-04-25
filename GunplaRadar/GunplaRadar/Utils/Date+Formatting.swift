//
//  Date+Formatting.swift
//  GunplaRadar
//
//  Created by almashY on 2026/04/25.
//

import Foundation

extension Date {
    /// 2026年4月25日（土）
    var japaneseDate: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ja_JP")
        f.dateFormat = "yyyy年M月d日（E）"
        return f.string(from: self)
    }

    /// H:mm（例: 9:05）
    var japaneseTime: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ja_JP")
        f.dateFormat = "H:mm"
        return f.string(from: self)
    }
}
