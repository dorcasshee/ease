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
        .modelContainer(for: [Transaction.self, Payee.self, TransactionCategory.self], onSetup: { result in
            switch result {
                case .success(let container):
                    do {
                        try TransactionCategory.seedDefaultCategories(in: container.mainContext)
                    } catch {
                        print("Error occurred while seeding data: \(error.localizedDescription)")
                    }
                case .failure(let error):
                    print("Error creating container: \(error.localizedDescription)")
            }
        })
    }
}

extension ModelContainer {
    static var preview: ModelContainer {
        let schema = Schema([Transaction.self, TransactionCategory.self, Payee.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: config)
        
        // Seed preview data
        let context = container.mainContext
        
        // entertainment
        let entertainment = TransactionCategory(name: "Entertainment", iconName: "tv", transactionType: .expense)
        context.insert(entertainment)
        context.insert(TransactionCategory(name: "Crafts", iconName: "pencil.and.outline", transactionType: .expense, parentCategory: entertainment))
        let gaming = TransactionCategory(name: "Gaming", iconName: "gamecontroller.circle", transactionType: .expense, parentCategory: entertainment)
        context.insert(gaming)
        
        // food
        let food = TransactionCategory(name: "Food", iconName: "fork.knife", transactionType: .expense)
        context.insert(food)
        let groceries = TransactionCategory(name: "Groceries", iconName: "carrot", transactionType: .expense, parentCategory: food)
        context.insert(groceries)
        context.insert(TransactionCategory(name: "Drinks", iconName: "cup.and.saucer", transactionType: .expense, parentCategory: food))
        context.insert(TransactionCategory(name: "Food", iconName: "fork.knife", isDefault: true, transactionType: .expense, parentCategory: food))
        let takeout = TransactionCategory(name: "Takeout", iconName: "takeoutbag.and.cup.and.straw", transactionType: .expense, parentCategory: food)
        context.insert(takeout)
        context.insert(TransactionCategory(name: "Snacks", iconName: "spoon.serving", transactionType: .expense, parentCategory: food))
        context.insert(TransactionCategory(name: "Food Delivery", iconName: "motorcycle", transactionType: .expense, parentCategory: food))
        
        // health and fitness
        let healthAndFitness = TransactionCategory(name: "Health and Fitness", iconName: "heart", transactionType: .expense)
        context.insert(healthAndFitness)
        context.insert(TransactionCategory(name: "Insurance", iconName: "dollarsign.circle", transactionType: .expense, parentCategory: healthAndFitness))
        context.insert(TransactionCategory(name: "Medical Bills", iconName: "stethoscope.circle", transactionType: .expense, parentCategory: healthAndFitness))
        context.insert(TransactionCategory(name: "Medication", iconName: "pill.circle", transactionType: .expense, parentCategory: healthAndFitness))
        context.insert(TransactionCategory(name: "Wellness", iconName: "figure.run.circle", transactionType: .expense, parentCategory: healthAndFitness))
        
        // housing
        let housing = TransactionCategory(name: "Housing", iconName: "house", transactionType: .expense)
        context.insert(housing)
        context.insert(TransactionCategory(name: "Rent", iconName: "dollarsign.circle", transactionType: .expense, parentCategory: housing))
        context.insert(TransactionCategory(name: "Mortgage", iconName: "dollarsign.bank.building", transactionType: .expense, parentCategory: housing))
        context.insert(TransactionCategory(name: "Utilities", iconName: "bolt.circle", transactionType: .expense, parentCategory: housing))
        
        // income
        let income = TransactionCategory(name: "Income", iconName: "dollarsign", transactionType: .income)
        context.insert(income)
        let salary = TransactionCategory(name: "Salary", iconName: "dollarsign.circle", isDefault: true, transactionType: .income, parentCategory: income)
        context.insert(salary)
        context.insert(TransactionCategory(name: "Freelance", iconName: "dollarsign.circle", transactionType: .income, parentCategory: income))
        context.insert(TransactionCategory(name: "Dividends", iconName: "dollarsign.circle", transactionType: .income, parentCategory: income))
        
        // personal care
        let personal = TransactionCategory(name: "Personal Care", iconName: "person", transactionType: .expense)
        context.insert(personal)
        let hairCare = TransactionCategory(name: "Hair Care", iconName: "bubbles.and.sparkles", transactionType: .expense, parentCategory: personal)
        context.insert(hairCare)
        context.insert(TransactionCategory(name: "Body Care", iconName: "bubbles.and.sparkles", transactionType: .expense, parentCategory: personal))
        context.insert(TransactionCategory(name: "Skin Care", iconName: "bubbles.and.sparkles", transactionType: .expense, parentCategory: personal))
        context.insert(TransactionCategory(name: "Cosmetics", iconName: "paintbrush.pointed", transactionType: .expense, parentCategory: personal))
        
        // transport
        let transport = TransactionCategory(name: "Transport", iconName: "car", transactionType: .expense)
        context.insert(transport)
        context.insert(TransactionCategory(name: "Public Transport", iconName: "bus", transactionType: .expense, parentCategory: transport))
        context.insert(TransactionCategory(name: "Private Hire", iconName: "car", transactionType: .expense, parentCategory: transport))

        // Create sample payees
        let starbucks = Payee(name: "Starbucks")
        context.insert(starbucks)

        let uber = Payee(name: "Uber")
        context.insert(uber)

        let fairprice = Payee(name: "FairPrice")
        context.insert(fairprice)

        // Create sample transactions
        let calendar = Calendar.current

        // Transaction 1: Monthly salary (income)
        let salaryTransaction = Transaction(
            amount: 5000.00,
            category: salary,
            desc: "January salary",
            payee: nil,
            date: calendar.date(from: DateComponents(year: 2026, month: 1, day: 1)) ?? Date()
        )
        context.insert(salaryTransaction)

        // Transaction 2: Groceries
        let groceriesTransaction = Transaction(
            amount: 87.50,
            category: groceries,
            desc: "Weekly groceries",
            payee: fairprice,
            date: calendar.date(from: DateComponents(year: 2026, month: 1, day: 15)) ?? Date()
        )
        context.insert(groceriesTransaction)

        // Transaction 3: Coffee
        let coffeeTransaction = Transaction(
            amount: 12.80,
            category: takeout,
            desc: "Morning coffee",
            payee: starbucks,
            date: calendar.date(from: DateComponents(year: 2026, month: 1, day: 20)) ?? Date()
        )
        context.insert(coffeeTransaction)

        // Transaction 5: Gaming purchase
        let gamingTransaction = Transaction(
            amount: 69.90,
            category: gaming,
            desc: "New game on Steam",
            payee: nil,
            date: calendar.date(from: DateComponents(year: 2026, month: 1, day: 10)) ?? Date()
        )
        context.insert(gamingTransaction)

        // Transaction 6: Haircut (same date as groceries to test section grouping)
        let haircutTransaction = Transaction(
            amount: 35.00,
            category: hairCare,
            desc: "Monthly haircut",
            payee: nil,
            date: calendar.date(from: DateComponents(year: 2026, month: 1, day: 15, hour: 17, minute: 30)) ?? Date()
        )
        context.insert(haircutTransaction)

        return container
    }
}
