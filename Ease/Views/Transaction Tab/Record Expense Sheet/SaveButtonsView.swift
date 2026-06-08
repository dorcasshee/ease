//
//  SaveButtonsView.swift
//  Ease
//
//  Created by Dorcas Shee on 14/1/26.
//

import SwiftUI
import SwiftData

struct SaveButtonsView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var transactionFormVM: TransactionFormViewModel
    @Bindable var categoryVM: CategoryViewModel
    
    @State private var buttonTapCount: Int = 0
    var focusedField: FocusState<RecordExpenseView.FocusField?>.Binding
    
    var body: some View {
        VStack(spacing: 10) {
            Button {
                buttonTapCount += 1
                if transactionFormVM.saveTransaction(context: context) {
                    dismiss()
                }
            } label: {
                Text("Save")
                    .frame(maxWidth: .infinity)
                    .roundButtonStyle(color: .eBlack)
            }
            
            Button {
                buttonTapCount += 1
                if transactionFormVM.saveAndResetForAnother(context: context, categoryVM: categoryVM) {
                    focusedField.wrappedValue = .amount
                }
            } label: {
                Text("Save & Add Another")
                    .frame(maxWidth: .infinity)
                    .roundButtonStyle(color: .eBlack)
            }
            
            if transactionFormVM.isEditing, let transactionToEdit = transactionFormVM.transactionToEdit {
                Button {
                    buttonTapCount += 1
                    dismiss()
                    transactionFormVM.deleteTransaction(context: context, item: transactionToEdit)
                } label: {
                    Text("Delete")
                        .frame(maxWidth: .infinity)
                        .roundButtonStyle(color: .eRed)
                }
            }
        }
        .fixedSize(horizontal: true, vertical: false)
        .sensoryFeedback(.selection, trigger: buttonTapCount)
    }
}
