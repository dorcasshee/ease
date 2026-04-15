//
//  Category.swift
//  Ease
//
//  Created by Dorcas Shee on 6/12/25.
//

import Foundation
import SwiftData

@Model
final class ParentCategory {
    var id: String = ""
    var name: String
    var iconName: String
    var isSystemIcon: Bool
    var transactionType: TransactionType
    var colorName: String
    
    @Relationship(deleteRule: .cascade, inverse: \SubCategory.parent) var subCategories: [SubCategory] = []
    
    init(id: String, name: String, iconName: String, isSystemIcon: Bool, colorName: String, transactionType: TransactionType) {
        self.id = id
        self.name = name
        self.iconName = iconName
        self.isSystemIcon = isSystemIcon
        self.colorName = colorName
        self.transactionType = transactionType
    }
}

@Model
final class SubCategory {
    var id: String = ""
    var name: String
    var iconName: String
    var isSystemIcon: Bool
    var isDefault: Bool
    var colorName: String
    var parent: ParentCategory?
    var transactionType: TransactionType {
        return parent?.transactionType ?? .expense
    }
    
    @Relationship(inverse: \Transaction.category) var transactions: [Transaction] = []
    
    init(id: String, name: String, iconName: String, isSystemIcon: Bool, isDefault: Bool, colorName: String? = nil, parent: ParentCategory) {
        self.id = id
        self.name = name
        self.iconName = iconName
        self.isSystemIcon = isSystemIcon
        self.isDefault = isDefault
        self.colorName = colorName ?? parent.colorName
        self.parent = parent
    }
}

struct ParentCategoryDTO: Codable {
    let id: String
    let name: String
    let iconName: String
    let isSystemIcon: Bool
    let transactionType: TransactionType
    let colorName: String
    let subCategories: [SubCategoryDTO]
}

struct SubCategoryDTO: Codable {
    let id: String
    let name: String
    let iconName: String
    let isSystemIcon: Bool
    let isDefault: Bool
}
