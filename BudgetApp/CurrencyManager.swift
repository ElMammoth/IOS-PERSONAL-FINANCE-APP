// CurrencyManager.swift

import SwiftUI
import Combine

/// `CurrencyManager` gère le symbole monétaire choisi par l'utilisateur.
class CurrencyManager: ObservableObject {
    // Symbole sélectionné, e.g. "$", "€", "CHF", "C$"
    @Published var selectedSymbol: String = "$" {
        didSet {
            // Sauvegarder dans UserDefaults dès qu'il est mis à jour
            UserDefaults.standard.set(selectedSymbol, forKey: "SelectedCurrencySymbol")
        }
    }

    init() {
        // Charger la valeur sauvegardée si elle existe
        if let savedSymbol = UserDefaults.standard.string(forKey: "SelectedCurrencySymbol") {
            selectedSymbol = savedSymbol
        } else {
            selectedSymbol = "$" // Valeur par défaut
        }
    }
}
