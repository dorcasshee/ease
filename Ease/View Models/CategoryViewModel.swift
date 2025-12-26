//
//  CategoryViewModel.swift
//  Ease
//
//  Created by Dorcas Shee on 7/12/25.
//

import Foundation
import SwiftData

@Observable class CategoryViewModel {
    var showSheet: Bool = false
    
    func createCategory(context: ModelContext) {
        
    }
    
    func getParentCategories(categories: [TransactionCategory], transactionType: TransactionType) -> [TransactionCategory] {
        categories.filter { $0.isParent && $0.transactionType == transactionType }
            .sorted(by: { $0.name < $1.name })
    }
    
    func getMostFrequentCategories(categories: [TransactionCategory], limit: Int = 8) -> [TransactionCategory] {
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
    
    func sortedSubCategories(cat: [TransactionCategory]) -> [TransactionCategory] {
        cat.sorted(by: { $0.name < $1.name })
    }
    
    func getDefaultCategory(for transactionType: TransactionType, context: ModelContext) throws -> TransactionCategory {
        let descriptor = FetchDescriptor<TransactionCategory> ( predicate: #Predicate { $0.isDefault == true })
        let defaultCategories = try context.fetch(descriptor)
        
        guard let category = defaultCategories.first(where: { $0.transactionType == transactionType }) else { throw AppError.noDefaultCategory }
        
        return category
    }
}
