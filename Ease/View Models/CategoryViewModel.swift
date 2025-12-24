//
//  CategoryViewModel.swift
//  Ease
//
//  Created by Dorcas Shee on 7/12/25.
//

import Foundation
import SwiftData

@Observable class CategoryViewModel {
    
    func createCategory(context: ModelContext) {
        
    }
    
    func getParentCategories(categories: [TransactionCategory]) -> [TransactionCategory] {
        categories.filter { $0.isParent }
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
}
