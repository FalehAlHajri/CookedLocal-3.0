//
//  Router.swift
//  Cooked Local
//

import SwiftUI
import Combine

final class Router: ObservableObject {
    @Published var path = NavigationPath()

    @MainActor
    func navigate(to route: AppRoute) {
        path.append(route)
    }

    @MainActor
    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    @MainActor
    func popToRoot() {
        path.removeLast(path.count)
    }

    @MainActor
    func replace(with route: AppRoute) {
        popToRoot()
        navigate(to: route)
    }
}
