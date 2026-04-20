//
//  Cooked_LocalApp.swift
//  Cooked Local
//

import SwiftUI

@main
struct Cooked_LocalApp: App {
    @StateObject private var container = DependencyContainer()

    var body: some Scene {
        WindowGroup {
            NavigationCoordinator()
                .environmentObject(container)
                .environmentObject(container.router)
        }
    }
}
