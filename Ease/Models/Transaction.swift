//
//  Transaction.swift
//  Ease
//
//  Created by Dorcas Shee on 3/12/25.
//

import Foundation
import SwiftData

@Model
final class Transaction {
    var amount: Double
    var desc: String?
    var date: Date
    var createdAt: Date
    var isRecurring: Bool
    var needsReview: Bool = false
    // Optional, not TransactionType — SwiftData's lightweight migration can't safely
    // backfill a non-optional custom Codable enum onto rows that predate this field;
    // it leaves the column empty and force-casting it crashes on read. Optional lets
    // migration add the column safely (missing = nil); DataSeeder.migrateV4ToV5
    // backfills real values, and the fallback below covers any row it hasn't reached yet.
    var transactionType: TransactionType?

    var effectiveTransactionType: TransactionType {
        transactionType ?? category.transactionType
    }

    var formattedAmount: String {
        let sign = effectiveTransactionType == .expense ? "-" : ""
        let formatted = amount.formatAsCurrency()

        return sign + formatted
    }

    @Relationship var category: SubCategory
    @Relationship var payee: Payee?

    init(amount: Double, category: SubCategory, transactionType: TransactionType, desc: String?, payee: Payee?, date: Date, isRecurring: Bool = false, needsReview: Bool = false) {
        self.amount = amount
        self.category = category
        self.transactionType = transactionType
        self.desc = desc
        self.payee = payee
        self.date = date
        self.createdAt = Date()
        self.isRecurring = isRecurring
        self.needsReview = needsReview
    }
}

struct TransactionSection: Identifiable {
    var id = UUID()
    var date: Date
    var transactions: [Transaction]

    var totalAmount: Double {
        transactions.reduce(0) { $0 + ($1.effectiveTransactionType == .expense ? -$1.amount : $1.amount) }
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
