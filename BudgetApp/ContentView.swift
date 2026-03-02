import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            // Onglet 1 : Dashboard
            NavigationView {
                DashboardView()
            }
            .tabItem {
                Label("Dashboard", systemImage: "house")
            }

            // Onglet 2 : Budget Tracking
            NavigationView {
                BudgetTrackingView()
            }
            .tabItem {
                Label("Tracking", systemImage: "chart.bar")
            }

            // Onglet 3 : Budget Planning
            NavigationView {
                BudgetPlanningView()
            }
            .tabItem {
                Label("Planning", systemImage: "calendar")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(CurrencyManager())
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
