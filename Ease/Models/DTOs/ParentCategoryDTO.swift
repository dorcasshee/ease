//
//  ParentCategoryDTO.swift
//  Ease
//
//  Created by Dorcas Shee on 1/5/26.
//

import Foundation

struct ParentCategoryDTO: Codable {
    let id: String
    let name: String
    let iconName: String
    let isSystemIcon: Bool
    let transactionType: TransactionType
    let colorName: String
    let subCategories: [SubCategoryDTO]
}
