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
    
    let columns: [GridItem] = Array(repeating: GridItem(.flexible()), count: 4)
    
    var body: some View {
        VStack {
            DismissButton()
            
            HStack {
                Text("Categories")
                    .font(.title.bold())
                Spacer()
            }
            
            // search bar
            
            ScrollView {
                ForEach(categoryVM.getParentCategories(categories: categories, transactionType: transactionVM.transactionType)) { parent in
                    Section {
                        LazyVGrid(columns: columns) {
                            ForEach(categoryVM.sortedSubCategories(cat: parent.subCategories)) { cat in
                                Button {
                                    transactionVM.category = cat
                                    dismiss()
                                } label: {
                                    CategoryButtonView(imageName: cat.iconName, categoryName: cat.name, hex: cat.colorHex)
                                        .padding(.bottom, 5)
                                }
                            }
                        }
                        .padding(.bottom)
                    } header: {
                        VStack {
                            HStack(alignment: .top) {
                                Label(parent.name, systemImage: parent.iconName)
                                    .font(.title3.bold())
                                    .foregroundStyle(.eBlack)
                                
                                Spacer()
                                
                                CounterView(count: "\(parent.subCategories.count)")
                            }
                            
                            Divider()
                        }
                    }
                    .padding(.bottom, 10)
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

extension Color {
    init(hex: String, opacity: Double = 1) {
        var rgb: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgb)
        
        self.init(.sRGB,
                  red: Double((rgb >> 16) & 0xff) / 255,
                  green: Double((rgb >> 8) & 0xff) / 255,
                  blue: Double((rgb >> 0) & 0xff) / 255,
                  opacity: opacity
        )
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
    }
}

struct CategoryButtonView: View {
    let imageName: String
    let categoryName: String
    let hex: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .foregroundStyle(Color(hex: hex))
            
            Text(categoryName)
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundStyle(.eBlack)
            
            Spacer()
        }
    }
}
