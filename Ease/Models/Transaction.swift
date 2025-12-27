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
        let sign = category.transactionType == .expense ? "-" : ""
        let formatted = amount.formatAsCurrency()

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

struct TransactionSection: Identifiable {
    var id = UUID()
    var date: Date
    var transactions: [Transaction]
    
    var totalAmount: Double {
        transactions.reduce(0) { $0 + ($1.category.transactionType == .expense ? -$1.amount : $1.amount) }
    }
    
    var formattedTotal: String {
        return totalAmount.formatAsCurrency()
    }
    
    var formattedDate: String {
        if Calendar.current.isDateInToday(date) {
            return "Today"
        } else if Calendar.current.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.setLocalizedDateFormatFromTemplate("EEEEdMMMM")
            return formatter.string(from: date)
        }
    }
}

extension Double {
    func formatAsCurrency() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = Locale.current.currency?.identifier ?? "USD"
    
        return formatter.string(from: NSNumber(value: self)) ?? "$0.00"
    }
}
