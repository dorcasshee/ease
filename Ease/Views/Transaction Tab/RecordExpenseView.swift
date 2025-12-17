//
//  RecordExpenseView.swift
//  Ease
//
//  Created by Dorcas Shee on 10/12/25.
//

import SwiftUI

struct RecordExpenseView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @State private var transactionVM = TransactionViewModel()
    
    var body: some View {
        VStack {
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
                        .padding(.trailing)
                        
                }
            }
            
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
            
            
            
            
            Button {
                // dismiss sheet
                transactionVM.createTransaction(context: context)
                dismiss()
            } label: {
                Text("Save")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 76)
                    .background {
                        Capsule()
                            .foregroundStyle(.black)
                    }
                    
            }
            
            Button {
                // Create another transaction
            } label: {
                Text("Save & Add Another")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.vertical, 10)
                    .padding(.horizontal)
                    .background {
                        Capsule()
                            .foregroundStyle(.black)
                    }
                    
            }
            
            Spacer()
        }
        
    }
}

#Preview {
    RecordExpenseView()
}
