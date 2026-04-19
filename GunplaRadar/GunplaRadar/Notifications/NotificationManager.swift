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

    func schedulePatrolNotification(plan: PatrolPlan, storeName: String) {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: plan.date)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: plan.time)

        var combined = DateComponents()
        combined.year = dateComponents.year
        combined.month = dateComponents.month
        combined.day = dateComponents.day
        combined.hour = timeComponents.hour
        combined.minute = timeComponents.minute

        guard let patrolDate = calendar.date(from: combined) else { return }
        let notifyDate = patrolDate.addingTimeInterval(-3600) // 1時間前

        guard notifyDate > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = "ガンプラ巡回予定"
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        content.body = "\(formatter.string(from: patrolDate)) に \(storeName) への巡回予定"
        content.sound = .default

        let triggerComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: notifyDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
        let request = UNNotificationRequest(identifier: "patrol_\(plan.id)", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }

    func cancelNotification(planId: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["patrol_\(planId)"])
    }
}
