//
//  EaseApp.swift
//  Ease
//
//  Created by Dorcas Shee on 1/11/25.
//

import SwiftUI
import SwiftData

@main
struct EaseApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Transaction.self, Payee.self, TransactionCategory.self])
    }
}
