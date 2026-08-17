# BudgetApp

An iOS personal finance app built with SwiftUI and Core Data. You define a monthly
budget per category, log income and expenses against those categories, and the
dashboard shows how much of each budget you have actually used.

The project is a self-contained learning exercise in native iOS development: no
third-party dependencies, no package manager, no backend. All data stays on the
device.

## Why it exists

Most budgeting apps either require an account or bury the one number that matters
— how much of this category's budget is left — under layers of navigation.
BudgetApp reduces the idea to its core loop:

1. **Plan** — create a category ("Rent", "Groceries", "Salary") and the amount you
   expect for it each month.
2. **Track** — log transactions and assign each one to a category.
3. **Review** — the dashboard totals income and expenses for a chosen month and
   draws a progress bar per category, coloured by how far through the budget you
   are.

Categories are not a separate entity. The list of categories you can assign a
transaction to *is* the set of budgets you have created, which keeps planning and
tracking from drifting apart.

## Requirements

- macOS with **Xcode 16.2** or later (the project uses Xcode 16 file-system
  synchronized groups, `objectVersion = 77`, which earlier Xcode versions cannot
  open)
- **iOS 15.6+** to run the app; the test targets are set to iOS 18.2
- An Apple ID for code signing if you want to run on a physical device

## Running it

```bash
git clone https://github.com/ElMammoth/IOS-PERSONAL-FINANCE-APP.git
cd IOS-PERSONAL-FINANCE-APP
open BudgetApp.xcodeproj
```

Then select the `BudgetApp` scheme and an iOS simulator, and press **⌘R**.

There is nothing to install — no CocoaPods, no Swift Package Manager
dependencies, no configuration files or API keys.

To run on a physical device, change the signing team in **BudgetApp → Signing &
Capabilities** to your own; the committed `DEVELOPMENT_TEAM` and the
`ElPatr0n.BudgetApp` bundle identifier will not sign under a different Apple ID.

To run the tests: **⌘U** (or **Product → Test**).

## Repository structure

```
BudgetApp.xcodeproj/        Xcode project
BudgetApp/
  BudgetAppApp.swift        @main entry point; builds the Core Data stack and
                            injects CurrencyManager into the environment
  ContentView.swift         Root TabView: Dashboard / Tracking / Planning
  Models/
    Currency.swift          A selectable currency (code, name, symbol)
    CurrencyManager.swift   Observable holder for the chosen currency symbol,
                            persisted in UserDefaults
  Persistence/
    PersistenceController.swift   NSPersistentContainer wrapper, plus an
                                  in-memory stack seeded for previews
    BudgetAppModel.xcdatamodeld   Core Data model: Budget and Transaction
  Views/
    Dashboard/              Monthly totals and per-category progress bars
    Planning/               Budget list, create and edit forms
    Tracking/               Transaction list, create and edit forms
    Settings/               Currency picker
  Assets.xcassets/          App icon and accent colour
  Preview Content/          Assets used only by SwiftUI previews
BudgetAppTests/             Unit test target
BudgetAppUITests/           UI test target
```

### Data model

Two Core Data entities, both with Xcode-generated classes (so there are no
model source files to read):

| Entity        | Attributes                                        |
| ------------- | ------------------------------------------------- |
| `Budget`      | `id`, `type`, `category`, `amount`                |
| `Transaction` | `id`, `type`, `category`, `title`, `amount`, `date` |

`type` is the string `"Expense"` or `"Income"` on both entities. A transaction is
matched to a budget by comparing `type` **and** `category`; there is no Core Data
relationship between them.

## Limitations

Worth knowing before reading the code:

- **Categories are matched by string.** Renaming a budget category does not
  update the transactions already assigned to it, so those transactions stop
  counting toward that budget. A Core Data relationship between `Budget` and
  `Transaction` would be the correct fix.
- **Nested navigation stacks.** The four Add/Edit screens each wrap their body in
  a `NavigationView` while being pushed from a `NavigationLink` inside another
  one. This produces a doubled navigation bar on those screens. Left as-is
  deliberately, since fixing it changes the UI.
- **No budget periods.** A `Budget` has no month or year, so the same planned
  amount is compared against every month's transactions. Budgets cannot vary
  month to month.
- **Amounts are formatted manually** with `String(format: "%.2f")` and a
  symbol appended, rather than through `NumberFormatter`. Grouping separators and
  symbol placement therefore do not follow the device locale.
- **Save failures call `fatalError`.** Core Data write errors crash the app
  instead of surfacing a message to the user.
- **Tests are scaffolding.** The unit and UI test targets exist and pass, but
  cover almost nothing: the balance and budget-tracking calculations are private
  methods on the SwiftUI views, which makes them unreachable from a unit test
  without extracting them into a separate type.
