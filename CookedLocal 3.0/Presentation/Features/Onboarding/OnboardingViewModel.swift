//
//  OnboardingViewModel.swift
//  Cooked Local
//

import SwiftUI
import Combine

final class OnboardingViewModel: ObservableObject {
    private let router: Router

    init(router: Router) {
        self.router = router
    }

    @MainActor
    func navigateToRoleSelection() {
        router.navigate(to: .selectRole)
    }
}
