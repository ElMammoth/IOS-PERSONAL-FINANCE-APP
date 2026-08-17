// Currency.swift

import Foundation

/// A currency the user can pick in Settings.
struct Currency: Identifiable {
    let id: String        // ISO code, e.g. "USD", "EUR"
    let name: String      // Full display name
    let symbol: String    // Symbol persisted by CurrencyManager
}
