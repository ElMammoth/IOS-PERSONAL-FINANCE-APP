import SwiftUI
import CoreData

/// Lists the planned budget per category, split by Expense / Income.
/// Categories created here are what `AddTransactionView` offers to pick from.
struct BudgetPlanningView: View {
    // MARK: - Environment
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var currencyManager: CurrencyManager

    // MARK: - FetchRequest
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Budget.type, ascending: true),
            NSSortDescriptor(keyPath: \Budget.category, ascending: true)
        ],
        animation: .default
    )
    private var budgets: FetchedResults<Budget>

    // MARK: - State
    @State private var selectedType: String = "Expense"
    private let budgetTypes = ["Expense", "Income"]

    var body: some View {
        VStack(alignment: .leading) {
            // Segmented Picker
            HStack {
                Text("Budget Type")
                    .font(.subheadline)
                    .padding(.leading)
                Spacer()
            }
            Picker("", selection: $selectedType) {
                ForEach(budgetTypes, id: \.self) { type in
                    Text(type)
                        .tag(type)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            .padding(.bottom, 8)

            // List of budgets
            List {
                ForEach(filteredBudgets) { budget in
                    NavigationLink(destination: EditBudgetView(budget: budget)) {
                        HStack {
                            Text(budget.category ?? "Unknown")
                            Spacer()
                            Text("\(String(format: "%.2f", budget.amount)) \(currencyManager.selectedSymbol)")
                                .foregroundColor(budget.type == "Expense" ? .red : .green)
                        }
                    }
                }
                .onDelete(perform: deleteBudget)
            }

            Spacer()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                NavigationLink(destination: AddBudgetView()) {
                    Text("+ Add a budget")
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

    // MARK: - Filter
    private var filteredBudgets: [Budget] {
        budgets.filter { $0.type == selectedType }
    }

    // MARK: - Delete
    private func deleteBudget(offsets: IndexSet) {
        let itemsToDelete = offsets.map { filteredBudgets[$0] }
        for item in itemsToDelete {
            viewContext.delete(item)
        }
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

struct BudgetPlanningView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BudgetPlanningView()
                .environmentObject(CurrencyManager())
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
