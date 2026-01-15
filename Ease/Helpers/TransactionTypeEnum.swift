//
//  TransactionTypeEnum.swift
//  Ease
//
//  Created by Dorcas Shee on 28/12/25.
//

import Foundation
import SwiftUI

enum TransactionType: String, Identifiable, Codable {
    case expense, income
    var id: String { rawValue }
    
    static let allCases: [TransactionType] = [.expense, .income]
    
    var color: Color {
        switch self {
        case .expense:
            return .eOrange
        case .income:
            return .ePink
        }
    }
}
