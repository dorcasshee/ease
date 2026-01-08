//
//  RecordExpenseBodyView.swift
//  Ease
//
//  Created by Dorcas Shee on 9/1/26.
//

import SwiftUI
import SwiftData

struct RecordExpenseBodyView: View {
    @Environment(\.modelContext) private var context
    
    @Bindable var categoryVM: CategoryViewModel
    @Bindable var transactionVM: TransactionViewModel
    
    @Query private var transactions: [Transaction]
    @Query private var payees: [Payee]
    
    var focusedField: FocusState<RecordExpenseView.FocusField?>.Binding
    
    var body: some View {
        VStack(spacing: 20) {
            CustomDivider()
            
            Button {
                categoryVM.showSheet = true
            } label: {
                HStack {
                    Label("Category:", systemImage: "circle.grid.2x2")
                        .foregroundStyle(.eBlack)
                    
                    Label(transactionVM.category?.name ?? "", systemImage: transactionVM.category?.iconName ?? "")
                        .foregroundStyle(transactionVM.transactionType.color)
                    
                    Spacer()
                }
                .font(.headline)
            }
            .sheet(isPresented: $categoryVM.showSheet) {
                CategorySheetView(transactionVM: transactionVM)
            }
            
            CustomDivider()
            
            HStack {
                Label(transactionVM.category?.transactionType == .expense ? "Paid To:" : "Received From:", systemImage: "person")
                    .font(.headline)
                    .foregroundStyle(.eBlack)
                
                TextField("Entity", text: $transactionVM.payeeName)
                    .focused(focusedField, equals: .payee)
                    .autocorrectionDisabled(false)
                    .submitLabel(.done)
                    .font(.headline).fontWeight(.regular)
                    .onChange(of: transactionVM.payeeName) { _, newValue in
                        transactionVM.payeeSuggestions = transactionVM.getAutocompleteSuggestions(for: newValue, from: payees.compactMap { $0.name })
                    }
            }
            
            CustomDivider()
            
            HStack {
                Image(systemName: "line.3.horizontal")
                
                TextField("Description", text: $transactionVM.desc)
                    .focused(focusedField, equals: .desc)
                    .autocorrectionDisabled(false)
                    .submitLabel(.done)
                    .font(.headline).fontWeight(.regular)
                    .onChange(of: transactionVM.desc) { _, newValue in
                        transactionVM.descSuggestions = transactionVM.getAutocompleteSuggestions(
                            for: newValue,
                            from: transactions
                                .compactMap { $0.category.transactionType == transactionVM.transactionType ? $0.desc : nil })
                    }
            }
            
            CustomDivider()
            
            DateRowView(transactionVM: transactionVM)
            
            CustomDivider()
                .padding(.bottom, 15)
            
            SaveButtonsView(transactionVM: transactionVM, categoryVM: categoryVM)
        }
        .padding(.top, 10)
        .padding(.bottom, 25)
        .padding(.horizontal, 10)
        .overlay(alignment: .top) {
            if focusedField.wrappedValue == .payee && !transactionVM.payeeSuggestions.isEmpty {
                VStack {
                    ForEach(transactionVM.payeeSuggestions, id: \.self) { name in
                        Button {
                            transactionVM.payeeName = name
                            transactionVM.isSuggestionSelected = true
                            transactionVM.payeeSuggestions = []
                        } label: {
                            AutocompleteRowView(text: name)
                        }
                        
                        if name != transactionVM.payeeSuggestions.last {
                            CustomDivider()
                                .padding(.vertical, 5)
                        }
                    }
                }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundStyle(Color(.secondarySystemBackground))
                        .shadow(color: .eBlack.opacity(0.1), radius: 5, x: 5, y: 5)
                }
                .frame(maxWidth: .infinity)
                .offset(y: 141)
            }
            
            if focusedField.wrappedValue == .desc && !transactionVM.descSuggestions.isEmpty {
                VStack {
                    ForEach(transactionVM.descSuggestions, id: \.self) { desc in
                        Button {
                            transactionVM.desc = desc
                            transactionVM.isSuggestionSelected = true
                            transactionVM.descSuggestions = []
                        } label: {
                            AutocompleteRowView(text: desc)
                        }
                        
                        if desc != transactionVM.descSuggestions.last {
                            CustomDivider()
                                .padding(.vertical, 5)
                        }
                    }
                }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundStyle(Color(.secondarySystemBackground))
                        .shadow(color: .eBlack.opacity(0.1), radius: 5, x: 5, y: 5)
                }
                .frame(maxWidth: .infinity)
                .offset(y: 203)
            }
        }
    }
}

struct SaveButtonsView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var transactionVM: TransactionViewModel
    @Bindable var categoryVM: CategoryViewModel
    
    var body: some View {
        VStack {
            Button {
                if transactionVM.saveTransaction(context: context) {
                    dismiss()
                }
            } label: {
                Text("Save")
                    .frame(maxWidth: .infinity)
                    .blackButtonStyle()
            }
            .padding(.bottom, 5)
            
            Button {
                if transactionVM.saveTransaction(context: context) {
                    transactionVM.resetForm()
                    transactionVM.selectedCategories[transactionVM.transactionType] = try? categoryVM.getDefaultCategory(for: transactionVM.transactionType, context: context)
                }
            } label: {
                Text("Save & Add Another")
                    .frame(maxWidth: .infinity)
                    .blackButtonStyle()
            }
        }
        .fixedSize(horizontal: true, vertical: false)
    }
}

struct CustomDivider: View {
    var body: some View {
        Divider()
            .opacity(0.8)
    }
}
