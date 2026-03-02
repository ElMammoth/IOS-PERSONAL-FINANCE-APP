// SettingsView.swift

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var currencyManager: CurrencyManager
    @Environment(\.presentationMode) var presentationMode
    
    // Structure représentant une devise
    struct Currency: Identifiable {
        let id: String        // Code de la devise (ex. USD, EUR)
        let name: String      // Nom complet de la devise
        let symbol: String    // Symbole monétaire
    }
    
    // Liste des devises autorisées
    let currencies: [Currency] = [
        Currency(id: "USD", name: "US Dollar", symbol: "$"),
        Currency(id: "EUR", name: "Euro", symbol: "€"),
        Currency(id: "CHF", name: "Swiss Franc", symbol: "CHF"),
        Currency(id: "CAD", name: "Canadian Dollar", symbol: "C$")
    ]
    
    var body: some View {
        VStack {
            List(currencies) { currency in
                HStack {
                    Text(currency.name)
                        .foregroundColor(.primary)
                    Spacer()
                    Text(currency.symbol)
                        .foregroundColor(.gray)
                    
                    // Afficher une coche si la devise est sélectionnée
                    if currency.symbol == currencyManager.selectedSymbol {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                    }
                }
                .contentShape(Rectangle())  // Rendre toute la ligne cliquable
                .onTapGesture {
                    currencyManager.selectedSymbol = currency.symbol
                }
            }
        }
        .navigationTitle("Settings")
        .toolbar {
            // Bouton Save en haut à droite
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    // Fermer la vue
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView()
                .environmentObject(CurrencyManager()) // Injection pour l'aperçu
        }
    }
}
