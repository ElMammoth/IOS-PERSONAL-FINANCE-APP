// Currency.swift

import Foundation

/// Structure représentant une devise.
struct Currency: Identifiable {
    let id: String        // Code de la devise (ex. USD, EUR)
    let name: String      // Nom complet de la devise
    let symbol: String    // Symbole monétaire
}
