//
//  SaveButtonsView.swift
//  Ease
//
//  Created by Dorcas Shee on 14/1/26.
//

import SwiftUI

struct SaveButtonsView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var transactionVM: TransactionViewModel
    @Bindable var categoryVM: CategoryViewModel
    
    @State private var buttonTapCount: Int = 0
    @FocusState.Binding var focusedField: RecordExpenseView.FocusField?
    
    var body: some View {
        VStack(spacing: 10) {
            Button {
                buttonTapCount += 1
                if transactionVM.saveTransaction(context: context) {
                    dismiss()
                }
            } label: {
                Text("Save")
                    .frame(maxWidth: .infinity)
                    .roundButtonStyle(color: .eBlack)
            }
            
            Button {
                buttonTapCount += 1
                if transactionVM.saveAndResetForAnother(context: context, categoryVM: categoryVM) {
                    focusedField = .amount
                }
            } label: {
                Text("Save & Add Another")
                    .frame(maxWidth: .infinity)
                    .roundButtonStyle(color: .eBlack)
            }
            
            if transactionVM.trsnMode == .update, let trsnToEdit = transactionVM.trsnToEdit {
                Button {
                    buttonTapCount += 1
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
        .sensoryFeedback(.selection, trigger: buttonTapCount)
    }
}
