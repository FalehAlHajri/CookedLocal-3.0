//
//  CommonService.swift
//  Cooked Local
//

import Foundation

final class CommonService {
    private let network = NetworkManager.shared

    func fetchAbout() async throws -> [APIInfoPage] {
        try await network.request(path: "common/about", requiresAuth: false)
    }

    func fetchTerms() async throws -> [APIInfoPage] {
        try await network.request(path: "common/terms", requiresAuth: false)
    }

    func fetchPrivacyPolicy() async throws -> [APIInfoPage] {
        try await network.request(path: "common/privacy-policy", requiresAuth: false)
    }

    func getLaunchScreenConfig() async throws -> LaunchScreenConfig {
        try await network.request(path: "common/launch-screen", requiresAuth: false)
    }
}
