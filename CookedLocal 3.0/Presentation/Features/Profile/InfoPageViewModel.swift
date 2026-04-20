//
//  InfoPageViewModel.swift
//  Cooked Local
//

import SwiftUI
import Combine

enum InfoPageType {
    case about
    case terms
    case privacy
}

final class InfoPageViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var isLoading: Bool = false

    // MARK: - Properties
    let title: String
    let pageType: InfoPageType

    // MARK: - Dependencies
    private let router: Router
    private let commonService: CommonService

    // MARK: - Initialization
    init(title: String, pageType: InfoPageType, router: Router, commonService: CommonService) {
        self.title = title
        self.pageType = pageType
        self.router = router
        self.commonService = commonService
    }

    // MARK: - Methods

    func goBack() {
        router.pop()
    }

    // MARK: - Private

    // Content is now hardcoded in the view for reliability
}
