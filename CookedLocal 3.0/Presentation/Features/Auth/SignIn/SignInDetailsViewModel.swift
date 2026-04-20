//
//  SignInDetailsViewModel.swift
//  Cooked Local
//

import SwiftUI
import Combine

final class SignInDetailsViewModel: ObservableObject {
    @Published var emailOrPhone: String = ""
    @Published var password: String = ""
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?

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

    var isFormValid: Bool {
        (validationService.isValidEmail(emailOrPhone) ||
         validationService.isValidPhone(emailOrPhone)) &&
        validationService.isValidPassword(password)
    }

    @MainActor
    func signIn() async {
        guard isFormValid else {
            errorMessage = "Please enter a valid email and password."
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let user = try await authService.signIn(email: emailOrPhone, password: password)
            let destination: AppRoute = user.userRole == .chef ? .chefHome : .home
            router.replace(with: destination)
        } catch let apiError as APIError {
            errorMessage = apiError.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    @MainActor
    func navigateToResetPassword() {
        router.navigate(to: .resetPassword)
    }
}
