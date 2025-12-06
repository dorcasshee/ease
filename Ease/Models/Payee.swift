//
//  Payee.swift
//  Ease
//
//  Created by Dorcas Shee on 6/12/25.
//

import Foundation
import SwiftData

@Model
class Payee {
    @Attribute(.unique) var name: String
    @Relationship(deleteRule: .nullify, inverse: \Transaction.payee) var transactions: [Transaction] = []
    
    init(name: String) {
        self.name = name
    }
}
