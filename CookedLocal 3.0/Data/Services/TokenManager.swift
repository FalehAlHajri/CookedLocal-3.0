//
//  TokenManager.swift
//  Cooked Local
//

import Foundation

// MARK: - Session User

struct SessionUser: Codable, Equatable {
    let id: String
    let name: String
    let email: String
    let role: String  // "customer", "provider", "admin"
    var profileUrl: String?
    var shopName: String?

    var userRole: UserRole {
        role == "provider" ? .chef : .customer
    }
}

// MARK: - TokenManager

final class TokenManager {
    static let shared = TokenManager()

    private let tokenKey = "auth_token"
    private let currentUserKey = "current_user"
    private let otpEmailKey = "otp_pending_email"
    private let resetTokenKey = "reset_password_token"

    private let defaults = UserDefaults.standard

    private init() {}

    // MARK: - Token

    func saveToken(_ token: String) {
        defaults.set(token, forKey: tokenKey)
    }

    func getToken() -> String? {
        defaults.string(forKey: tokenKey)
    }

    func deleteToken() {
        defaults.removeObject(forKey: tokenKey)
    }

    // MARK: - Current User

    func saveCurrentUser(_ user: SessionUser) {
        if let data = try? JSONEncoder().encode(user) {
            defaults.set(data, forKey: currentUserKey)
        }
    }

    func getCurrentUser() -> SessionUser? {
        guard let data = defaults.data(forKey: currentUserKey) else { return nil }
        return try? JSONDecoder().decode(SessionUser.self, from: data)
    }

    func deleteCurrentUser() {
        defaults.removeObject(forKey: currentUserKey)
    }

    // MARK: - Auth State

    var isLoggedIn: Bool {
        getToken() != nil && getCurrentUser() != nil
    }

    // MARK: - OTP Email (for flows that persist email across screens)

    var savedEmail: String? {
        getOTPEmail()
    }

    func saveOTPEmail(_ email: String) {
        defaults.set(email, forKey: otpEmailKey)
    }

    func getOTPEmail() -> String? {
        defaults.string(forKey: otpEmailKey)
    }

    func clearOTPEmail() {
        defaults.removeObject(forKey: otpEmailKey)
    }

    // MARK: - Reset Password Token (short-lived JWT from forgot-password)

    func saveResetToken(_ token: String) {
        defaults.set(token, forKey: resetTokenKey)
    }

    func getResetToken() -> String? {
        defaults.string(forKey: resetTokenKey)
    }

    func clearResetToken() {
        defaults.removeObject(forKey: resetTokenKey)
    }
}
