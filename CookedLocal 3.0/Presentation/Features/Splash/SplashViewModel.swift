//
//  SplashViewModel.swift
//  Cooked Local
//

import SwiftUI
import Combine

final class SplashViewModel: ObservableObject {
    @Published private(set) var shouldNavigate = false

    private let router: Router

    init(router: Router) {
        self.router = router
    }

    @MainActor
    func startSplashTimer() {
        Task {
            // Wait for logo animation: 2s display + 0.5s fade = 2.5s total
            try? await Task.sleep(nanoseconds: 2_500_000_000)

            SessionManager.shared.refreshFromStorage()

            // Navigate based on auth state
            if SessionManager.shared.isAuthenticated,
               let user = SessionManager.shared.currentUser {
                let destination: AppRoute = user.userRole == .chef ? .chefHome : .home
                router.replace(with: destination)
            } else {
                router.replace(with: .onboarding)
            }
        }
    }
}
