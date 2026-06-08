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
                           desc: String?,
                           payee: Payee?,
                           date: Date,
                           isRecurring: Bool,
                           context: ModelContext) throws
        
    func saveTransaction(context: ModelContext) throws
    
    func deleteTransaction(_ transaction: Transaction, context: ModelContext) throws
}
