//
//  NotificationManager.swift
//  GunplaRadar
//
//  Created by almashY on 2026/04/19.
//

import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()

    private init() {}

    func requestPermission() async {
        try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
    }

    func schedulePatrolNotifications(plan: PatrolPlan, storeName: String) {
        cancelNotifications(planId: plan.id)

        let offsets = plan.notifyOffsetList
        guard !offsets.isEmpty else { return }

        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: plan.date)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: plan.time)

        var combined = DateComponents()
        combined.year  = dateComponents.year
        combined.month = dateComponents.month
        combined.day   = dateComponents.day
        combined.hour  = timeComponents.hour
        combined.minute = timeComponents.minute

        guard let patrolDate = calendar.date(from: combined) else { return }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"

        for (index, offsetMinutes) in offsets.enumerated() {
            let notifyDate = patrolDate.addingTimeInterval(TimeInterval(-offsetMinutes * 60))
            guard notifyDate > Date() else { continue }

            let content = UNMutableNotificationContent()
            content.title = "ガンプラ巡回予定"
            let label = offsetMinutes >= 60 ? "\(offsetMinutes / 60)時間前" : "\(offsetMinutes)分前"
            content.body = "\(label)：\(formatter.string(from: patrolDate)) に \(storeName) への巡回予定"
            content.sound = .default

            let triggerComponents = calendar.dateComponents(
                [.year, .month, .day, .hour, .minute], from: notifyDate
            )
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
            let request = UNNotificationRequest(
                identifier: "patrol_\(plan.id)_\(index)",
                content: content,
                trigger: trigger
            )
            UNUserNotificationCenter.current().add(request)
        }
    }

    func cancelNotifications(planId: String) {
        let ids = (0..<3).map { "patrol_\(planId)_\($0)" }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
    }
}
