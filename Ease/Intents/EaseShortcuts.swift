//
//  EaseShortcuts.swift
//  Ease
//
//  Created by Dorcas Shee on 18/9/26.
//

import AppIntents

struct EaseShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: LogExpenseIntent(),
            phrases: ["Log a transaction in \(.applicationName)"],
            shortTitle: "Log A Transaction",
            systemImageName: "creditcard"
        )
    }
}
