//
//  PatrolNotificationSettingView.swift
//  GunplaRadar
//
//  Created by almashY on 2026/04/25.
//

import SwiftUI

struct PatrolNotificationSettingView: View {
    @Binding var selectedOffsets: Set<Int>

    private let options: [(Int, String)] = [
        (5,   "5分前"),
        (10,  "10分前"),
        (15,  "15分前"),
        (30,  "30分前"),
        (60,  "1時間前"),
        (120, "2時間前"),
        (180, "3時間前")
    ]

    var body: some View {
        List {
            Section {
                ForEach(options, id: \.0) { minutes, label in
                    Button {
                        if selectedOffsets.contains(minutes) {
                            selectedOffsets.remove(minutes)
                        } else if selectedOffsets.count < 3 {
                            selectedOffsets.insert(minutes)
                        }
                    } label: {
                        HStack {
                            Text(label)
                            Spacer()
                            if selectedOffsets.contains(minutes) {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Color.accentColor)
                            }
                        }
                    }
                    .foregroundStyle(
                        !selectedOffsets.contains(minutes) && selectedOffsets.count >= 3
                            ? .secondary : .primary
                    )
                }
            } header: {
                Text("通知タイミング")
            } footer: {
                Text("最大3つまで選択できます（現在\(selectedOffsets.count)件）")
            }
        }
        .navigationTitle("通知アラーム")
        .navigationBarTitleDisplayMode(.inline)
    }
}
