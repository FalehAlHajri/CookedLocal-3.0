//
//  SelectRoleViewModel.swift
//  Cooked Local
//

import SwiftUI
import Combine

final class SelectRoleViewModel: ObservableObject {
    @Published var selectedRole: UserRole?

    private let router: Router

    init(router: Router) {
        self.router = router
    }

    @MainActor
    func selectRole(_ role: UserRole) {
        selectedRole = role
        router.navigate(to: .signUp(role: role))
    }
}
