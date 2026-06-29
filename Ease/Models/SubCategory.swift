//
//  SubCategory.swift
//  Ease
//
//  Created by Dorcas Shee on 1/5/26.
//

import Foundation
import SwiftData

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
    
    @Relationship(deleteRule: .deny, inverse: \Transaction.category) var transactions: [Transaction] = []
    
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
