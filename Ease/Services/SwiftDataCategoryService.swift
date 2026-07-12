//
//  SwiftDataCategoryRepository.swift
//  Ease
//
//  Created by Dorcas Shee on 1/5/26.
//

import Foundation
import SwiftData

class SwiftDataCategoryService: CategoryRepository {
    func createParentCategory(context: ModelContext,
                              name: String,
                              iconName: String,
                              isSystemIcon: Bool,
                              colorName: String,
                              transactionType: TransactionType) {
        
        let newCategory = ParentCategory(id: UUID().uuidString,
                                         name: name,
                                         iconName: iconName,
                                         isSystemIcon: isSystemIcon,
                                         colorName: colorName,
                                         transactionType: transactionType)
        
        context.insert(newCategory)
    }
    
    func createSubCategory(context: ModelContext,
                           parentCategory: ParentCategory,
                           name: String,
                           iconName: String,
                           isSystemIcon: Bool,
                           isDefault: Bool,
                           colorName: String) {
        
        let newCategory = SubCategory(id: UUID().uuidString,
                                      name: name,
                                      iconName: iconName,
                                      isSystemIcon: isSystemIcon,
                                      isDefault: isDefault,
                                      colorName: colorName,
                                      parent: parentCategory)
        
        context.insert(newCategory)
    }
    
    func saveCategory(context: ModelContext) throws {
        try context.save()
    }
    
    func deleteCategory(context: ModelContext, _ category: SubCategory) throws {
        context.delete(category)
        try context.save()
    }
    
    func getMostFrequentCategories(context: ModelContext, limit: Int = 8, transactionType: TransactionType) throws -> [SubCategory] {
        let descriptor = FetchDescriptor<SubCategory>()
        let subCategories = try context.fetch(descriptor)

        let cutoffDate = Calendar.current.date(byAdding: .month, value: -3, to: Date()) ?? .distantPast
        let minRecentTransactions = 3

        func recentTransactionCount(_ subCategory: SubCategory) -> Int {
            subCategory.transactions.filter { $0.date >= cutoffDate }.count
        }

        return subCategories
            .filter { $0.transactionType == transactionType }
            .map { ($0, recentTransactionCount($0)) }
            .filter { $0.1 >= minRecentTransactions }
            .sorted {
                if $0.1 == $1.1 {
                    return $0.0.name < $1.0.name
                }
                return $0.1 > $1.1
            }
            .prefix(limit)
            .map { $0.0 }
    }
    
    func getDefaultCategory(context: ModelContext, for type: TransactionType) throws -> SubCategory {
        let descriptor = FetchDescriptor<SubCategory> ( predicate: #Predicate { $0.isDefault == true })
        let defaultCategories = try context.fetch(descriptor)
        
        guard let category = defaultCategories.first(where: { $0.transactionType == type }) else { throw AppError.noDefaultCategory }
        
        return category
    }
}
