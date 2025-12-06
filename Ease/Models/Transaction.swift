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
    @Relationship var category: TransactionCategory
    @Relationship var payee: Payee?
    
    init(amount: Double, category: TransactionCategory, desc: String?, payee: Payee, date: Date, isRecurring: Bool) {
        self.amount = amount
        self.category = category
        self.desc = desc
        self.payee = payee
        self.date = date
        self.isRecurring = isRecurring
    }
}
