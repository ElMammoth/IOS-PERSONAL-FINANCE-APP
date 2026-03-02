// EditBudgetView.swift

import SwiftUI
import CoreData

struct EditBudgetView: View {
    // MARK: - Observed Object
    @ObservedObject var budget: Budget

    // MARK: - Environment
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var currencyManager: CurrencyManager  // Accès au symbole monétaire

    // MARK: - State
    @State private var selectedType: String = "Expense"  // Valeur par défaut
    @State private var categoryName: String = ""
    @State private var amountString: String = ""

    // Types possibles pour le Picker
    private let budgetTypes = ["Expense", "Income"]

    // MARK: - Initializer
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
                // Sélecteur de Type (Expense / Income)
                Section(header: Text("Type")) {
                    Picker("Budget Type", selection: $selectedType) {
                        ForEach(budgetTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }

                // Nom de la Catégorie
                Section(header: Text("CATEGORY NAME")) {
                    TextField("Ex: Rent, Salary, etc.", text: $categoryName)
                        .autocapitalization(.words)
                }

                // Montant (avec le symbole monétaire)
                Section(header: Text("AMOUNT")) {
                    HStack {
                        TextField("Enter amount", text: $amountString)
                            .keyboardType(.decimalPad)
                        Text(currencyManager.selectedSymbol)
                            .foregroundColor(.gray)
                    }
                }

                // Bouton Save Changes
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
                // Bouton Cancel en haut à gauche
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }

    // MARK: - Validation
    /// Vérifie si le montant saisi est un nombre valide et positif
    private func isValidAmount() -> Bool {
        if let amount = Double(amountString), amount > 0 {
            return true
        }
        return false
    }

    // MARK: - Save Changes
    /// Sauvegarde les modifications apportées au budget dans Core Data
    private func saveChanges() {
        // Validation du montant
        guard let amountValue = Double(amountString), amountValue > 0 else {
            // Afficher une alerte ou gérer l'erreur selon les besoins
            return
        }

        // Mettre à jour les propriétés du budget
        budget.type = selectedType   // "Expense" ou "Income"
        budget.category = categoryName
        budget.amount = amountValue

        // Sauvegarder le contexte Core Data
        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()  // Fermer la vue
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

// MARK: - Preview
struct EditBudgetView_Previews: PreviewProvider {
    static var previews: some View {
        // Exemple de Budget pour l’aperçu
        let viewContext = PersistenceController.preview.container.viewContext
        let sampleBudget = Budget(context: viewContext)
        sampleBudget.id = UUID()
        sampleBudget.type = "Expense"
        sampleBudget.category = "Loyer"
        sampleBudget.amount = 1000.0

        return NavigationView {
            EditBudgetView(budget: sampleBudget)
                .environmentObject(CurrencyManager()) // Injection du CurrencyManager
                .environment(\.managedObjectContext, viewContext)
        }
    }
}
