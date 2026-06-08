//
//  CategoryRepository.swift
//  Ease
//
//  Created by Dorcas Shee on 1/5/26.
//

import Foundation
import SwiftData

protocol CategoryRepository {
    func createParentCategory(context: ModelContext, name: String, iconName: String, isSystemIcon: Bool, colorName: String, transactionType: TransactionType)
    func createSubCategory(context: ModelContext, parentCategory: ParentCategory, name: String, iconName: String, isSystemIcon: Bool, isDefault: Bool, colorName: String)
    func saveCategory(context: ModelContext) throws
    func deleteCategory(context: ModelContext, _ category: SubCategory) throws
    func getMostFrequentCategories(context: ModelContext, limit: Int, transactionType: TransactionType) throws -> [SubCategory]
    func getDefaultCategory(context: ModelContext, for type: TransactionType) throws -> SubCategory
}
