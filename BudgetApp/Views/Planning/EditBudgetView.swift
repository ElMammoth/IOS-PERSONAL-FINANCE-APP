// EditBudgetView.swift

import SwiftUI
import CoreData

/// Form for editing an existing budget category in place.
struct EditBudgetView: View {
    // MARK: - Observed Object
    @ObservedObject var budget: Budget

    // MARK: - Environment
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var currencyManager: CurrencyManager

    // MARK: - State
    @State private var selectedType: String = "Expense"
    @State private var categoryName: String = ""
    @State private var amountString: String = ""

    private let budgetTypes = ["Expense", "Income"]

    // MARK: - Initializer
    /// Seeds the editable state from the budget being edited.
    init(budget: Budget) {
        self.budget = budget
        _selectedType = State(initialValue: budget.type ?? "Expense")
        _categoryName = State(initialValue: budget.category ?? "")
        _amountString = State(initialValue: String(format: "%.2f", budget.amount))
    }

    // MARK: - Body
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Type")) {
                    Picker("Budget Type", selection: $selectedType) {
                        ForEach(budgetTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }

                Section(header: Text("CATEGORY NAME")) {
                    TextField("Ex: Rent, Salary, etc.", text: $categoryName)
                        .autocapitalization(.words)
                }

                Section(header: Text("AMOUNT")) {
                    HStack {
                        TextField("Enter amount", text: $amountString)
                            .keyboardType(.decimalPad)
                        Text(currencyManager.selectedSymbol)
                            .foregroundColor(.gray)
                    }
                }

                Section {
                    Button(action: saveChanges) {
                        Text("Save Changes")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .disabled(categoryName.isEmpty || amountString.isEmpty || !isValidAmount())
                }
            }
            .navigationTitle("Edit Budget")
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

    // MARK: - Validation
    /// True when the entered text parses as a positive number.
    private func isValidAmount() -> Bool {
        if let amount = Double(amountString), amount > 0 {
            return true
        }
        return false
    }

    // MARK: - Save Changes
    /// Writes the edited values back to the managed object and saves the context.
    private func saveChanges() {
        guard let amountValue = Double(amountString), amountValue > 0 else {
            return
        }

        budget.type = selectedType   // "Expense" or "Income"
        budget.category = categoryName
        budget.amount = amountValue

        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

// MARK: - Preview
struct EditBudgetView_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PersistenceController.preview.container.viewContext
        let sampleBudget = Budget(context: viewContext)
        sampleBudget.id = UUID()
        sampleBudget.type = "Expense"
        sampleBudget.category = "Rent"
        sampleBudget.amount = 1000.0

        return NavigationView {
            EditBudgetView(budget: sampleBudget)
                .environmentObject(CurrencyManager())
                .environment(\.managedObjectContext, viewContext)
        }
    }
}
