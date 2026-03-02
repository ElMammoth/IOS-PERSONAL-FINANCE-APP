// BudgetCategory.swift

import Foundation

/// Catégorie possible pour le budget : Dépense (Expense) ou Revenu (Income)
enum BudgetCategory: String, CaseIterable, Identifiable {
    case expense = "Expense"
    case income  = "Income"

    var id: String { self.rawValue }
}
