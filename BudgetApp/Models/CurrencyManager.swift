// CurrencyManager.swift

import SwiftUI
import Combine

/// Holds the currency symbol chosen by the user and persists it across launches.
/// Injected into the environment by `BudgetApp` and read by every view that
/// displays an amount.
class CurrencyManager: ObservableObject {
    private static let storageKey = "SelectedCurrencySymbol"

    /// Selected symbol, e.g. "$", "€", "CHF", "C$".
    @Published var selectedSymbol: String = "$" {
        didSet {
            UserDefaults.standard.set(selectedSymbol, forKey: Self.storageKey)
        }
    }

    init() {
        if let savedSymbol = UserDefaults.standard.string(forKey: Self.storageKey) {
            selectedSymbol = savedSymbol
        } else {
            selectedSymbol = "$"
        }
    }
}
