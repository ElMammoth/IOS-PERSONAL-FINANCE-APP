// PersistenceController.swift

import CoreData

/// Owns the Core Data stack for the app.
struct PersistenceController {
    static let shared = PersistenceController()

    /// In-memory stack seeded with sample data, used by SwiftUI previews and tests
    /// so they never touch the on-disk store.
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext

        for i in 0..<3 {
            let newTransaction = Transaction(context: viewContext)
            newTransaction.id = UUID()
            newTransaction.category = (i % 2 == 0) ? "Expense" : "Income"
            newTransaction.title = (i % 2 == 0) ? "Sample Expense \(i)" : "Sample Income \(i)"
            newTransaction.amount = Double(i + 1) * 50.0
            newTransaction.date = Date()
        }

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }

        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "BudgetAppModel")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
