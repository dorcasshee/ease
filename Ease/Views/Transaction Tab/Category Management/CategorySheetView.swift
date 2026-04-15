//
//  CategorySheetView.swift
//  Ease
//
//  Created by Dorcas Shee on 23/12/25.
//

import SwiftUI
import SwiftData
import OSLog
import UIKit

struct CategorySheetView: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var parents: [ParentCategory]
    
    @State private var categoryVM = CategoryViewModel()
    var transactionVM: TransactionViewModel
    
    private var sortedParents: [ParentCategory] {
        categoryVM.sortParentCategories(parents: parents, type: transactionVM.transactionType)
    }
    
    var body: some View {
        NavigationStack {
            DismissButton()
            
            HStack {
                Text("Categories")
                    .font(.title.bold())
                
                Spacer()
                
                Button {
                    
                } label: {
                    Image(systemName: "pencil")
                        .font(.title)
                        .foregroundStyle(.eBlack)
                }
                .padding(.trailing, 5)
                
                Button {
                    if categoryVM.isAllCollapsed(parentCount: sortedParents.count) {
                        categoryVM.collapsedSections.removeAll();
                    } else {
                        categoryVM.collapsedSections = Set(sortedParents.map(\.id))
                    }
                } label: {
                    Label("\(categoryVM.isAllCollapsed(parentCount: sortedParents.count) ? "Expand" : "Collapse") All", systemImage: categoryVM.isAllCollapsed(parentCount: sortedParents.count) ? "plus" : "minus" )
                        .foregroundStyle(.eIvory)
                        .font(.caption.bold())
                        .padding(.vertical, 5)
                        .padding(.horizontal, 10)
                        .background(.eBlack)
                        .clipShape(Capsule())
                }
            }
            
            // TODO: search bar
            
            ScrollView {
                LazyVStack(pinnedViews: [.sectionHeaders]){
                    ForEach(sortedParents) { parent in
                        Section {
                            if !categoryVM.collapsedSections.contains(parent.id) {
                                SubCategoryGridView(categoryVM: categoryVM, transactionVM: transactionVM, parent: parent)
                            }
                        } header: {
                            Button {
                                categoryVM.toggleSection(parentID: parent.id)
                            } label: {
                                CategoryHeaderView(categoryVM: categoryVM, name: parent.name, iconName: parent.iconName, count: parent.subCategories.count, isSystemIcon: parent.isSystemIcon, parentID: parent.id)
                            }
                        }
                        .padding(.bottom, 10)
                    }
                }
            }
            .scrollIndicators(.hidden)
            .scrollBounceBehavior(.basedOnSize)
        }
        .padding()
    }
}

#Preview {
    CategorySheetView(transactionVM: TransactionViewModel())
        .modelContainer(.preview)
}

struct SubCategoryGridView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var buttonTapCount: Int = 0
    
    var categoryVM: CategoryViewModel
    var transactionVM: TransactionViewModel
    var parent: ParentCategory
    
    let columns: [GridItem] = Array(repeating: GridItem(.flexible()), count: 4)
    
    var body: some View {
        LazyVGrid(columns: columns) {
            ForEach(categoryVM.sortedSubCategories(parent: parent)) { sub in
                Button {
                    buttonTapCount += 1
                    transactionVM.selectedCategories[transactionVM.transactionType] = sub
                    dismiss()
                } label: {
                    CategoryButtonView(categoryName: sub.name, imageName: sub.iconName, isSystemIcon: sub.isSystemIcon, color: Color(sub.colorName))
                        .padding(.bottom, 5)
                }
                .sensoryFeedback(.selection, trigger: buttonTapCount)
            }
        }
        .padding(.bottom)
    }
}


struct CategoryHeaderView: View {
    @Bindable var categoryVM: CategoryViewModel
    let name: String
    let iconName: String
    let count: Int
    let isSystemIcon: Bool
    let parentID: String
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                HStack {
                    Group {
                        if isSystemIcon {
                            Image(systemName: iconName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                        } else {
                            Image(iconName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                        }
                    }
                    .frame(width: 26, alignment: .center)
                    
                    Text(name)
                        .font(.title3)
                        .fontWeight(.bold)
                }
                .foregroundStyle(.eBlack)
                
                Spacer()
                
                CounterView(count: "\(count)")
                    .padding(.trailing, 5)
                
                Button {
                    categoryVM.toggleSection(parentID: parentID)
                } label: {
                    Image(systemName: "chevron.down")
                        .rotationEffect(.degrees(categoryVM.collapsedSections.contains(parentID) ? -90 : 0))
                        .foregroundStyle(.eBlack)
                }
            }
            .padding(.bottom, 10)
            
            CustomDivider()
                .padding(.bottom, 10)
        }
        .background(.background)
    }
}

struct CounterView: View {
    var count: String
    
    var body: some View {
        ZStack(alignment: .center) {
            Image(systemName: "square")
                .font(.title)
            
            Text(count)
                .font(.body.bold())
                .foregroundStyle(.eBlack)
        }
        .foregroundStyle(.eBlack)
    }
}

struct CategoryButtonView: View {
    let categoryName: String
    let imageName: String
    let isSystemIcon: Bool
    let color: Color

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            CategoryIconView(imageName: imageName, color: color, isSystemIcon: isSystemIcon)
            
            Text(categoryName)
                .font(.callout)
                .multilineTextAlignment(.center)
                .foregroundStyle(.eBlack)
            
            Spacer()
        }
    }
}

struct CategoryIconView: View {
    let imageName: String
    let color: Color
    var isSystemIcon: Bool
    
    var body: some View {
        ZStack(alignment: .center) {
            Circle()
                .frame(width: 50, height: 50)
                .foregroundStyle(color)
            
            if isSystemIcon {
                Image(systemName: SymbolNameResolver.resolve(imageName))
                    .font(.title3.bold())
                    .foregroundStyle(.white)
                    .fixedSize()
            } else {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                    .foregroundStyle(.white)
                    .fixedSize()
            }
            
        }
    }
}

// written by Cursor
enum SymbolNameResolver {
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "Ease", category: "Symbols")
    private static var missingSymbolsLogged: Set<String> = []

    static func resolve(_ symbolName: String) -> String {
        if UIImage(systemName: symbolName) != nil {
            return symbolName
        }

        let fallbackToken = symbolName.split(separator: ".").first.map(String.init)
        if let fallbackToken, UIImage(systemName: fallbackToken) != nil {
            logMissingSymbolOnce(symbolName, fallback: fallbackToken)
            return fallbackToken
        }

        logMissingSymbolOnce(symbolName, fallback: "questionmark.circle")
        return "questionmark.circle"
    }

    private static func logMissingSymbolOnce(_ symbolName: String, fallback: String) {
        #if DEBUG
        guard missingSymbolsLogged.insert(symbolName).inserted else { return }
        logger.warning("Missing symbol '\(symbolName, privacy: .public)'. Falling back to '\(fallback, privacy: .public)'.")
        #endif
    }
}
