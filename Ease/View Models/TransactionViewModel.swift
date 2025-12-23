//
//  TransactionViewModel.swift
//  Ease
//
//  Created by Dorcas Shee on 6/12/25.
//

import Foundation
import SwiftData

@Observable class TransactionViewModel {
    /*
     This view model contains the following logic for transaction CRUD operations.
     */
    
    private var payeeViewModel: PayeeViewModel
    var amount: Double = 0
    var isSelected: Bool = false
    var date: Date
    var transactionType: TransactionType = .expense
    var category: TransactionCategory?
    var desc: String = ""
    var payeeName: String = ""
    var isRecurring: Bool = false
    
    var selectedCategory: TransactionCategory?
    
    var showError: Bool = false
    var valError: ValidationError?
    
    var showSheet: Bool = false
    
    init() {
        self.payeeViewModel = PayeeViewModel()
        self.date = Date()
    }
    
    func createTransaction(context: ModelContext) {
        showError = false
        valError = nil
        
        do {
            guard let category = category else { throw ValidationError.missingCategory } // missingCategory error
            guard amount > 0 else { throw ValidationError.invalidAmount } // invalid amount error
            
            let trimmedName = payeeName.trimmingCharacters(in: .whitespacesAndNewlines)
            let payee = trimmedName.isEmpty ? nil : payeeViewModel.getOrCreatePayee(context: context, name: trimmedName)
            
            let newTransaction = Transaction(amount: amount,
                                             category: category,
                                             desc: desc.isEmpty ? nil : desc,
                                             payee: payee,
                                             date: date,
                                             isRecurring: isRecurring)
            
            context.insert(newTransaction)
            try context.save()
        } catch let error as ValidationError {
            valError = error
            showError = true
        } catch {
            valError = .unexpectedError
            showError = true
        }
    }
    
    func updateTransaction(context: ModelContext, item: Transaction) {
        showError = false
        valError = nil
        
        do {
            guard let category = category else { throw ValidationError.missingCategory } // missingCategory error
            guard amount > 0 else { throw ValidationError.invalidAmount } // invalid amount error
            
            let trimmedName = payeeName.trimmingCharacters(in: .whitespacesAndNewlines)
            
            item.amount = amount
            item.category = category
            item.desc = desc.isEmpty ? nil : desc
            item.payee = trimmedName.isEmpty ? nil : payeeViewModel.getOrCreatePayee(context: context, name: trimmedName)
            item.date = date
            item.isRecurring = isRecurring
            
            try context.save()
        } catch let error as ValidationError {
            valError = error
            showError = true
        } catch {
            valError = .unexpectedError
            showError = true
        }
    }
    
    func deleteTransaction(context: ModelContext, item: Transaction) {
        context.delete(item)
    }
    
    func incrementDate() {
        if let newDate = Calendar.current.date(byAdding: .day, value: 1, to: date) {
            date = newDate
        }
    }
    
    func decrementDate() {
        if let newDate = Calendar.current.date(byAdding: .day, value: -1, to: date) {
            date = newDate
        }
    }
}


// MARK: Enums
enum TransactionType: String, Identifiable {
    case expense, income
    var id: String { rawValue }
    
    static let allCases: [TransactionType] = [.expense, .income]
}

enum ValidationError: Error {
    case missingCategory, invalidAmount, unexpectedError
    
    var errorTitle: String {
        switch self {
            case .missingCategory: return "Missing Category"
            case .invalidAmount: return "Invalid Amount"
            case .unexpectedError: return "Unexpected Error"
        }
    }
    
    var errorMessage: String {
        switch self {
            case .missingCategory: return "Please select a category."
            case .invalidAmount: return "Amount should be more than $0.00."
            case .unexpectedError: return "An unexpected error occurred while saving this transaction. Please try again."
        }
    }
}
