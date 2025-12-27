//
//  TransactionCategory.swift
//  Ease
//
//  Created by Dorcas Shee on 6/12/25.
//

import Foundation
import SwiftData

@Model
class TransactionCategory {
    var name: String
    var iconName: String
    var isDefault: Bool
    var transactionType: TransactionType
    var parentCategory: TransactionCategory? // nil == top-level category
    
    @Relationship(deleteRule: .cascade, inverse: \TransactionCategory.parentCategory) var subCategories: [TransactionCategory] = []
    @Relationship(deleteRule: .deny, inverse: \Transaction.category) var transactions: [Transaction] = []
    
    // computed properties
    var isParent: Bool {
        parentCategory == nil
    }
    
    var isSubCategory: Bool {
        parentCategory != nil
    }
    
    var usageCount: Int {
        transactions.count
    }
    
    init(name: String, iconName: String, isDefault: Bool = false, transactionType: TransactionType, parentCategory: TransactionCategory? = nil) {
        self.name = name
        self.iconName = iconName
        self.isDefault = isDefault
        self.transactionType = transactionType
        self.parentCategory = parentCategory
    }
}

extension TransactionCategory {
    static func seedDefaultCategories(in context: ModelContext) throws {
        let fetchDesc = FetchDescriptor<TransactionCategory>()
        let existingCount = try context.fetchCount(fetchDesc)

        guard existingCount == 0 else { return }

        // entertainment
        let entertainment = TransactionCategory(name: "Entertainment", iconName: "tv", transactionType: .expense)
        context.insert(entertainment)
        context.insert(TransactionCategory(name: "Crafts", iconName: "pencil.and.scribble", transactionType: .expense, parentCategory: entertainment))
        context.insert(TransactionCategory(name: "Gaming", iconName: "formfitting.gamecontroller", transactionType: .expense, parentCategory: entertainment))

        // food
        let food = TransactionCategory(name: "Food", iconName: "fork.knife", transactionType: .expense)
        context.insert(food)
        context.insert(TransactionCategory(name: "Groceries", iconName: "cart", transactionType: .expense, parentCategory: food))
        context.insert(TransactionCategory(name: "Drinks", iconName: "cup.and.saucer", transactionType: .expense, parentCategory: food))
        context.insert(TransactionCategory(name: "Food", iconName: "wineglass", isDefault: true, transactionType: .expense, parentCategory: food))
        context.insert(TransactionCategory(name: "Takeout", iconName: "takeoutbag.and.cup.and.straw", transactionType: .expense, parentCategory: food))
        context.insert(TransactionCategory(name: "Snacks", iconName: "spoon.serving", transactionType: .expense, parentCategory: food))
        context.insert(TransactionCategory(name: "Food Delivery", iconName: "motorcycle", transactionType: .expense, parentCategory: food))
        
        // health and fitness
        let healthAndFitness = TransactionCategory(name: "Health and Fitness", iconName: "heart", transactionType: .expense)
        context.insert(healthAndFitness)
        context.insert(TransactionCategory(name: "Insurance", iconName: "dollarsign.circle", transactionType: .expense, parentCategory: healthAndFitness))
        context.insert(TransactionCategory(name: "Medical Bills", iconName: "stethoscope", transactionType: .expense, parentCategory: healthAndFitness))
        context.insert(TransactionCategory(name: "Medication", iconName: "pill", transactionType: .expense, parentCategory: healthAndFitness))
        context.insert(TransactionCategory(name: "Wellness", iconName: "figure.run", transactionType: .expense, parentCategory: healthAndFitness))

        // housing
        let housing = TransactionCategory(name: "Housing", iconName: "house", transactionType: .expense)
        context.insert(housing)
        context.insert(TransactionCategory(name: "Rent", iconName: "dollarsign.square", transactionType: .expense, parentCategory: housing))
        context.insert(TransactionCategory(name: "Mortgage", iconName: "dollarsign.bank.building", transactionType: .expense, parentCategory: housing))
        context.insert(TransactionCategory(name: "Utilities", iconName: "bolt.house", transactionType: .expense, parentCategory: housing))

        // income
        let income = TransactionCategory(name: "Income", iconName: "dollarsign", transactionType: .income)
        context.insert(income)
        context.insert(TransactionCategory(name: "Salary", iconName: "dollarsign.circle", isDefault: true, transactionType: .income, parentCategory: income))
        context.insert(TransactionCategory(name: "Freelance", iconName: "dollarsign.circle", transactionType: .income, parentCategory: income))
        context.insert(TransactionCategory(name: "Dividends", iconName: "dollarsign.circle", transactionType: .income, parentCategory: income))
        
        // personal care
        let personal = TransactionCategory(name: "Personal Care", iconName: "person", transactionType: .expense)
        context.insert(personal)
        context.insert(TransactionCategory(name: "Hair Care", iconName: "bubbles.and.sparkles", transactionType: .expense, parentCategory: personal))
        context.insert(TransactionCategory(name: "Body Care", iconName: "bubbles.and.sparkles", transactionType: .expense, parentCategory: personal))
        context.insert(TransactionCategory(name: "Skin Care", iconName: "bubbles.and.sparkles", transactionType: .expense, parentCategory: personal))
        context.insert(TransactionCategory(name: "Cosmetics", iconName: "paintbrush.pointed", transactionType: .expense, parentCategory: personal))
        
        // transport
        let transport = TransactionCategory(name: "Transport", iconName: "car", transactionType: .expense)
        context.insert(transport)
        context.insert(TransactionCategory(name: "Public Transport", iconName: "bus", transactionType: .expense, parentCategory: transport))
        context.insert(TransactionCategory(name: "Private Hire", iconName: "car", transactionType: .expense, parentCategory: transport))
    }
}
