//
//  SignInDetailsViewModel.swift
//  Cooked Local
//

import SwiftUI
import Combine
import AuthenticationServices

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
    func signInWithApple() async {
        isLoading = true
        errorMessage = nil
        do {
            let credentials = try await AppleSignInService.shared.signIn()
            let fullName = credentials.fullName?.formatted()
            let user = try await authService.signInWithApple(
                idToken: credentials.identityToken,
                fullName: fullName,
                role: role
            )
            SessionManager.shared.saveSession(user: user, token: TokenManager.shared.getToken() ?? "")
            let destination: AppRoute = user.userRole == .chef ? .chefHome : .home
            router.replace(with: destination)
        } catch let apiError as APIError {
            errorMessage = apiError.errorDescription
        } catch {
            if let authError = error as? ASAuthorizationError, authError.code == .canceled {
                // User cancelled — silently ignore
            } else {
                errorMessage = error.localizedDescription
            }
        }
        isLoading = false
    }

    @MainActor
    func navigateToResetPassword() {
        router.navigate(to: .resetPassword)
    }
}
