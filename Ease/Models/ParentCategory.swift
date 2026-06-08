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
