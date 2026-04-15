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
    var isSystemIcon: Bool = true
    var colorName: String?
    var transactionType: TransactionType = .expense
    var showSheet: Bool = false
    var collapsedSections: Set<String> = []
    
    func createParentCategory(context: ModelContext) {
        guard let name = name, let iconName = iconName else { return }
        
        let newCategory = ParentCategory(id: UUID().uuidString, name: name, iconName: iconName, isSystemIcon: isSystemIcon, colorName: "eOrange", transactionType: transactionType)
        
        context.insert(newCategory)
    }
    
    func createSubCategory(context: ModelContext, parentCategory: ParentCategory) {
        guard let name = name, let iconName = iconName else { return }
        
        let newCategory = SubCategory(id: UUID().uuidString, name: name, iconName: iconName, isSystemIcon: isSystemIcon, isDefault: isDefault, colorName: parentCategory.colorName, parent: parentCategory)
        
        context.insert(newCategory)
    }
    
    func sortParentCategories(parents: [ParentCategory], type: TransactionType) -> [ParentCategory] {
        parents.filter { $0.transactionType == type }
            .sorted(by: { $0.name < $1.name })
    }
    
    func getMostFrequentCategories(context: ModelContext, limit: Int = 8) throws -> [SubCategory] {
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
    
    func sortedSubCategories(parent: ParentCategory) -> [SubCategory] {
        parent.subCategories.sorted(by: { $0.name < $1.name })
    }
    
    func getDefaultCategory(for type: TransactionType, context: ModelContext) throws -> SubCategory {
        let descriptor = FetchDescriptor<SubCategory> ( predicate: #Predicate { $0.isDefault == true })
        let defaultCategories = try context.fetch(descriptor)
        
        guard let category = defaultCategories.first(where: { $0.transactionType == type }) else { throw AppError.noDefaultCategory }
        
        return category
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
