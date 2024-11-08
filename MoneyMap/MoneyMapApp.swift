//
//  MoneyMapApp.swift
//  MoneyMap
//
//  Created by Roman Khancha on 05.11.2024.
//

import SwiftUI
import SwiftData

@main
struct MoneyMapApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .modelContainer(for: [Transaction.self, Category.self])
        }
    }
}

class AppState: ObservableObject {
    @Published var selectedTab: Int = 0
}
