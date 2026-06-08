//
//  PayeeRepository.swift
//  Ease
//
//  Created by Dorcas Shee on 1/5/26.
//

import Foundation
import SwiftData

protocol PayeeRepository {
    func getOrCreatePayee(name: String, context: ModelContext) -> Payee
    func deletePayeeIfOrphaned(id: PersistentIdentifier, context: ModelContext)
}
