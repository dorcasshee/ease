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
    var category: TransactionCategory? // amend later
    var desc: String?
    var payeeName: String = String()
    var isRecurring: Bool = false
    
    init() {
        self.payeeViewModel = PayeeViewModel()
        self.date = Date()
    }
    
    func createTransaction(context: ModelContext) {
        
        let payee = payeeViewModel.getOrCreatePayee(context: context, name: payeeName)
        
        let newTransaction = Transaction(amount: amount,
                                         category: category ?? TransactionCategory(name: "", iconName: "", colorHex: "", isDefault: false),
                                         desc: desc ?? String(),
                                         payee: payee,
                                         date: date,
                                         isRecurring: isRecurring)
        
        context.insert(newTransaction)
    }
    
    func updateTransaction(context: ModelContext, item: Transaction) {
        try? context.save()
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
