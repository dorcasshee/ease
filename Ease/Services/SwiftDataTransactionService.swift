//
//  SwiftDataTransactionRepository.swift
//  Ease
//
//  Created by Dorcas Shee on 1/5/26.
//

import Foundation
import SwiftData

class SwiftDataTransactionService: TransactionRepository {
    func createTransaction(amount: Double,
                           category: SubCategory,
                           desc: String?,
                           payee: Payee?,
                           date: Date,
                           isRecurring: Bool,
                           context: ModelContext) throws {
        
        let newTransaction = Transaction(amount: amount,
                                         category: category,
                                         desc: desc,
                                         payee: payee,
                                         date: date,
                                         isRecurring: isRecurring)
        
        context.insert(newTransaction)
    }
    
    func saveTransaction(context: ModelContext) throws {
        try context.save()
    }
    
    func deleteTransaction(_ transaction: Transaction, context: ModelContext) throws {
        context.delete(transaction)
        try context.save()
    }
}
