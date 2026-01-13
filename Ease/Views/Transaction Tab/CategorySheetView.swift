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
    @Query private var categories: [TransactionCategory]
    
    @State private var categoryVM = CategoryViewModel()
    var transactionVM: TransactionViewModel
    
    var body: some View {
        VStack {
            DismissButton()
            
            HStack {
                Text("Categories")
                    .font(.title.bold())
                Spacer()
            }
            
            // TODO: search bar
            
            ScrollView {
                LazyVStack(pinnedViews: [.sectionHeaders]){
                    ForEach(categoryVM.getParentCategories(categories: categories, transactionType: transactionVM.transactionType)) { parent in
                        Section {
                            SubCategoryGridView(categoryVM: categoryVM, transactionVM: transactionVM, parent: parent)
                        } header: {
                            CategoryHeaderView(name: parent.name, iconName: parent.iconName, count: parent.subCategories.count)
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
    var parent: TransactionCategory
    
    let columns: [GridItem] = Array(repeating: GridItem(.flexible()), count: 4)
    
    var body: some View {
        LazyVGrid(columns: columns) {
            ForEach(categoryVM.sortedSubCategories(cat: parent.subCategories)) { cat in
                Button {
                    buttonTapCount += 1
                    transactionVM.selectedCategories[transactionVM.transactionType] = cat
                    dismiss()
                } label: {
                    CategoryButtonView(categoryName: cat.name, imageName: cat.iconName, color: cat.transactionType.color)
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
    
    var body: some View {
        VStack {
            HStack(alignment: .top) {
                Label(name, systemImage: iconName)
                    .font(.title3)
                    .fontWeight(.bold)
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
    let color: Color
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            CategoryIconView(imageName: imageName, color: color)
            
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
    
    var body: some View {
        ZStack(alignment: .center) {
            Circle()
                .frame(width: 50, height: 50)
                .foregroundStyle(color)
            
            Image(systemName: imageName)
                .font(.title3.bold())
                .foregroundStyle(.white)
        }
    }
}
