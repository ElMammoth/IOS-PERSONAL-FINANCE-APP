import SwiftUI

/// Root view: the three top-level tabs of the app.
struct ContentView: View {
    var body: some View {
        TabView {
            NavigationView {
                DashboardView()
            }
            .tabItem {
                Label("Dashboard", systemImage: "house")
            }

            NavigationView {
                BudgetTrackingView()
            }
            .tabItem {
                Label("Tracking", systemImage: "chart.bar")
            }

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
