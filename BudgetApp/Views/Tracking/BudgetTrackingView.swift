import SwiftUI
import CoreData

/// Lists every transaction, newest first, and shows the running balance.
struct BudgetTrackingView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var currencyManager: CurrencyManager

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)],
        animation: .default)
    private var transactions: FetchedResults<Transaction>

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Balance")
                .font(.subheadline)
                .padding(.horizontal)

            Text("\(String(format: "%.2f", calculateBalance())) \(currencyManager.selectedSymbol)")
                .font(.title3)
                .fontWeight(.bold)
                .padding(.horizontal)

            // Transaction list
            List {
                ForEach(transactions) { transaction in
                    NavigationLink(destination: EditTransactionView(transaction: transaction)) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(transaction.title ?? "Untitled")
                                    .fontWeight(.medium)
                                if let date = transaction.date {
                                    Text(date, style: .date)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            Spacer()
                            let sign = (transaction.type == "Income") ? "+" : "-"
                            Text("\(sign)\(String(format: "%.2f", transaction.amount)) \(currencyManager.selectedSymbol)")
                                .foregroundColor(transaction.type == "Income" ? .green : .red)
                        }
                    }
                }
                .onDelete(perform: deleteTransaction)
            }

            Spacer()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                NavigationLink(destination: AddTransactionView()) {
                    Text("+ Add a transaction")
                        .font(.headline)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: SettingsView()) {
                    Image(systemName: "gearshape")
                }
            }
        }
    }

    private func calculateBalance() -> Double {
        var total = 0.0
        for tx in transactions {
            if tx.type == "Income" {
                total += tx.amount
            } else if tx.type == "Expense" {
                total -= tx.amount
            }
        }
        return total
    }

    private func deleteTransaction(at offsets: IndexSet) {
        offsets.map { transactions[$0] }.forEach(viewContext.delete)
        saveContext()
    }

    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

struct BudgetTrackingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BudgetTrackingView()
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
                .environmentObject(CurrencyManager())
        }
    }
}
