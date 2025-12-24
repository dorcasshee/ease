//
//  RecordExpenseView.swift
//  Ease
//
//  Created by Dorcas Shee on 10/12/25.
//

import SwiftUI
import SwiftData

struct RecordExpenseView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @Query private var categories: [TransactionCategory]
    
    @State private var transactionVM = TransactionViewModel()
    @State private var categoryVM = CategoryViewModel()
    
    var body: some View {
        VStack {
            DismissButton()
            
            Text("New Transaction")
                .font(.headline).fontWeight(.regular)
            
            TextField("$0.00", value: $transactionVM.amount, format: .currency(code: "SGD")) // allow currency to change
                .font(.system(size: 50, weight: .bold))
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.center)
                .padding()
            
            Picker("Select transaction type", selection: $transactionVM.transactionType) { // expense, income, transfer, investment
                ForEach(TransactionType.allCases) { type in
                    Text(type.rawValue.capitalized)
                        .tag(type)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.bottom)
            .frame(width: 250)
            
            VStack(spacing: 20) {
                CustomDivider()
                
                Button {
                    transactionVM.showSheet = true
                } label: {
                    HStack {
                        Label("Category:", systemImage: "circle.grid.2x2")
                            .foregroundStyle(.eBlack)
                        
                        Label(transactionVM.category?.name ?? "", systemImage: transactionVM.category?.iconName ?? "")
                            .foregroundStyle(Color(hex: transactionVM.category?.colorHex ?? Strings.Colors.eBlack))
                        
                        Spacer()
                    }
                    .font(.headline)
                }
                .sheet(isPresented: $transactionVM.showSheet) {
                    CategorySheetView(transactionVM: transactionVM)
                }
                
                CustomDivider()
                
                HStack {
                    Label("Paid To:", systemImage: "person")
                        .font(.headline)
                        .foregroundStyle(.eBlack)
                    
                    TextField(text: $transactionVM.payeeName) {
                    }
                }
                
                CustomDivider()
                
                HStack {
                    Image(systemName: "line.3.horizontal")
                    
                    TextField("Description", text: $transactionVM.desc) {}
                        .font(.headline).fontWeight(.regular)
                }
                
                CustomDivider()
                
                DateRowView(transactionVM: transactionVM)
                
                CustomDivider()
            }
            .padding(.top, 10)
            .padding(.bottom, 25)
            
            Button {
                // dismiss sheet
                transactionVM.createTransaction(context: context)
                dismiss()
            } label: {
                BlackButtonView(text: "Save", horizontalPadding: 80)
                    
            }
            .padding(.bottom, 5)
            
            Button {
                transactionVM.createTransaction(context: context)
            } label: {
                BlackButtonView(text: "Save & Add Another", horizontalPadding: 20)
            }
            
            Spacer()
        }
        .padding(.horizontal, 30)
        .padding(.vertical)
        .alert(transactionVM.valError?.errorTitle ?? "Error", isPresented: $transactionVM.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(transactionVM.valError?.errorMessage ?? "An unexpected error has occurred. Please try again.")
        }
        .onAppear {
            if transactionVM.category == nil {
                transactionVM.category = try? categoryVM.getDefaultCategory(for: transactionVM.transactionType, context: context)
            }
        }
        .onChange(of: transactionVM.transactionType) { _, newValue in
            transactionVM.category = try? categoryVM.getDefaultCategory(for: newValue, context: context)
        }
    }
}

struct CustomDivider: View {
    var body: some View {
        Divider()
            .opacity(0.75)
    }
}

struct DismissButton: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        HStack {
            Spacer()
            
            Button {
                dismiss()
            } label: {
                Image(systemName: "x.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(Color(.systemGray2), Color(.secondarySystemBackground))
                    .frame(width: 32)
            }
        }
    }
}

struct BlackButtonView: View {
    let text: String
    let horizontalPadding: CGFloat
    
    var body: some View {
        Text(text)
            .font(.headline)
            .foregroundStyle(.white)
            .padding(.vertical, 10)
            .padding(.horizontal, horizontalPadding)
            .background {
                Capsule()
                    .foregroundStyle(.black)
            }
    }
}

struct DateRowView: View {
    @Bindable var transactionVM: TransactionViewModel
    
    var body: some View {
        HStack {
            Image(systemName: "calendar")
            
            ZStack {
                DatePicker("", selection: $transactionVM.date, displayedComponents: .date)
                    .labelsHidden()
                    .blendMode(.destinationOver)
                
                Text(transactionVM.date, format: .dateTime.weekday(.wide).day().month(.wide))
                    .font(.headline).fontWeight(.regular)
                    .allowsHitTesting(false)
            }
            
            Spacer()
            
            Button {
                transactionVM.decrementDate()
            } label: {
                Image(systemName: "chevron.left")
                    .foregroundStyle(.eBlack)
            }
            .padding(.trailing)
            
            Button {
                transactionVM.incrementDate()
            } label: {
                Image(systemName: "chevron.right")
                    .foregroundStyle(.eBlack)
            }
        }
    }
}

#Preview {
    RecordExpenseView()
        .modelContainer(.preview)
}
