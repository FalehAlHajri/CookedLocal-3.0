//
//  UserService.swift
//  Cooked Local
//

import Foundation

final class UserService {
    private let network = NetworkManager.shared

    // MARK: - Profile

    func fetchMyProfile() async throws -> APIUserProfile {
        try await network.request(path: "user/get-my-profile")
    }

    func updateMyProfile(name: String? = nil, image: Data? = nil) async throws -> APIUserProfile {
        var fields: [String: String] = [:]
        if let name = name { fields["name"] = name }

        var files: [NetworkManager.MultipartFile] = []
        if let image = image {
            files.append(NetworkManager.MultipartFile(
                fieldName: "profile",
                data: image,
                fileName: "profile.jpg",
                mimeType: "image/jpeg"
            ))
        }

        return try await network.requestMultipartMultiFile(
            path: "user/update-my-profile",
            method: "PATCH",
            fields: fields,
            files: files
        )
    }

    // MARK: - Update Shop Profile (provider)

    func updateShopProfile(
        shopName: String? = nil,
        bio: String? = nil,
        phoneNumber: String? = nil,
        location: String? = nil,
        facebookUrl: String? = nil,
        instagramUrl: String? = nil,
        whatsappNumber: String? = nil,
        profileImage: Data? = nil,
        bannerImage: Data? = nil,
        qualificationPDF: Data? = nil
    ) async throws -> APIUserProfile {
        var fields: [String: String] = [:]
        if let shopName = shopName { fields["shop_name"] = shopName }
        if let bio = bio { fields["bio"] = bio }
        if let phoneNumber = phoneNumber { fields["phone_number"] = phoneNumber }
        if let location = location { fields["location"] = location }
        if let facebookUrl = facebookUrl { fields["facebook_url"] = facebookUrl }
        if let instagramUrl = instagramUrl { fields["instagram_url"] = instagramUrl }
        if let whatsappNumber = whatsappNumber { fields["whatsapp_number"] = whatsappNumber }

        var files: [NetworkManager.MultipartFile] = []
        if let profileImage = profileImage {
            files.append(NetworkManager.MultipartFile(
                fieldName: "profile",
                data: profileImage,
                fileName: "profile.jpg",
                mimeType: "image/jpeg"
            ))
        }
        if let bannerImage = bannerImage {
            files.append(NetworkManager.MultipartFile(
                fieldName: "banner",
                data: bannerImage,
                fileName: "banner.jpg",
                mimeType: "image/jpeg"
            ))
        }
        if let qualificationPDF = qualificationPDF {
            files.append(NetworkManager.MultipartFile(
                fieldName: "qualification",
                data: qualificationPDF,
                fileName: "qualification.pdf",
                mimeType: "application/pdf"
            ))
        }

        return try await network.requestMultipartMultiFile(
            path: "user/update-my-profile",
            method: "PATCH",
            fields: fields,
            files: files
        )
    }

    // MARK: - Providers / Chefs

    func fetchProviders(page: Int = 1, limit: Int = 20) async throws -> [APIProvider] {
        let queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "limit", value: "\(limit)")
        ]
        return try await network.requestPaginated(path: "user/all-providers", queryItems: queryItems)
    }

    // MARK: - Dashboard (chef only)

    func fetchProviderDashboard() async throws -> APIProviderDashboard {
        try await network.request(path: "dashboard/provider/overview")
    }

    // MARK: - Change Password

    func changePassword(oldPassword: String, newPassword: String, confirmPassword: String) async throws {
        let body = ChangePasswordRequest(oldPassword: oldPassword, newPassword: newPassword, confirmPassword: confirmPassword)
        try await network.requestVoid(path: "auth/change-password", method: "POST", body: body)
    }
}
