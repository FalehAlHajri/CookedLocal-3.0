//
//  ResetPasswordViewModel.swift
//  Cooked Local
//

import SwiftUI
import Combine

final class ResetPasswordViewModel: ObservableObject {
    @Published var newPassword: String = ""
    @Published var confirmPassword: String = ""
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

    var isFormValid: Bool {
        validationService.isValidPassword(newPassword) &&
        newPassword == confirmPassword
    }

    var passwordsMatch: Bool {
        newPassword == confirmPassword || confirmPassword.isEmpty
    }

    @MainActor
    func resetPassword() async {
        guard isFormValid else {
            if !passwordsMatch {
                errorMessage = AuthError.passwordMismatch.localizedDescription
            }
            return
        }

        guard TokenManager.shared.getResetToken() != nil else {
            errorMessage = "Session expired. Please start the password reset process again."
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            try await authService.resetPassword(newPassword: newPassword, confirmPassword: confirmPassword)
            router.navigate(to: .success(
                message: "Password Updated!",
                subtitle: "Successfully",
                buttonTitle: "Back to Sign In",
                navigateToHome: false
            ))
        } catch let apiError as APIError {
            errorMessage = apiError.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
