//
//  DataSeeder.swift
//  Ease
//
//  Created by Dorcas Shee on 11/2/26.
//

import Foundation
import SwiftData

@ModelActor
actor DataSeeder {
    private let seedVersionKey = "CategorySeedVersion"
    private let latestCategorySeedVersion = 4

    func seedDefaultCategories() throws {
        var currentVersion = UserDefaults.standard.integer(forKey: seedVersionKey)

        if try !hasAnyCategories() {
            try seedFromDefaultCategoriesJSON()
            currentVersion = 1
            UserDefaults.standard.set(currentVersion, forKey: seedVersionKey)
        }

        var version = currentVersion
        while version < latestCategorySeedVersion {
            switch version {
            case 0:
                try migrateV0ToV1()
            case 1:
                try migrateV1ToV2()
            case 2:
                try migrateV2ToV3()
            case 3:
                try migrateV3ToV4()
            default:
                return
            }

            version += 1
            UserDefaults.standard.set(version, forKey: seedVersionKey)
        }
    }

    private func seedFromDefaultCategoriesJSON() throws {
        let dataObjects = try loadDefaultCategoryData()

        for dataObject in dataObjects {
            let parent = ParentCategory(id: dataObject.id,
                                        name: dataObject.name,
                                        iconName: dataObject.iconName,
                                        isSystemIcon: dataObject.isSystemIcon,
                                        colorName: dataObject.colorName,
                                        transactionType: dataObject.transactionType)
            modelContext.insert(parent)

            for subDataObject in dataObject.subCategories {
                let sub = SubCategory(id: subDataObject.id,
                                      name: subDataObject.name,
                                      iconName: subDataObject.iconName,
                                      isSystemIcon: subDataObject.isSystemIcon,
                                      isDefault: subDataObject.isDefault,
                                      colorName: dataObject.colorName,
                                      parent: parent)
                modelContext.insert(sub)
            }
        }

        try modelContext.save()
    }

    private func migrateV3ToV4() throws {
        // Renames the expense "Uncategorized" sentinel to "Uncategorised" (spelling
        // consistency with the income sentinel added below), and adds the income
        // equivalent — categories are partitioned by transactionType, so
        // "Uncategorized" only ever existed for expense; LogIncomeIntent needs its
        // own type-specific sentinel to default hands-free income transactions to.
        let expenseUncategorizedID = "pcat.expense.uncategorized"
        let expenseUncategorizedSubID = "scat.expense.uncategorized.uncategorized"

        let parentDescriptor = FetchDescriptor<ParentCategory>(predicate: #Predicate { $0.id == expenseUncategorizedID })
        if let expenseParent = try modelContext.fetch(parentDescriptor).first {
            expenseParent.name = "Uncategorised"
        }

        let subDescriptor = FetchDescriptor<SubCategory>(predicate: #Predicate { $0.id == expenseUncategorizedSubID })
        if let expenseSub = try modelContext.fetch(subDescriptor).first {
            expenseSub.name = "Uncategorised"
        }

        let incomeUncategorizedID = "pcat.income.uncategorized"
        let incomeDescriptor = FetchDescriptor<ParentCategory>(predicate: #Predicate { $0.id == incomeUncategorizedID })
        guard try modelContext.fetchCount(incomeDescriptor) == 0 else { return }

        let incomeParent = ParentCategory(id: incomeUncategorizedID,
                                           name: "Uncategorised",
                                           iconName: "questionmark.circle",
                                           isSystemIcon: true,
                                           colorName: "eBlack",
                                           transactionType: .income)
        modelContext.insert(incomeParent)

        let incomeSub = SubCategory(id: "scat.income.uncategorized.uncategorized",
                                     name: "Uncategorised",
                                     iconName: "questionmark.circle",
                                     isSystemIcon: true,
                                     isDefault: false,
                                     colorName: "eBlack",
                                     parent: incomeParent)
        modelContext.insert(incomeSub)

        try modelContext.save()
    }

    private func migrateV1ToV2() throws {
        // Convert known iOS 26-only SF Symbols to asset-backed icons for iOS 18 compatibility.
        let parentDescriptor = FetchDescriptor<ParentCategory>()
        let parents = try modelContext.fetch(parentDescriptor)
        for parent in parents where parent.id == "pcat.expense.travel" {
            parent.isSystemIcon = false
        }

        let subDescriptor = FetchDescriptor<SubCategory>()
        let subCategories = try modelContext.fetch(subDescriptor)
        for sub in subCategories {
            switch sub.id {
            case "scat.expense.travel.flights", "scat.expense.tech.tech_accessories":
                sub.isSystemIcon = false
            default:
                continue
            }
        }

        try modelContext.save()
    }

    private func migrateV2ToV3() throws {
        // Adds the "Uncategorized" catch-all category, used for transactions
        // logged hands-free (e.g. via the Shortcuts/Apple Wallet intent) that need review.
        let uncategorizedID = "pcat.expense.uncategorized"
        let descriptor = FetchDescriptor<ParentCategory>(predicate: #Predicate { $0.id == uncategorizedID })
        guard try modelContext.fetchCount(descriptor) == 0 else { return }

        let parent = ParentCategory(id: uncategorizedID,
                                    name: "Uncategorized",
                                    iconName: "questionmark.circle",
                                    isSystemIcon: true,
                                    colorName: "eBlack",
                                    transactionType: .expense)
        modelContext.insert(parent)

        let sub = SubCategory(id: "scat.expense.uncategorized.uncategorized",
                              name: "Uncategorized",
                              iconName: "questionmark.circle",
                              isSystemIcon: true,
                              isDefault: false,
                              colorName: "eBlack",
                              parent: parent)
        modelContext.insert(sub)

        try modelContext.save()
    }

    private func migrateV0ToV1() throws {
        let descriptor = FetchDescriptor<ParentCategory>()
        let parents = try modelContext.fetch(descriptor)

        for parent in parents {
            if parent.id.isEmpty {
                parent.id = deterministicParentID(type: parent.transactionType, parentName: parent.name)
            }

            let parentSlug = slugify(parent.name)
            for sub in parent.subCategories {
                if sub.id.isEmpty {
                    sub.id = deterministicSubID(type: sub.transactionType, parentSlug: parentSlug, subName: sub.name)
                }
            }
        }

        try modelContext.save()
    }

    private func hasAnyCategories() throws -> Bool {
        let descriptor = FetchDescriptor<ParentCategory>()
        return try modelContext.fetchCount(descriptor) > 0
    }

    private func loadDefaultCategoryData() throws -> [ParentCategoryDTO] {
        guard let url = Bundle.main.url(forResource: "DefaultCategories", withExtension: "json") else {
            return []
        }

        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([ParentCategoryDTO].self, from: data)
    }

    private func deterministicParentID(type: TransactionType, parentName: String) -> String {
        "pcat.\(type.rawValue).\(slugify(parentName))"
    }

    private func deterministicSubID(type: TransactionType, parentSlug: String, subName: String) -> String {
        "scat.\(type.rawValue).\(parentSlug).\(slugify(subName))"
    }

    // normalises names to ensure IDs are safe and consistent.
    private func slugify(_ value: String) -> String {
        let lowercased = value.lowercased()
        let allowed = CharacterSet.alphanumerics
        let scalars = lowercased.unicodeScalars.map { scalar in
            allowed.contains(scalar) ? Character(scalar) : "_"
        }
        let raw = String(scalars)

        return raw
            .replacingOccurrences(of: "_+", with: "_", options: .regularExpression)
            .trimmingCharacters(in: CharacterSet(charactersIn: "_"))
    }
}

#if DEBUG
enum SeedDebug {
    static func resetCategorySeedVersion(to version: Int = 0) {
        UserDefaults.standard.set(version, forKey: "CategorySeedVersion")
    }
}
#endif
