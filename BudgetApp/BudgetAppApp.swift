// BudgetAppApp.swift

import SwiftUI

@main
struct BudgetApp: App {
    let persistenceController = PersistenceController.shared

    /// Single source of truth for the currency symbol, shared by every view.
    @StateObject var currencyManager = CurrencyManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(currencyManager)
        }
    }
}
