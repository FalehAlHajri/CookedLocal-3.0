//
//  OTPViewModel.swift
//  Cooked Local
//

import SwiftUI
import Combine

// MARK: - OTP Context

enum OTPContext: Hashable {
    case registration(email: String)
    case passwordReset(email: String)

    var email: String {
        switch self {
        case .registration(let email), .passwordReset(let email):
            return email
        }
    }
}

// MARK: - OTPViewModel

final class OTPViewModel: ObservableObject {
    @Published var otpDigits: [String] = Array(repeating: "", count: 6)
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?

    let emailOrPhone: String
    let otpContext: OTPContext

    private let router: Router
    private let authService: AuthService

    init(
        emailOrPhone: String,
        router: Router,
        authService: AuthService,
        context: OTPContext = .passwordReset(email: "")
    ) {
        self.emailOrPhone = emailOrPhone
        self.router = router
        self.authService = authService
        self.otpContext = context
    }

    var isComplete: Bool {
        otpDigits.allSatisfy { !$0.isEmpty }
    }

    var otpCode: String {
        otpDigits.joined()
    }

    @MainActor
    func verifyOTP() async {
        guard isComplete else { return }

        isLoading = true
        errorMessage = nil

        do {
            switch otpContext {
            case .registration:
                // Backend extracts email from Bearer token (saved during registration)
                try await authService.verifyRegistrationOTP(otp: otpCode)
                router.navigate(to: .success(
                    message: "Email Verified!",
                    subtitle: "Your account is ready. Please sign in.",
                    buttonTitle: "Sign In",
                    navigateToHome: false
                ))

            case .passwordReset:
                // Backend extracts email from reset token (Bearer)
                try await authService.verifyPasswordResetOTP(otp: otpCode)
                router.navigate(to: .newPassword)
            }
        } catch let apiError as APIError {
            errorMessage = apiError.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    @MainActor
    func resendOTP() async {
        isLoading = true
        errorMessage = nil

        do {
            switch otpContext {
            case .registration(let email):
                try await authService.requestRegistrationOTP(email: email)
            case .passwordReset(let email):
                try await authService.requestPasswordReset(email: email)
            }
            otpDigits = Array(repeating: "", count: 6)
        } catch let apiError as APIError {
            errorMessage = apiError.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
