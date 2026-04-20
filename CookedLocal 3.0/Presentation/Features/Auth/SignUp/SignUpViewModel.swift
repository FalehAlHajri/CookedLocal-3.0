//
//  SignUpViewModel.swift
//  Cooked Local
//

import SwiftUI
import Combine

final class SignUpViewModel: ObservableObject {
    @Published var emailOrPhone: String = ""
    @Published private(set) var isValid: Bool = false

    let role: UserRole
    private let router: Router
    private let validationService: ValidationService

    init(role: UserRole, router: Router, validationService: ValidationService) {
        self.role = role
        self.router = router
        self.validationService = validationService
    }

    func validateInput() {
        isValid = validationService.isValidEmail(emailOrPhone) ||
                  validationService.isValidPhone(emailOrPhone)
    }

    @MainActor
    func continueToDetails() {
        router.navigate(to: .signUpDetails(role: role))
    }

    @MainActor
    func navigateToSignIn() {
        router.navigate(to: .signIn(role: role))
    }
}
