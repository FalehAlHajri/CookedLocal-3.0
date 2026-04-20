//
//  CategoryService.swift
//  Cooked Local
//

import Foundation

final class CategoryService {
    private let network = NetworkManager.shared

    func fetchCategories() async throws -> [APICategory] {
        try await network.requestPaginated(
            path: "common/category",
            requiresAuth: false
        )
    }
}
