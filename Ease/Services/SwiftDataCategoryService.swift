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
        let descriptor = FetchDescriptor<SubCategory>(predicate: #Predicate { $0.parent?.transactionType == transactionType })
        let subCategories = try context.fetch(descriptor)
        
        return subCategories.sorted {
            if $0.transactions.count == $1.transactions.count {
                return $0.name < $1.name
            }
            return $0.transactions.count > $1.transactions.count
        }
        .prefix(limit)
        .map { $0 }
    }
    
    func getDefaultCategory(context: ModelContext, for type: TransactionType) throws -> SubCategory {
        let descriptor = FetchDescriptor<SubCategory> ( predicate: #Predicate { $0.isDefault == true })
        let defaultCategories = try context.fetch(descriptor)
        
        guard let category = defaultCategories.first(where: { $0.transactionType == type }) else { throw AppError.noDefaultCategory }
        
        return category
    }
}
