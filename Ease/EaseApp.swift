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
        context.insert(TransactionCategory(name: "Crafts", iconName: "pencil.and.scribble", colorHex: Strings.Colors.ePinkLightHex, transactionType: .expense, parentCategory: entertainment))
        context.insert(TransactionCategory(name: "Gaming", iconName: "formfitting.gamecontroller", colorHex: Strings.Colors.ePinkLightHex, transactionType: .expense, parentCategory: entertainment))
        
        // food
        let food = TransactionCategory(name: "Food", iconName: "fork.knife", transactionType: .expense)
        context.insert(food)
        context.insert(TransactionCategory(name: "Groceries", iconName: "cart", colorHex: Strings.Colors.eOrangeLightHex, transactionType: .expense, parentCategory: food))
        context.insert(TransactionCategory(name: "Drinks", iconName: "cup.and.saucer", colorHex: Strings.Colors.eOrangeLightHex, transactionType: .expense, parentCategory: food))
        context.insert(TransactionCategory(name: "Food", iconName: "wineglass", colorHex: Strings.Colors.eOrangeLightHex, isDefault: true, transactionType: .expense, parentCategory: food))
        context.insert(TransactionCategory(name: "Takeout", iconName: "takeoutbag.and.cup.and.straw", colorHex: Strings.Colors.eOrangeLightHex, transactionType: .expense, parentCategory: food))
        context.insert(TransactionCategory(name: "Snacks", iconName: "spoon.serving", colorHex: Strings.Colors.eOrangeLightHex, transactionType: .expense, parentCategory: food))
        context.insert(TransactionCategory(name: "Food Delivery", iconName: "motorcycle", colorHex: Strings.Colors.eOrangeLightHex, transactionType: .expense, parentCategory: food))
        
        // health and fitness
        let healthAndFitness = TransactionCategory(name: "Health and Fitness", iconName: "heart", transactionType: .expense)
        context.insert(healthAndFitness)
        context.insert(TransactionCategory(name: "Insurance", iconName: "dollarsign.circle", colorHex: Strings.Colors.eBlueLightHex, transactionType: .expense, parentCategory: healthAndFitness))
        context.insert(TransactionCategory(name: "Medical Bills", iconName: "stethoscope", colorHex: Strings.Colors.eBlueLightHex, transactionType: .expense, parentCategory: healthAndFitness))
        context.insert(TransactionCategory(name: "Medication", iconName: "stethoscope", colorHex: Strings.Colors.eBlueLightHex, transactionType: .expense, parentCategory: healthAndFitness))
        context.insert(TransactionCategory(name: "Wellness", iconName: "figure.run", colorHex: Strings.Colors.eBlueLightHex, transactionType: .expense, parentCategory: healthAndFitness))
        
        // housing
        let housing = TransactionCategory(name: "Housing", iconName: "house", transactionType: .expense)
        context.insert(housing)
        context.insert(TransactionCategory(name: "Rent", iconName: "dollarsign.square", colorHex: Strings.Colors.ePinkLightHex, transactionType: .expense, parentCategory: housing))
        context.insert(TransactionCategory(name: "Mortgage", iconName: "dollarsign.bank.building", colorHex: Strings.Colors.ePinkLightHex, transactionType: .expense, parentCategory: housing))
        context.insert(TransactionCategory(name: "Utilities", iconName: "bolt.house", colorHex: Strings.Colors.ePinkLightHex, transactionType: .expense, parentCategory: housing))
        
        // income
        let income = TransactionCategory(name: "Income", iconName: "dollarsign", transactionType: .income)
        context.insert(income)
        context.insert(TransactionCategory(name: "Salary", iconName: "dollarsign.circle", colorHex: Strings.Colors.eOrangeLightHex, transactionType: .income, parentCategory: income))
        context.insert(TransactionCategory(name: "Freelance", iconName: "dollarsign.circle", colorHex: Strings.Colors.eOrangeLightHex, transactionType: .income, parentCategory: income))
        context.insert(TransactionCategory(name: "Dividends", iconName: "dollarsign.circle", colorHex: Strings.Colors.eOrangeLightHex, isDefault: true, transactionType: .income, parentCategory: income))
        
        // personal care
        let personal = TransactionCategory(name: "Personal Care", iconName: "person", transactionType: .expense)
        context.insert(personal)
        context.insert(TransactionCategory(name: "Hair Care", iconName: "bubbles.and.sparkles", colorHex: Strings.Colors.eBlueLightHex, transactionType: .expense, parentCategory: personal))
        context.insert(TransactionCategory(name: "Body Care", iconName: "bubbles.and.sparkles", colorHex: Strings.Colors.eBlueLightHex, transactionType: .expense, parentCategory: personal))
        context.insert(TransactionCategory(name: "Skin Care", iconName: "bubbles.and.sparkles", colorHex: Strings.Colors.eBlueLightHex, transactionType: .expense, parentCategory: personal))
        context.insert(TransactionCategory(name: "Cosmetics", iconName: "paintbrush.pointed", colorHex: Strings.Colors.eBlueLightHex, transactionType: .expense, parentCategory: personal))
        
        // transport
        let transport = TransactionCategory(name: "Transport", iconName: "car", transactionType: .expense)
        context.insert(transport)
        context.insert(TransactionCategory(name: "Public Transport", iconName: "bus", colorHex: Strings.Colors.ePinkLightHex, transactionType: .expense, parentCategory: transport))
        context.insert(TransactionCategory(name: "Private Hire", iconName: "car", colorHex: Strings.Colors.ePinkLightHex, transactionType: .expense, parentCategory: transport))
        
        return container
    }
}
