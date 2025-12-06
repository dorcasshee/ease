//
//  TransactionCategory.swift
//  Ease
//
//  Created by Dorcas Shee on 6/12/25.
//

import Foundation
import SwiftData

@Model
class TransactionCategory {
    @Attribute(.unique) var name: String
    var type: TransactionType
    var iconName: String
    var colorHex: String
    var isDefault: Bool
    
    @Relationship(deleteRule: .deny, inverse: \Transaction.category) var transactions: [Transaction] = []
    
    init(name: String, type: TransactionType, iconName: String, colorHex: String, isDefault: Bool) {
        self.name = name
        self.type = type
        self.iconName = iconName
        self.colorHex = colorHex
        self.isDefault = isDefault
    }
}

enum TransactionType: String, CaseIterable {
    case income, expense
}
