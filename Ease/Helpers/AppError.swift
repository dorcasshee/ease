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
    
    // general errors
    case unexpectedError
    
    var errorTitle: String {
        switch self {
        case .missingCategory: return "Missing Category"
        case .noDefaultCategory: return "No Default Category Found"
        case .unexpectedError: return "Unexpected Error"
        }
    }
    
    var errorMessage: String {
        switch self {
        case .missingCategory: return "Please select a category."
        case .noDefaultCategory: return "There is no default category found."
        case .unexpectedError: return "An unexpected error occurred while saving this transaction. Please try again."
        }
    }
}
