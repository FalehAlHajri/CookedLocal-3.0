//
//  SearchSuggestion.swift
//  Cooked Local
//

import Foundation

struct SearchSuggestion: Identifiable, Hashable {
    let id: String
    let text: String
    let shopName: String?

    init(id: String = UUID().uuidString, text: String, shopName: String? = nil) {
        self.id = id
        self.text = text
        self.shopName = shopName
    }

    var fullText: String {
        if let shopName = shopName {
            return "\(text) \(shopName)"
        }
        return text
    }
}

//extension SearchSuggestion {
//    static let samples: [SearchSuggestion] = [
//        SearchSuggestion(text: "Pasta"),
//        SearchSuggestion(text: "children Pasta"),
//        SearchSuggestion(text: "children Pasta", shopName: "Hex Shop"),
//        SearchSuggestion(text: "Birthday Cake"),
//        SearchSuggestion(text: "Pizza Margherita"),
//        SearchSuggestion(text: "Burger Classic", shopName: "Burger Hub")
//    ]
//}
