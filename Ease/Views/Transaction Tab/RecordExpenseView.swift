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
            
            Text("new transaction")
                .font(.subheadline)
            
            TextField("0.00", value: $transactionVM.amount, format: .currency(code: "SGD")) // allow currency to change
                .font(.system(size: 50, weight: .bold))
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.center)
                .padding()
            
            Picker("", selection: $transactionVM.category) {
                ForEach(TransactionType.allCases) { type in
                    Text(type.rawValue.capitalized)
                        .tag(type)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.bottom)
            
            
            
            Button {
                // dismiss sheet
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
