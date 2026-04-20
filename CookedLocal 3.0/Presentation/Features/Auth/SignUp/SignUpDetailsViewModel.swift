//
//  SignUpDetailsViewModel.swift
//  Cooked Local
//

import SwiftUI
import Combine

final class SignUpDetailsViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var isFormValid: Bool = false

    let role: UserRole
    private let router: Router
    private let authService: AuthService
    private let validationService: ValidationService

    init(
        role: UserRole,
        router: Router,
        authService: AuthService,
        validationService: ValidationService
    ) {
        self.role = role
        self.router = router
        self.authService = authService
        self.validationService = validationService
    }

    func validateForm() {
        isFormValid = validationService.isValidName(name) &&
                      validationService.isValidEmail(email) &&
                      validationService.isValidPassword(password)
    }

    @MainActor
    func signUp() async {
        guard isFormValid else { return }

        isLoading = true
        errorMessage = nil

        do {
            _ = try await authService.signUp(
                name: name,
                email: email,
                password: password,
                role: role
            )
            // Navigate to OTP screen for email verification
            router.navigate(to: .registrationOTP(email: email))
        } catch let apiError as APIError {
            errorMessage = apiError.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
