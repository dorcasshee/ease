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
    var colorHex: String
    var isDefault: Bool
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
    
    init(name: String, iconName: String, colorHex: String, isDefault: Bool = false, parentCategory: TransactionCategory? = nil) {
        self.name = name
        self.iconName = iconName
        self.colorHex = colorHex
        self.isDefault = isDefault
        self.parentCategory = parentCategory
    }
}

extension TransactionCategory {
    static func seedDefaultCategories(in context: ModelContext) throws {
        let fetchDesc = FetchDescriptor<TransactionCategory>()
        let existingCount = try context.fetchCount(fetchDesc)

        guard existingCount == 0 else { return }

        // income
        let income = TransactionCategory(name: "Income", iconName: "dollarsign", colorHex: Strings.Colors.eOrangeLightHex)
        context.insert(income)
        context.insert(TransactionCategory(name: "Salary", iconName: "dollarsign.circle", colorHex: Strings.Colors.eOrangeLightHex, parentCategory: income))
        context.insert(TransactionCategory(name: "Freelance", iconName: "dollarsign.circle", colorHex: Strings.Colors.eOrangeLightHex, parentCategory: income))
        context.insert(TransactionCategory(name: "Dividends", iconName: "dollarsign.circle", colorHex: Strings.Colors.eOrangeLightHex, parentCategory: income))

        // food
        let food = TransactionCategory(name: "Food", iconName: "fork.knife", colorHex: Strings.Colors.ePinkLightHex)
        context.insert(food)
        context.insert(TransactionCategory(name: "Groceries", iconName: "cart", colorHex: Strings.Colors.ePinkLightHex, parentCategory: food))
        context.insert(TransactionCategory(name: "Drinks", iconName: "cup.and.saucer", colorHex: Strings.Colors.ePinkLightHex, parentCategory: food))
        context.insert(TransactionCategory(name: "Dine Out", iconName: "wineglass", colorHex: Strings.Colors.ePinkLightHex, parentCategory: food))
        context.insert(TransactionCategory(name: "Takeout & Food Delivery", iconName: "takeoutbag.and.cup.and.straw", colorHex: Strings.Colors.ePinkLightHex, parentCategory: food))
        context.insert(TransactionCategory(name: "Snacks", iconName: "spoon.serving", colorHex: Strings.Colors.ePinkLightHex, parentCategory: food))

        // housing
        let housing = TransactionCategory(name: "Housing", iconName: "house", colorHex: Strings.Colors.eBlueLightHex)
        context.insert(housing)
        context.insert(TransactionCategory(name: "Rent", iconName: "dollarsign.square", colorHex: Strings.Colors.eBlueLightHex, parentCategory: housing))
        context.insert(TransactionCategory(name: "Mortgage", iconName: "dollarsign.bank.building", colorHex: Strings.Colors.eBlueLightHex, parentCategory: housing))
        context.insert(TransactionCategory(name: "Utilities", iconName: "bolt.house", colorHex: Strings.Colors.eBlueLightHex, parentCategory: housing))

        // transport
        let transport = TransactionCategory(name: "Transport", iconName: "car", colorHex: Strings.Colors.eOrangeDarkHex)
        context.insert(transport)
        context.insert(TransactionCategory(name: "Public Transport", iconName: "bus", colorHex: Strings.Colors.eOrangeDarkHex, parentCategory: transport))
        context.insert(TransactionCategory(name: "Private Hire", iconName: "car", colorHex: Strings.Colors.eOrangeDarkHex, parentCategory: transport))

        // entertainment
        let entertainment = TransactionCategory(name: "Entertainment", iconName: "tv", colorHex: Strings.Colors.ePinkDarkHex)
        context.insert(entertainment)
        context.insert(TransactionCategory(name: "Crafts", iconName: "pencil.and.scribble", colorHex: Strings.Colors.ePinkDarkHex, parentCategory: entertainment))
        context.insert(TransactionCategory(name: "Gaming", iconName: "formfitting.gamecontroller", colorHex: Strings.Colors.ePinkDarkHex, parentCategory: entertainment))

        // health and fitness
        let healthAndFitness = TransactionCategory(name: "Health and Fitness", iconName: "heart", colorHex: Strings.Colors.eBlueDarkHex)
        context.insert(healthAndFitness)
        context.insert(TransactionCategory(name: "Insurance", iconName: "dollarsign.circle", colorHex: Strings.Colors.eBlueDarkHex, parentCategory: healthAndFitness))
        context.insert(TransactionCategory(name: "Medical Bills", iconName: "stethoscope", colorHex: Strings.Colors.eBlueDarkHex, parentCategory: healthAndFitness))
        context.insert(TransactionCategory(name: "Medication", iconName: "stethoscope", colorHex: Strings.Colors.eBlueDarkHex, parentCategory: healthAndFitness))
        context.insert(TransactionCategory(name: "Wellness", iconName: "figure.run", colorHex: Strings.Colors.eBlueDarkHex, parentCategory: healthAndFitness))

        // personal care
        let personal = TransactionCategory(name: "Personal Care", iconName: "person", colorHex: Strings.Colors.eOrangeLightHex)
        context.insert(personal)
        context.insert(TransactionCategory(name: "Hair Care", iconName: "bubbles.and.sparkles", colorHex: Strings.Colors.eOrangeLightHex, parentCategory: personal))
        context.insert(TransactionCategory(name: "Body Care", iconName: "bubbles.and.sparkles", colorHex: Strings.Colors.eOrangeLightHex, parentCategory: personal))
        context.insert(TransactionCategory(name: "Skin Care", iconName: "bubbles.and.sparkles", colorHex: Strings.Colors.eOrangeLightHex, parentCategory: personal))
        context.insert(TransactionCategory(name: "Cosmetics", iconName: "paintbrush.pointed", colorHex: Strings.Colors.eOrangeLightHex, parentCategory: personal))
    }
}
