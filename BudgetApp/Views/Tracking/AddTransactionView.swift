import SwiftUI
import CoreData

/// Form for recording a new transaction against an existing budget category.
struct AddTransactionView: View {
    // MARK: - Environment
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var currencyManager: CurrencyManager

    // MARK: - State
    @State private var selectedType: String = "Expense"
    @State private var transactionName: String = ""
    @State private var selectedCategory: String = ""
    @State private var amountString: String = ""
    @State private var transactionDate: Date = Date()

    // MARK: - FetchRequests for Categories
    // Categories are not a separate entity: the available categories are simply
    // the budgets the user has already created, split by type.
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Budget.category, ascending: true)
        ],
        predicate: NSPredicate(format: "type == %@", "Expense"),
        animation: .default
    )
    private var expenseBudgets: FetchedResults<Budget>

    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Budget.category, ascending: true)
        ],
        predicate: NSPredicate(format: "type == %@", "Income"),
        animation: .default
    )
    private var incomeBudgets: FetchedResults<Budget>

    // MARK: - Body
    var body: some View {
        NavigationView {
            Form {
                // Section for transaction type
                Section(header: Text("Type")) {
                    Picker("Transaction Type", selection: $selectedType) {
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

                // Category Picker
                Section(header: Text("Category")) {
                    Picker("Select Category", selection: $selectedCategory) {
                        Text("Select one...").tag("")
                        if selectedType == "Expense" {
                            ForEach(expenseBudgets, id: \.self) { bud in
                                Text(bud.category ?? "Unknown")
                                    .tag(bud.category ?? "")
                            }
                        } else {
                            ForEach(incomeBudgets, id: \.self) { bud in
                                Text(bud.category ?? "Unknown")
                                    .tag(bud.category ?? "")
                            }
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }

                // Amount
                Section(header: Text("Amount")) {
                    TextField("Enter amount", text: $amountString)
                        .keyboardType(.decimalPad)
                }

                // Transaction Date
                Section(header: Text("Date")) {
                    DatePicker("Select Date", selection: $transactionDate, displayedComponents: .date)
                }

                // Save Button
                Section {
                    Button(action: saveTransaction) {
                        Text("Save")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .disabled(transactionName.isEmpty || selectedCategory.isEmpty || amountString.isEmpty)
                }
            }
            .navigationTitle("Add Transaction")
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

    // MARK: - Save
    private func saveTransaction() {
        // The Save button is disabled on empty fields, so this guard only rejects
        // text that is not a positive number.
        guard let amountValue = Double(amountString), amountValue > 0 else {
            return
        }

        let newTx = Transaction(context: viewContext)
        newTx.id = UUID()
        newTx.type = selectedType
        newTx.title = transactionName
        newTx.category = selectedCategory
        newTx.amount = amountValue
        newTx.date = transactionDate

        // Persist
        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

struct AddTransactionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AddTransactionView()
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
                .environmentObject(CurrencyManager())
        }
    }
}
