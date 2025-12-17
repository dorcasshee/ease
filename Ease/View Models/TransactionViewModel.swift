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
    var desc: String?
    var payeeName: String = ""
    var isRecurring: Bool = false
    
    init() {
        self.payeeViewModel = PayeeViewModel()
        self.date = Date()
    }
    
    func createTransaction(context: ModelContext) throws {
        guard let category = category else { throw ValidationError.missingCategory } // missingCategory error
        guard amount > 0 else { throw ValidationError.invalidAmount } // invalid amount error
        
        let trimmedName = payeeName.trimmingCharacters(in: .whitespacesAndNewlines)
        let payee = trimmedName.isEmpty ? nil : payeeViewModel.getOrCreatePayee(context: context, name: trimmedName)
        
        let newTransaction = Transaction(amount: amount,
                                         category: category,
                                         desc: desc,
                                         payee: payee,
                                         date: date,
                                         isRecurring: isRecurring)
        
        context.insert(newTransaction)
    }
    
    func updateTransaction(context: ModelContext, item: Transaction) throws {
        guard let category = category else { throw ValidationError.missingCategory } // missingCategory error
        guard amount > 0 else { throw ValidationError.invalidAmount } // invalid amount error
        
        let trimmedName = payeeName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        item.amount = amount
        item.category = category
        item.desc = desc
        item.payee = trimmedName.isEmpty ? nil : payeeViewModel.getOrCreatePayee(context: context, name: trimmedName)
        item.date = date
        item.isRecurring = isRecurring
    }
    
    func deleteTransaction(context: ModelContext, item: Transaction) {
        context.delete(item)
    }
}

enum TransactionType: String, Identifiable {
    case expense, income
    var id: String { rawValue }
    
    static let allCases: [TransactionType] = [.expense, .income]
}

enum ValidationError: Error {
    case missingCategory, invalidAmount
    
    var errorMessage: String {
        switch self {
            case .missingCategory: return "Please select a category."
            case .invalidAmount: return "Amount should be more than $0.00."
        }
    }
}
