//
//  UserRole.swift
//  Cooked Local
//

import Foundation

enum UserRole: String, Codable, CaseIterable {
    case chef
    case customer

    var displayName: String {
        switch self {
        case .chef:
            return "Chef"
        case .customer:
            return "Customer"
        }
    }
}
