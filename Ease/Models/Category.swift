//
//  Category.swift
//  Ease
//
//  Created by Dorcas Shee on 6/12/25.
//

import Foundation
import SwiftData

@Model
class Category {
    var name: String
    var iconName: String
    var isDefault: Bool
    var transactionType: TransactionType
    var parentCategory: Category? // nil == parent category
    
    @Relationship(deleteRule: .cascade, inverse: \Category.parentCategory) var subCategories: [Category] = []
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
    
    init(name: String, iconName: String, isDefault: Bool = false, transactionType: TransactionType, parentCategory: Category? = nil) {
        self.name = name
        self.iconName = iconName
        self.isDefault = isDefault
        self.transactionType = transactionType
        self.parentCategory = parentCategory
    }
}

struct CategorySeed: Codable {
    let name: String
    let iconName: String
    let isDefault: Bool
    let transactionType: String // "income" or "expense"
    let subCategories: [CategorySeed]? // Nested structure
}

extension Category {
    static func seedDefaultCategories(in context: ModelContext) throws {
        let fetchDesc = FetchDescriptor<Category>()
        let existingCount = try context.fetchCount(fetchDesc)

        guard existingCount == 0 else { return }

        // entertainment
        let entertainment = Category(name: "Entertainment", iconName: "tv", transactionType: .expense)
        context.insert(entertainment)
        context.insert(Category(name: "Crafts", iconName: "pencil.and.scribble", transactionType: .expense, parentCategory: entertainment))
        context.insert(Category(name: "Gaming", iconName: "formfitting.gamecontroller", transactionType: .expense, parentCategory: entertainment))

        // food
        let food = Category(name: "Food", iconName: "fork.knife", transactionType: .expense)
        context.insert(food)
        context.insert(Category(name: "Groceries", iconName: "carrot", transactionType: .expense, parentCategory: food))
        context.insert(Category(name: "Drinks", iconName: "cup.and.saucer", transactionType: .expense, parentCategory: food))
        context.insert(Category(name: "Food", iconName: "fork.knife", isDefault: true, transactionType: .expense, parentCategory: food))
        context.insert(Category(name: "Takeout", iconName: "takeoutbag.and.cup.and.straw", transactionType: .expense, parentCategory: food))
        context.insert(Category(name: "Snacks", iconName: "spoon.serving", transactionType: .expense, parentCategory: food))
        context.insert(Category(name: "Food Delivery", iconName: "motorcycle", transactionType: .expense, parentCategory: food))
        
        // health and fitness
        let healthAndFitness = Category(name: "Health and Fitness", iconName: "heart", transactionType: .expense)
        context.insert(healthAndFitness)
        context.insert(Category(name: "Insurance", iconName: "dollarsign.circle", transactionType: .expense, parentCategory: healthAndFitness))
        context.insert(Category(name: "Medical Bills", iconName: "stethoscope", transactionType: .expense, parentCategory: healthAndFitness))
        context.insert(Category(name: "Medication", iconName: "pill", transactionType: .expense, parentCategory: healthAndFitness))
        context.insert(Category(name: "Wellness", iconName: "figure.run", transactionType: .expense, parentCategory: healthAndFitness))

        // housing
        let housing = Category(name: "Housing", iconName: "house", transactionType: .expense)
        context.insert(housing)
        context.insert(Category(name: "Rent", iconName: "dollarsign.square", transactionType: .expense, parentCategory: housing))
        context.insert(Category(name: "Mortgage", iconName: "dollarsign.bank.building", transactionType: .expense, parentCategory: housing))
        context.insert(Category(name: "Utilities", iconName: "bolt.house", transactionType: .expense, parentCategory: housing))

        // income
        let income = Category(name: "Income", iconName: "dollarsign", transactionType: .income)
        context.insert(income)
        context.insert(Category(name: "Salary", iconName: "dollarsign.circle", isDefault: true, transactionType: .income, parentCategory: income))
        context.insert(Category(name: "Freelance", iconName: "dollarsign.circle", transactionType: .income, parentCategory: income))
        context.insert(Category(name: "Dividends", iconName: "dollarsign.circle", transactionType: .income, parentCategory: income))
        
        // personal care
        let personal = Category(name: "Personal Care", iconName: "person", transactionType: .expense)
        context.insert(personal)
        context.insert(Category(name: "Hair Care", iconName: "bubbles.and.sparkles", transactionType: .expense, parentCategory: personal))
        context.insert(Category(name: "Body Care", iconName: "bubbles.and.sparkles", transactionType: .expense, parentCategory: personal))
        context.insert(Category(name: "Skin Care", iconName: "bubbles.and.sparkles", transactionType: .expense, parentCategory: personal))
        context.insert(Category(name: "Cosmetics", iconName: "paintbrush.pointed", transactionType: .expense, parentCategory: personal))
        
        // transport
        let transport = Category(name: "Transport", iconName: "car", transactionType: .expense)
        context.insert(transport)
        context.insert(Category(name: "Public Transport", iconName: "bus", transactionType: .expense, parentCategory: transport))
        context.insert(Category(name: "Private Hire", iconName: "car", transactionType: .expense, parentCategory: transport))
    }
}
