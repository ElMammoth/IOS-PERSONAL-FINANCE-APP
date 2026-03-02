// BudgetApp.swift

import SwiftUI

@main
struct BudgetApp: App {
    let persistenceController = PersistenceController.shared
    
    // Instancier un CurrencyManager comme source de vérité pour le symbole monétaire
    @StateObject var currencyManager = CurrencyManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                // Injecter CurrencyManager dans l'environnement pour les vues enfants
                .environmentObject(currencyManager)
        }
    }
}
