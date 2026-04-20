//
//  ResetViewModel.swift
//  Cooked Local
//

import SwiftUI
import Combine

final class ResetViewModel: ObservableObject {
    @Published var emailOrPhone: String = ""
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?

    private let router: Router
    private let authService: AuthService
    private let validationService: ValidationService

    init(
        router: Router,
        authService: AuthService,
        validationService: ValidationService
    ) {
        self.router = router
        self.authService = authService
        self.validationService = validationService
    }

    var isInputValid: Bool {
        validationService.isValidEmail(emailOrPhone) ||
        validationService.isValidPhone(emailOrPhone)
    }

    @MainActor
    func requestReset() async {
        guard isInputValid else {
            errorMessage = "Please enter a valid email address."
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            try await authService.requestPasswordReset(email: emailOrPhone)
            router.navigate(to: .otp(emailOrPhone: emailOrPhone))
        } catch let apiError as APIError {
            errorMessage = apiError.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
