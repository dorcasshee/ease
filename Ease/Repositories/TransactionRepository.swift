//
//  TransactionRepository.swift
//  Ease
//
//  Created by Dorcas Shee on 1/5/26.
//

import Foundation
import SwiftData

protocol TransactionRepository {
    func createTransaction(amount: Double,
                           category: SubCategory,
                           transactionType: TransactionType,
                           desc: String?,
                           payee: Payee?,
                           date: Date,
                           isRecurring: Bool,
                           needsReview: Bool,
                           context: ModelContext) throws

    func saveTransaction(context: ModelContext) throws

    func deleteTransaction(_ transaction: Transaction, context: ModelContext) throws
}

extension TransactionRepository {
    // convenience overload for callers that don't care about needsReview (defaults to false)
    func createTransaction(amount: Double,
                           category: SubCategory,
                           transactionType: TransactionType,
                           desc: String?,
                           payee: Payee?,
                           date: Date,
                           isRecurring: Bool,
                           context: ModelContext) throws {
        try createTransaction(amount: amount, category: category, transactionType: transactionType, desc: desc, payee: payee, date: date, isRecurring: isRecurring, needsReview: false, context: context)
    }
}
