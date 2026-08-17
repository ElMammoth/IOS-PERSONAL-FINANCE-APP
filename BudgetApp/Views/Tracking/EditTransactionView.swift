import SwiftUI
import CoreData

/// Form for editing an existing transaction in place.
struct EditTransactionView: View {
    @ObservedObject var transaction: Transaction

    // Environments
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var currencyManager: CurrencyManager

    // States for editing
    @State private var selectedType: String = "Expense"
    @State private var transactionName: String = ""
    @State private var selectedCategory: String = ""
    @State private var amountString: String = ""
    @State private var transactionDate: Date = Date()

    // Selectable categories are the budgets already created for each type.
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Budget.category, ascending: true)],
        predicate: NSPredicate(format: "type == %@", "Expense"),
        animation: .default
    )
    private var expenseBudgets: FetchedResults<Budget>

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Budget.category, ascending: true)],
        predicate: NSPredicate(format: "type == %@", "Income"),
        animation: .default
    )
    private var incomeBudgets: FetchedResults<Budget>

    /// Seeds the editable state from the transaction being edited.
    init(transaction: Transaction) {
        self.transaction = transaction
        _selectedType = State(initialValue: transaction.type ?? "Expense")
        _transactionName = State(initialValue: transaction.title ?? "")
        _selectedCategory = State(initialValue: transaction.category ?? "")
        _amountString = State(initialValue: String(format: "%.2f", transaction.amount))
        _transactionDate = State(initialValue: transaction.date ?? Date())
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Type")) {
                    Picker("Type", selection: $selectedType) {
                        Text("Income").tag("Income")
                        Text("Expense").tag("Expense")
                    }
                    .pickerStyle(MenuPickerStyle())
                    .onChange(of: selectedType) { _ in
                        // The category list depends on the type, so clear a
                        // selection that no longer belongs to it.
                        selectedCategory = ""
                    }
                }

                // Transaction Name
                Section(header: Text("Transaction Name")) {
                    TextField("Ex: Rent, Salary, etc.", text: $transactionName)
                }

                Section(header: Text("Category")) {
                    Picker("Select Category", selection: $selectedCategory) {
                        Text("Select one...").tag("")

                        if selectedType == "Expense" {
                            ForEach(expenseBudgets, id: \.self) { bud in
                                Text(bud.category ?? "Unknown").tag(bud.category ?? "")
                            }
                        } else {
                            ForEach(incomeBudgets, id: \.self) { bud in
                                Text(bud.category ?? "Unknown").tag(bud.category ?? "")
                            }
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }

                Section(header: Text("Amount")) {
                    TextField("Enter amount", text: $amountString)
                        .keyboardType(.decimalPad)
                }

                Section(header: Text("Date")) {
                    DatePicker("Select Date", selection: $transactionDate, displayedComponents: .date)
                }

                Section {
                    Button(action: saveChanges) {
                        Text("Save Changes")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .disabled(transactionName.isEmpty || selectedCategory.isEmpty || amountString.isEmpty)
                }
            }
            .navigationTitle("Edit Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }

    /// Writes the edited values back to the managed object and saves the context.
    private func saveChanges() {
        guard let amountValue = Double(amountString), amountValue > 0 else {
            return
        }

        transaction.type = selectedType
        transaction.title = transactionName
        transaction.category = selectedCategory
        transaction.amount = amountValue
        transaction.date = transactionDate

        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

struct EditTransactionView_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PersistenceController.preview.container.viewContext
        let sampleTx = Transaction(context: viewContext)
        sampleTx.id = UUID()
        sampleTx.type = "Expense"
        sampleTx.title = "Rent"
        sampleTx.category = "Housing"
        sampleTx.amount = 800
        sampleTx.date = Date()

        return NavigationView {
            EditTransactionView(transaction: sampleTx)
                .environment(\.managedObjectContext, viewContext)
                .environmentObject(CurrencyManager())
        }
    }
}
