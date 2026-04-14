//
//  CategorySheetView.swift
//  Ease
//
//  Created by Dorcas Shee on 23/12/25.
//

import SwiftUI
import SwiftData

struct CategorySheetView: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var parents: [ParentCategory]
    
    @State private var categoryVM = CategoryViewModel()
    var transactionVM: TransactionViewModel
    
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
            }
            
            // TODO: search bar
            
            ScrollView {
                LazyVStack(pinnedViews: [.sectionHeaders]){
                    ForEach(categoryVM.sortParentCategories(parents: parents, type: transactionVM.transactionType)) { parent in
                        Section {
                            SubCategoryGridView(categoryVM: categoryVM, transactionVM: transactionVM, parent: parent)
                        } header: {
                            CategoryHeaderView(name: parent.name, iconName: parent.iconName, count: parent.subCategories.count, isSystemIcon: parent.isSystemIcon)
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
    let name: String
    let iconName: String
    let count: Int
    let isSystemIcon: Bool
    
    var body: some View {
        VStack {
            HStack(alignment: .top) {
                Label {
                    Text(name)
                        .font(.title3)
                        .fontWeight(.bold)
                } icon: {
                    if isSystemIcon {
                        Image(systemName: iconName)
                    } else {
                        Image(iconName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 36, height: 36)
                    }
                }
                .foregroundStyle(.eBlack)
                
                Spacer()
                
                CounterView(count: "\(count)")
            }
            
            CustomDivider()
                .padding(.bottom, 10)
        }
        .background(.eWhite)
    }
}

struct CounterView: View {
    var count: String
    
    var body: some View {
        ZStack(alignment: .center) {
            Image(systemName: "square")
                .font(.title)
            
            Text(count)
                .font(.body)
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
                Image(systemName: imageName)
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
