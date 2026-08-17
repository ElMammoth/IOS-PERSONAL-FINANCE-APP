import SwiftUI
import CoreData

/// Monthly overview: income and expense totals for the selected month, plus a
/// progress bar per budget category showing tracked spend against the plan.
struct DashboardView: View {
    // MARK: - Environment
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var currencyManager: CurrencyManager

    // MARK: - State
    @State private var selectedMonth: Int = Calendar.current.component(.month, from: Date())
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
    @State private var selectedCategory: TransactionCategory = .expense

    /// Raw values must match the `type` strings written to Core Data.
    enum TransactionCategory: String, CaseIterable {
        case expense = "Expense"
        case income  = "Income"
    }

    private let months = Array(1...12)

    /// Selectable years, centred on the current one so the picker never goes stale.
    private let years: [Int] = {
        let currentYear = Calendar.current.component(.year, from: Date())
        return Array((currentYear - 3)...(currentYear + 1))
    }()

    // MARK: - FetchRequest for Transactions
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)],
        animation: .default
    )
    private var transactions: FetchedResults<Transaction>

    // MARK: - FetchRequest for Budgets
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Budget.type, ascending: true),
            NSSortDescriptor(keyPath: \Budget.category, ascending: true)
        ],
        animation: .default
    )
    private var budgets: FetchedResults<Budget>

    // MARK: - Body
    var body: some View {
        VStack {
            // Section Totals: Income and Expense
            HStack {
                // Total Income
                VStack(alignment: .leading) {
                    Text("Total Income")
                        .font(.subheadline)
                    Text("\(String(format: "%.2f", totalIncomeForSelectedMonthYear())) \(currencyManager.selectedSymbol)")
                        .font(.title3)
                        .fontWeight(.bold)
                }
                Spacer()
                // Total Expense
                VStack(alignment: .trailing) {
                    Text("Total Expense")
                        .font(.subheadline)
                    Text("\(String(format: "%.2f", totalExpenseForSelectedMonthYear())) \(currencyManager.selectedSymbol)")
                        .font(.title3)
                        .fontWeight(.bold)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            // Toggle Bar: "Expense" / "Income"
            Picker("", selection: $selectedCategory) {
                ForEach(TransactionCategory.allCases, id: \.self) { cat in
                    Text(cat.rawValue).tag(cat)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            .padding(.top, 8)
            
            // Budget Categories List
            List {
                ForEach(filteredBudgets) { bud in
                    // Calculate tracked amount for this budget
                    let trackedAmount = amountTracked(for: bud)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        // Category Name and Tracked/Planned Amount
                        HStack {
                            Text(bud.category ?? "Unknown")
                                .fontWeight(.medium)
                            Spacer()
                            Text("\(String(format: "%.2f", trackedAmount)) / \(String(format: "%.2f", bud.amount))")
                                .fontWeight(.semibold)
                        }
                        
                        // Progress Bar with Dynamic Colors
                        ProgressView(value: trackedAmount, total: bud.amount)
                            .accentColor(progressBarColor(tracked: trackedAmount, planned: bud.amount))
                    }
                    .padding(.vertical, 4)
                }
            }
            .listStyle(PlainListStyle())
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // MARK: - Left side: Month/Year pickers side by side
            ToolbarItem(placement: .navigationBarLeading) {
                // Fixed widths and tight spacing keep both pickers on one line.
                HStack(spacing: 8) {
                    Picker("Month", selection: $selectedMonth) {
                        ForEach(months, id: \.self) { month in
                            Text(monthName(from: month)).tag(month)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(width: 80)

                    Picker("Year", selection: $selectedYear) {
                        ForEach(years, id: \.self) { year in
                            Text("\(year)").tag(year)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(width: 80)
                }
            }

            // MARK: - Right side: Settings gear icon
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: SettingsView()) {
                    Image(systemName: "gearshape")
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    
    /// Returns the abbreviated name of the month for a given month number.
    private func monthName(from number: Int) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        return formatter.shortMonthSymbols[number - 1] // Use abbreviated month names
    }
    
    /// Filters budgets based on the selected category (Expense/Income).
    private var filteredBudgets: [Budget] {
        budgets.filter { $0.type == selectedCategory.rawValue }
    }
    
    /// Calculates the total income for the selected month and year.
    private func totalIncomeForSelectedMonthYear() -> Double {
        transactions.filter { tx in
            guard let date = tx.date else { return false }
            let components = Calendar.current.dateComponents([.year, .month], from: date)
            let isSelectedDate = (components.year == selectedYear && components.month == selectedMonth)
            let isIncome       = (tx.type == "Income")
            return isSelectedDate && isIncome
        }.reduce(0) { $0 + $1.amount }
    }
    
    /// Calculates the total expense for the selected month and year.
    private func totalExpenseForSelectedMonthYear() -> Double {
        transactions.filter { tx in
            guard let date = tx.date else { return false }
            let components = Calendar.current.dateComponents([.year, .month], from: date)
            let isSelectedDate = (components.year == selectedYear && components.month == selectedMonth)
            let isExpense      = (tx.type == "Expense")
            return isSelectedDate && isExpense
        }.reduce(0) { $0 + $1.amount }
    }

    /// Calculates the amount tracked for a given budget in the selected month and year.
    private func amountTracked(for budget: Budget) -> Double {
        transactions.filter { tx in
            guard let date = tx.date else { return false }
            let components = Calendar.current.dateComponents([.year, .month], from: date)
            let matchesDate = (components.year == selectedYear && components.month == selectedMonth)
            let matchesType = (tx.type == budget.type)
            let matchesCategory = (tx.category == budget.category)
            return matchesDate && matchesType && matchesCategory
        }.reduce(0) { $0 + $1.amount }
    }
    
    /// Determines the color of the progress bar based on tracking status.
    private func progressBarColor(tracked: Double, planned: Double) -> Color {
        if tracked > planned {
            return .red // Exceeded
        } else if tracked == planned {
            return .green // Completed
        } else if tracked > 0 {
            return .blue // Started but not completed
        } else {
            return .gray // Not started
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DashboardView()
                .environmentObject(CurrencyManager())
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
