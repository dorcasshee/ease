//
//  CategoryViewModel.swift
//  Ease
//
//  Created by Dorcas Shee on 7/12/25.
//

import Foundation
import SwiftData

@Observable class CategoryViewModel {
    // repositories
    var categoryRepository: CategoryRepository
    
    var name: String?
    var iconName: String?
    var isDefault: Bool = false
    var isSystemIcon: Bool = true
    var colorName: String?
    var transactionType: TransactionType = .expense
    var collapsedSections: Set<String> = []
    
    // UI state
    var showSheet: Bool = false
    var showEditSheet: Bool = false
    var showError: Bool = false
    var error: AppError? = nil
    
    init(categoryRepository: CategoryRepository = SwiftDataCategoryService()) {
        self.categoryRepository = categoryRepository
    }
    
    func createParentCategory(context: ModelContext) {
        guard let name = name, let iconName = iconName else { return }
        
        categoryRepository.createParentCategory(context: context, name: name, iconName: iconName, isSystemIcon: isSystemIcon, colorName: colorName ?? "eOrange", transactionType: transactionType)
    }
    
    func createSubCategory(context: ModelContext, parentCategory: ParentCategory) {
        guard let name = name, let iconName = iconName else { return }
        
        categoryRepository.createSubCategory(context: context, parentCategory: parentCategory, name: name, iconName: iconName, isSystemIcon: isSystemIcon, isDefault: isDefault, colorName: colorName ?? parentCategory.colorName)
    }
    
    func sortParentCategories(parents: [ParentCategory], type: TransactionType) -> [ParentCategory] {
        parents.filter { $0.transactionType == type }
            .sorted(by: { $0.name < $1.name })
    }
    
    func getMostFrequentCategories(context: ModelContext, limit: Int = 8, transactionType: TransactionType) throws -> [SubCategory] {
        do {
            return try categoryRepository.getMostFrequentCategories(context: context, limit: limit, transactionType: transactionType)
        } catch {
            self.error = .unexpectedError
            showError = true
            return []
        }
    }
    
    func sortedSubCategories(parent: ParentCategory) -> [SubCategory] {
        parent.subCategories.sorted(by: { $0.name < $1.name })
    }
    
    func getDefaultCategory(for type: TransactionType, context: ModelContext) throws -> SubCategory {
        try categoryRepository.getDefaultCategory(context: context, for: type)
    }
    
    func isAllCollapsed(parentCount: Int) -> Bool {
        collapsedSections.count == parentCount;
    }
    
    func toggleSection(parentID: String) {
        if collapsedSections.contains(parentID) {
            collapsedSections.remove(parentID)
        } else {
            collapsedSections.insert(parentID)
        }
    }
}
