// SettingsView.swift

import SwiftUI

/// Lets the user pick the currency symbol used throughout the app.
struct SettingsView: View {
    @EnvironmentObject var currencyManager: CurrencyManager
    @Environment(\.presentationMode) var presentationMode

    /// Supported currencies. The symbol, not the code, is what gets persisted.
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

                    if currency.symbol == currencyManager.selectedSymbol {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                    }
                }
                .contentShape(Rectangle())  // Make the whole row tappable
                .onTapGesture {
                    currencyManager.selectedSymbol = currency.symbol
                }
            }
        }
        .navigationTitle("Settings")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                // The selection is already saved on tap; this only dismisses the view.
                Button("Save") {
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
                .environmentObject(CurrencyManager())
        }
    }
}
