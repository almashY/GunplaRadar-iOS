//
//  RestockPrioritySettingView.swift
//  GunplaRadar
//
//  Created by almashY on 2026/04/25.
//

import SwiftUI

struct RestockPrioritySettingView: View {
    @AppStorage("restock_priority_mask") private var priorityMask: Int = 15

    private let priorities: [(Int, String)] = [
        (0, "低"),
        (1, "中"),
        (2, "高"),
        (3, "最高")
    ]

    var body: some View {
        List {
            ForEach(priorities, id: \.0) { value, label in
                Button {
                    let bit = 1 << value
                    if priorityMask & bit != 0 {
                        priorityMask &= ~bit
                    } else {
                        priorityMask |= bit
                    }
                } label: {
                    HStack {
                        Text(label)
                        Spacer()
                        if priorityMask & (1 << value) != 0 {
                            Image(systemName: "checkmark")
                                .foregroundStyle(Color.accentColor)
                        }
                    }
                }
                .foregroundStyle(.primary)
            }
        }
        .navigationTitle("対象優先度")
        .navigationBarTitleDisplayMode(.inline)
    }
}
