import Testing
@testable import BudgetApp

/// Unit test target scaffolding. The app's calculations currently live in
/// private methods on the SwiftUI views, so there is no unit-testable surface
/// yet — see the Limitations section of the README.
struct BudgetAppTests {

    @Test func appModuleLoads() async throws {
        #expect(CurrencyManager().selectedSymbol.isEmpty == false)
    }

}
