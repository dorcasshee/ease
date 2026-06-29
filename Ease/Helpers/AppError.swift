//
//  AppError.swift
//  Ease
//
//  Created by Dorcas Shee on 25/12/25.
//

import Foundation

enum AppError: Error {
    // transaction errors
    case missingCategory
    
    // category errors
    case noDefaultCategory
    case sectionInUse
    case categoryHasTransactions
    
    // general errors
    case unexpectedError
    
    var errorTitle: String {
        switch self {
        case .missingCategory: return "Missing Category"
        case .noDefaultCategory: return "No Default Category Found"
        case .sectionInUse: return "Category in Use"
        case .categoryHasTransactions: return "Category with Transactions"
        case .unexpectedError: return "Unexpected Error"
        }
    }
    
    var errorMessage: String {
        switch self {
        case .missingCategory: return "Please select a category."
        case .noDefaultCategory: return "There is no default category found."
        case .sectionInUse: return "There are still categories in this Section. Are you sure you want to delete this Section?"
        case .categoryHasTransactions: return "There are transactions linked to this category. Are you sure you want to delete this category?"
        case .unexpectedError: return "An unexpected error occurred while saving this transaction. Please try again."
        }
    }
}
