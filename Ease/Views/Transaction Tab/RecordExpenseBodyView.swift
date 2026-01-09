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
    
    @FocusState.Binding var focusedField: RecordExpenseView.FocusField?
    
    var body: some View {
        VStack(spacing: 20) {
            CustomDivider()
            
            Button {
                categoryVM.showSheet = true
            } label: {
                HStack {
                    Label("Category:", systemImage: "circle.grid.2x2")
                        .foregroundStyle(.eBlack)
                    
                    Label(transactionVM.category?.name ?? "", systemImage: transactionVM.category?.iconName ?? "circle")
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
                    .focused($focusedField, equals: .payee)
                    .autocorrectionDisabled(false)
                    .submitLabel(.done)
                    .font(.headline).fontWeight(.regular)
                    .onChange(of: transactionVM.payeeName) { _, newValue in
                        transactionVM.payeeSuggestions = transactionVM.getAutocompleteSuggestions(for: newValue, from: payees.compactMap { $0.name })
                    }
            }
            
            CustomDivider()
                .anchorPreference(key: BoundsPreferenceKey.self, value: .bounds) { [.payee : $0] }
            
            HStack {
                Image(systemName: "line.3.horizontal")
                
                TextField("Description", text: $transactionVM.desc)
                    .focused($focusedField, equals: .desc)
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
                .anchorPreference(key: BoundsPreferenceKey.self, value: .bounds) { [.desc : $0] }
            
            DateRowView(transactionVM: transactionVM)
            
            CustomDivider()
                .padding(.bottom, 15)
            
            SaveButtonsView(transactionVM: transactionVM, categoryVM: categoryVM, focusedField: $focusedField)
        }
        .padding(.top, 10)
        .padding(.bottom, 25)
        .padding(.horizontal, 10)
    }
}

struct CustomDivider: View {
    var body: some View {
        Divider()
            .opacity(0.8)
    }
}

struct AutocompleteRowView: View {
    var text: String
    
    var body: some View {
        HStack {
            Text(text)
                .foregroundStyle(.eBlack)
                .font(.subheadline)
            
            Spacer()
        }
    }
}

struct SaveButtonsView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var transactionVM: TransactionViewModel
    @Bindable var categoryVM: CategoryViewModel
    
    @FocusState.Binding var focusedField: RecordExpenseView.FocusField?
    
    var body: some View {
        VStack(spacing: 10) {
            Button {
                if transactionVM.saveTransaction(context: context) {
                    dismiss()
                }
            } label: {
                Text("Save")
                    .frame(maxWidth: .infinity)
                    .roundButtonStyle(color: .eBlack)
            }
            
            Button {
                if transactionVM.saveTransaction(context: context) {
                    transactionVM.resetForm()
                    transactionVM.selectedCategories[transactionVM.transactionType] = try? categoryVM.getDefaultCategory(for: transactionVM.transactionType, context: context)
                    focusedField = .amount
                }
            } label: {
                Text("Save & Add Another")
                    .frame(maxWidth: .infinity)
                    .roundButtonStyle(color: .eBlack)
            }
            
            if transactionVM.trsnMode == .update, let trsnToEdit = transactionVM.trsnToEdit {
                Button {
                    dismiss()
                    transactionVM.deleteTransaction(context: context, item: trsnToEdit)
                } label: {
                    Text("Delete")
                        .frame(maxWidth: .infinity)
                        .roundButtonStyle(color: .eRed)
                }
            }
        }
        .fixedSize(horizontal: true, vertical: false)
    }
}
