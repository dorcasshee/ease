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
    var createdAt: Date
    var isRecurring: Bool
    
    var formattedAmount: String {
        let sign = category.transactionType == .expense ? "-" : ""
        let formatted = amount.formatAsCurrency()

        return sign + formatted
    }
    
    @Relationship var category: Category
    @Relationship var payee: Payee?
    
    init(amount: Double, category: Category, desc: String?, payee: Payee?, date: Date, isRecurring: Bool = false) {
        self.amount = amount
        self.category = category
        self.desc = desc
        self.payee = payee
        self.date = date
        self.createdAt = Date()
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
}

extension Double {
    func formatAsCurrency() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = Locale.current.currency?.identifier ?? "USD"
    
        return formatter.string(from: NSNumber(value: self)) ?? "$0.00"
    }
}

extension Date {
    func formatRelativeDate() -> String {
        if Calendar.current.isDateInToday(self) {
            return "Today"
        } else if Calendar.current.isDateInYesterday(self) {
            return "Yesterday"
        }  else if Calendar.current.isDateInTomorrow(self){
            return "Tomorrow"
        } else {
            let formatter = DateFormatter()
            formatter.setLocalizedDateFormatFromTemplate("EEEEdMMMM")
            return formatter.string(from: self)
        }
    }
}
