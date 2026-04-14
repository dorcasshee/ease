//
//  EaseApp.swift
//  Ease
//
//  Created by Dorcas Shee on 1/11/25.
//

import SwiftUI
import SwiftData

@main
struct EaseApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Transaction.self, Payee.self, ParentCategory.self], onSetup: { result in
            switch result {
                case .success(let container):
                    Task {
                        let seeder = DataSeeder(modelContainer: container)
                        
                        do {
                            try await seeder.seedDefaultCategories()
                        } catch {
                            print("Seeding failed: \(error.localizedDescription)")
                        }
                    }
                case .failure(let error):
                    print("Error creating container: \(error.localizedDescription)")
            }
        })
    }
}

extension ModelContainer {
    static var preview: ModelContainer {
        let schema = Schema([Transaction.self, ParentCategory.self, Payee.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: config)
        
        // Seed preview data
        let context = container.mainContext
        
        // load categories from JSON
        if let url = Bundle.main.url(forResource: "DefaultCategories", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let dataObjects = try? JSONDecoder().decode([ParentCategoryDTO].self, from: data) {
            for dataObject in dataObjects {
                let parent = ParentCategory(name: dataObject.name,
                                            iconName: dataObject.iconName,
                                            isSystemIcon: dataObject.isSystemIcon,
                                            colorName: dataObject.colorName,
                                            transactionType: dataObject.transactionType)
                context.insert(parent)
                
                for subDataObject in dataObject.subCategories {
                    let sub = SubCategory(name: subDataObject.name,
                                          iconName: subDataObject.iconName,
                                          isSystemIcon: subDataObject.isSystemIcon,
                                          isDefault: subDataObject.isDefault,
                                          colorName: dataObject.colorName,
                                          parent: parent)
                    context.insert(sub)
                }
            }
        }

        // Create sample payees
        let starbucks = Payee(name: "Starbucks")
        context.insert(starbucks)

        let uber = Payee(name: "Uber")
        context.insert(uber)

        let fairprice = Payee(name: "FairPrice")
        context.insert(fairprice)

        // Create sample transactions
        let calendar = Calendar.current
        
        let salary = try? context.fetch(
            FetchDescriptor<SubCategory>(
                predicate: #Predicate { $0.name == "Salary" }
            )
        ).first

        // Transaction 1: Monthly salary (income)
        if let salary {
            let salaryTransaction = Transaction(
                amount: 5000.00,
                category: salary,
                desc: "January salary",
                payee: nil,
                date: calendar.date(from: DateComponents(year: 2026, month: 1, day: 1)) ?? Date()
            )
            context.insert(salaryTransaction)
        }

        // Transaction 2: Groceries
        let groceries = try? context.fetch(
            FetchDescriptor<SubCategory>(
                predicate: #Predicate { $0.name == "Groceries" }
            )
        ).first
        
        if let groceries {
            let groceriesTransaction = Transaction(
                amount: 87.50,
                category: groceries,
                desc: "Weekly groceries",
                payee: fairprice,
                date: calendar.date(from: DateComponents(year: 2026, month: 1, day: 15)) ?? Date()
            )
            context.insert(groceriesTransaction)
        }

        // Transaction 3: Coffee
        let drinks = try? context.fetch(
            FetchDescriptor<SubCategory>(
                predicate: #Predicate { $0.name == "Drinks" }
            )
        ).first
        
        if let drinks {
            let coffeeTransaction = Transaction(
                amount: 12.80,
                category: drinks,
                desc: "Morning coffee",
                payee: starbucks,
                date: calendar.date(from: DateComponents(year: 2026, month: 1, day: 20)) ?? Date()
            )
            context.insert(coffeeTransaction)
        }

        // Transaction 5: Gaming purchase
        let gaming = try? context.fetch(
            FetchDescriptor<SubCategory>(
                predicate: #Predicate { $0.name == "Gaming" }
            )
        ).first
        
        if let gaming {
            let gamingTransaction = Transaction(
                amount: 69.90,
                category: gaming,
                desc: "New game on Steam",
                payee: nil,
                date: calendar.date(from: DateComponents(year: 2026, month: 1, day: 10)) ?? Date()
            )
            context.insert(gamingTransaction)
        }

        // Transaction 6: Haircut (same date as groceries to test section grouping)
        let toiletries = try? context.fetch(
            FetchDescriptor<SubCategory>(
                predicate: #Predicate { $0.name == "Toiletries" }
            )
        ).first
        
        if let toiletries {
            let haircutTransaction = Transaction(
                amount: 35.00,
                category: toiletries,
                desc: "Monthly haircut",
                payee: nil,
                date: calendar.date(from: DateComponents(year: 2026, month: 1, day: 15, hour: 17, minute: 30)) ?? Date()
            )
            context.insert(haircutTransaction)
        }

        return container
    }
}
