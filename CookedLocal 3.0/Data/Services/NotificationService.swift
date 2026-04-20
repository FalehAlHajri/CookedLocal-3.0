//
//  NotificationService.swift
//  Cooked Local
//

import Foundation

final class NotificationService {
    private let network = NetworkManager.shared

    func fetchNotifications() async throws -> [APINotification] {
        try await network.requestPaginated(path: "notification/all")
    }

    func fetchUnreadCount() async throws -> Int {
        let notifications = try await fetchNotifications()
        return notifications.filter { $0.isRead == false }.count
    }
}
