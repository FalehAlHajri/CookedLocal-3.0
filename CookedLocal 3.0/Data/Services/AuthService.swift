//
//  AuthService.swift
//  Cooked Local
//

import Foundation

final class AuthService: AuthServiceProtocol {
    private let network = NetworkManager.shared
    private let session = SessionManager.shared
    private let tokenManager = TokenManager.shared

    // MARK: - Sign Up

    func signUp(name: String, email: String, password: String, role: UserRole) async throws -> SessionUser {
        let endpoint = role == .chef ? "auth/register/chef" : "auth/register/customer"

        let authData: APIAuthResponse
        if role == .chef {
            let body = RegisterChefRequest(shop_name: name, email: email, password: password, role: "provider")
            authData = try await network.request(path: endpoint, method: "POST", body: body, requiresAuth: false)
        } else {
            let body = RegisterCustomerRequest(name: name, email: email, password: password, role: "customer")
            authData = try await network.request(path: endpoint, method: "POST", body: body, requiresAuth: false)
        }

        // Save token from registration (needed for OTP verification which uses Bearer auth)
        tokenManager.saveToken(authData.token)
        tokenManager.saveOTPEmail(email)

        let user = SessionUser(
            id: authData.results.id ?? "",
            name: authData.results.name ?? name,
            email: authData.results.email,
            role: authData.results.role,
            profileUrl: nil,
            shopName: authData.results.shop?.shop_name
        )
        return user
    }

    // MARK: - Sign In

    func signIn(email: String, password: String) async throws -> SessionUser {
        let body = LoginRequest(email: email, password: password)
        let loginData: APIAuthResponse = try await network.request(
            path: "auth/login",
            method: "POST",
            body: body,
            requiresAuth: false
        )
        let user = SessionUser(
            id: loginData.results.id ?? "",
            name: loginData.results.name ?? "",
            email: loginData.results.email,
            role: loginData.results.role,
            profileUrl: nil,
            shopName: loginData.results.shop?.shop_name
        )
        return user
    }

    // MARK: - Registration OTP

    func requestRegistrationOTP(email: String) async throws {
        let body = ResendOTPRequest(email: email)
        try await network.requestVoid(path: "auth/resend-otp", method: "POST", body: body, requiresAuth: false)
    }

    func verifyRegistrationOTP(otp: String) async throws {
        // Backend extracts email from the Bearer token (saved during registration)
        let body = OTPVerifyRequest(otp: otp)
        try await network.requestVoid(path: "auth/verify-otp", method: "POST", body: body)
        tokenManager.clearOTPEmail()
    }

    // MARK: - Password Reset

    func requestPasswordReset(email: String) async throws {
        let body = ForgotPasswordRequest(email: email)
        // Backend returns { data: { token } } - a short-lived JWT for the reset flow
        let response: APIForgotPasswordResponse = try await network.request(
            path: "auth/forgot-password",
            method: "POST",
            body: body,
            requiresAuth: false
        )
        tokenManager.saveResetToken(response.token)
        tokenManager.saveOTPEmail(email)
    }

    func verifyPasswordResetOTP(otp: String) async throws {
        // Backend extracts email from reset token (Bearer), not from body
        guard let resetToken = tokenManager.getResetToken() else {
            throw APIError.serverError("Reset session expired. Please try again.")
        }
        let body = ForgotOTPVerifyRequest(otp: otp)
        try await network.requestVoid(
            path: "auth/forgot-otp-verify",
            method: "POST",
            body: body,
            requiresAuth: false,
            customToken: resetToken
        )
    }

    func resetPassword(newPassword: String, confirmPassword: String) async throws {
        guard let resetToken = tokenManager.getResetToken() else {
            throw APIError.serverError("Reset session expired. Please try again.")
        }
        let body = ResetPasswordRequest(newPassword: newPassword, confirmPassword: confirmPassword)
        try await network.requestVoid(
            path: "auth/reset-password",
            method: "POST",
            body: body,
            requiresAuth: false,
            customToken: resetToken
        )
        tokenManager.clearResetToken()
        tokenManager.clearOTPEmail()
    }

    // MARK: - Change Password (authenticated)

    func changePassword(oldPassword: String, newPassword: String, confirmPassword: String) async throws {
        let body = ChangePasswordRequest(oldPassword: oldPassword, newPassword: newPassword, confirmPassword: confirmPassword)
        try await network.requestVoid(path: "auth/change-password", method: "POST", body: body)
    }

    // MARK: - Logout

    func logout() {
        session.clearSession()
    }
}
