//
//  Transaction.swift
//  Ease
//
//  Created by Dorcas Shee on 3/12/25.
//

import Foundation
import SwiftData

@Model
class Transaction {
    var amount: Double
    var desc: String?
    var date: Date
    var isRecurring: Bool
    
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = Locale.current.currency?.identifier ?? "USD"

        let sign = category.transactionType == .expense ? "-" : "+"
        let formatted = formatter.string(from: NSNumber(value: amount)) ?? "$0.00"

        return sign + formatted
    }
    
    @Relationship var category: TransactionCategory
    @Relationship var payee: Payee?
    
    init(amount: Double, category: TransactionCategory, desc: String?, payee: Payee?, date: Date, isRecurring: Bool = false) {
        self.amount = amount
        self.category = category
        self.desc = desc
        self.payee = payee
        self.date = date
        self.isRecurring = isRecurring
    }
}
