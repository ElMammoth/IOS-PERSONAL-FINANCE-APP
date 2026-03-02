import SwiftUI
import CoreData

struct EditTransactionView: View {
    // The transaction to edit
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

    // FetchRequest for categories
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

    // Initializer to pre-fill states
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
                // Transaction Type (MenuPickerStyle)
                Section(header: Text("Type")) {
                    Picker("Type", selection: $selectedType) {
                        Text("Income").tag("Income")
                        Text("Expense").tag("Expense")
                    }
                    .pickerStyle(MenuPickerStyle())
                    .onChange(of: selectedType) { _ in
                        selectedCategory = ""
                    }
                }

                // Transaction Name
                Section(header: Text("Transaction Name")) {
                    TextField("Ex: Rent, Salary, etc.", text: $transactionName)
                }

                // Category
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

                // Amount (no currency symbol text)
                Section(header: Text("Amount")) {
                    TextField("Enter amount", text: $amountString)
                        .keyboardType(.decimalPad)
                    // Removed the line that displayed currencyManager.selectedSymbol
                }

                // Date
                Section(header: Text("Date")) {
                    DatePicker("Select Date", selection: $transactionDate, displayedComponents: .date)
                }

                // Save button
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
                // Cancel button
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }

    // Save changes to existing transaction
    private func saveChanges() {
        guard let amountValue = Double(amountString), amountValue > 0 else {
            // handle invalid amount
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
