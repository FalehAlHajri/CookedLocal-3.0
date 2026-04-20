//
//  NotificationViewModel.swift
//  Cooked Local
//

import SwiftUI
import Combine

final class NotificationViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var notifications: [APINotification] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?

    // MARK: - Dependencies
    private let router: Router
    private let notificationService: NotificationService

    // MARK: - Initialization
    init(router: Router, notificationService: NotificationService) {
        self.router = router
        self.notificationService = notificationService
        Task { await loadNotifications() }
    }

    // MARK: - Methods

    func goBack() {
        router.pop()
    }

    @MainActor
    func refresh() async {
        await loadNotifications()
    }

    // MARK: - Private Methods

    @MainActor
    private func loadNotifications() async {
        isLoading = true
        errorMessage = nil
        do {
            notifications = try await notificationService.fetchNotifications()
        } catch {
            errorMessage = error.localizedDescription
            notifications = []
        }
        isLoading = false
    }
}
