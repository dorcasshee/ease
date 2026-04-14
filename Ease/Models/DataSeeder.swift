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
    func seedDefaultCategories() throws {
        // check if category already seeded
        let isSeeded = UserDefaults.standard.bool(forKey: "HasInitialSeed")
        guard !isSeeded else { return }
        
        // load and decode JSON
        guard let url = Bundle.main.url(forResource: "DefaultCategories", withExtension: "json"),
              let data = try? Data(contentsOf: url) else { return }
        
        let dataObjects = try JSONDecoder().decode([ParentCategoryDTO].self, from: data)
        
        // batch convert data objects into Model objects
        for dataObject in dataObjects {
            let parent = ParentCategory(name: dataObject.name,
                                        iconName: dataObject.iconName,
                                        isSystemIcon: dataObject.isSystemIcon,
                                        colorName: dataObject.colorName,
                                        transactionType: dataObject.transactionType)
            
            modelContext.insert(parent)
            
            for subDataObject in dataObject.subCategories {
                let sub = SubCategory(name: subDataObject.name,
                                      iconName: subDataObject.iconName,
                                      isSystemIcon: subDataObject.isSystemIcon,
                                      isDefault: subDataObject.isDefault,
                                      colorName: dataObject.colorName,
                                      parent: parent)
                
                modelContext.insert(sub)
            }
        }
        
        // batch save
        try modelContext.save()
        
        UserDefaults.standard.set(true, forKey: "HasInitialSeed")
    }
}
