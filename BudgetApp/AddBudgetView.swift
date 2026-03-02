import SwiftUI
import CoreData

struct AddBudgetView: View {
    // MARK: - Environment
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var currencyManager: CurrencyManager

    // MARK: - State
    @State private var selectedType: String = "Expense"
    @State private var categoryName: String = ""
    @State private var amountString: String = ""

    // Types for the Picker
    private let budgetTypes = ["Expense", "Income"]

    var body: some View {
        NavigationView {
            Form {
                // Section for type (Expense/Income)
                Section(header: Text("Type")) {
                    Picker("Budget Type", selection: $selectedType) {
                        ForEach(budgetTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }

                // Category Name
                Section(header: Text("CATEGORY NAME")) {
                    TextField("Ex: Rent, Salary, etc.", text: $categoryName)
                }

                // Amount
                Section(header: Text("AMOUNT")) {
                    TextField("Enter amount", text: $amountString)
                        .keyboardType(.decimalPad)
                    // Removed the line showing the current currency symbol
                }

                // Save Button
                Section {
                    Button(action: saveBudget) {
                        Text("Save")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .disabled(categoryName.isEmpty || amountString.isEmpty)
                }
            }
            .navigationTitle("Add Budget")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Méthodes
    private func saveBudget() {
        guard let amountValue = Double(amountString), amountValue > 0 else {
            // Handle invalid amount
            return
        }

        // Create a new Budget object
        let newBudget = Budget(context: viewContext)
        newBudget.id = UUID()
        newBudget.type = selectedType
        newBudget.category = categoryName
        newBudget.amount = amountValue

        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

struct AddBudgetView_Previews: PreviewProvider {
    static var previews: some View {
        AddBudgetView()
            .environmentObject(CurrencyManager())
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
