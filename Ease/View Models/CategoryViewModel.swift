//
//  CategoryViewModel.swift
//  Ease
//
//  Created by Dorcas Shee on 7/12/25.
//

import Foundation
import SwiftData

@Observable class CategoryViewModel {
    var name: String?
    var iconName: String?
    var isDefault: Bool = false
    var transactionType: TransactionType = .expense
    var showSheet: Bool = false
    
    func createParentCategory(context: ModelContext) {
        guard let name = name, let iconName = iconName else { return }
        
        let newCategory = Category(name: name, iconName: name, transactionType: transactionType)
        
        context.insert(newCategory)
    }
    
    func createSubCategory(context: ModelContext, parentCategory: Category) {
        guard let name = name, let iconName = iconName else { return }
        
        let newCategory = Category(name: name, iconName: name, transactionType: transactionType, parentCategory: parentCategory)
        
        context.insert(newCategory)
    }
    
    func getParentCategories(categories: [Category], transactionType: TransactionType) -> [Category] {
        categories.filter { $0.isParent && $0.transactionType == transactionType }
            .sorted(by: { $0.name < $1.name })
    }
    
    func getMostFrequentCategories(categories: [Category], limit: Int = 8) -> [Category] {
        let subCategories = categories.filter { $0.isSubCategory }
        return subCategories.sorted {
            if $0.usageCount == $1.usageCount {
                return $0.name < $1.name
            }
            return $0.usageCount > $1.usageCount
        }
        .prefix(limit)
        .map { $0 }
    }
    
    func sortedSubCategories(cat: [Category]) -> [Category] {
        cat.sorted(by: { $0.name < $1.name })
    }
    
    func getDefaultCategory(for transactionType: TransactionType, context: ModelContext) throws -> Category {
        let descriptor = FetchDescriptor<Category> ( predicate: #Predicate { $0.isDefault == true })
        let defaultCategories = try context.fetch(descriptor)
        
        guard let category = defaultCategories.first(where: { $0.transactionType == transactionType }) else { throw AppError.noDefaultCategory }
        
        return category
    }
}
