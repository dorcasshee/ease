//
//  TransactionViewModel.swift
//  Ease
//
//  Created by Dorcas Shee on 6/12/25.
//

import Foundation
import SwiftData

@Observable
class TransactionViewModel {
    /*
    This view model contains the following logic for transaction CRUD operations.
    */
    
    private var context: ModelContext
    private var payeeViewModel: PayeeViewModel
    
    init(context: ModelContext) {
        self.context = context
        self.payeeViewModel = PayeeViewModel(context: context)
    }
    
    func createTransaction(amount: Double, category: TransactionCategory, desc: String?, payeeName: String, date: Date, isRecurring: Bool) {
        
        let payee = payeeViewModel.getOrCreatePayee(name: payeeName)
        
        let newTransaction = Transaction(amount: amount, category: category, desc: desc ?? String(), payee: payee, date: date, isRecurring: isRecurring)
        
        context.insert(newTransaction)
    }
    
    func updateTransaction() {
        
    }
    
    func deleteTransaction(item: Transaction) {
        context.delete(item)
    }
}
