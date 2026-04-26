//
//  AuthServiceProtocol.swift
//  Cooked Local
//

import Foundation

// MARK: - Auth Errors

enum AuthError: Error, LocalizedError {
    case invalidCredentials
    case networkError
    case userNotFound
    case invalidOTP
    case passwordMismatch
    case serverError(String)
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password."
        case .networkError:
            return "Network error. Please try again."
        case .userNotFound:
            return "User not found."
        case .invalidOTP:
            return "Invalid verification code."
        case .passwordMismatch:
            return "Passwords do not match."
        case .serverError(let message):
            return message
        case .unknown:
            return "An unknown error occurred."
        }
    }
}

// MARK: - Protocol

protocol AuthServiceProtocol {
    func signUp(name: String, email: String, password: String, role: UserRole) async throws -> SessionUser
    func signIn(email: String, password: String) async throws -> SessionUser
    func signInWithApple(idToken: String, fullName: String?, role: UserRole) async throws -> SessionUser
    func requestRegistrationOTP(email: String) async throws
    func verifyRegistrationOTP(otp: String) async throws
    func requestPasswordReset(email: String) async throws
    func verifyPasswordResetOTP(otp: String) async throws
    func resetPassword(newPassword: String, confirmPassword: String) async throws
    func changePassword(oldPassword: String, newPassword: String, confirmPassword: String) async throws
    func logout()
}
