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
    
    @State private var categoryVM = CategoryViewModel()
    @Bindable var transactionVM: TransactionViewModel
    
    @FocusState private var focusedField: FocusField?
    
    enum FocusField: Hashable {
        case amount, payee, desc
    }
    
    private var fieldOffset: CGFloat {
        if focusedField == .payee { return -100 }
        if focusedField == .desc { return -150 }
        return 0
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    DismissButton()
                    
                    Text("New Transaction")
                        .font(.headline).fontWeight(.regular)
                    
                    TextField("$0.00", value: $transactionVM.amount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                        .focused($focusedField, equals: .amount)
                        .font(.system(size: 50, weight: .bold))
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.center)
                        .padding()
                        .submitLabel(.done)
                        .toolbar {
                            if focusedField == .amount {
                                ToolbarItemGroup(placement: .keyboard) {
                                    Spacer()
                                    Button("Done") {
                                        focusedField = nil
                                    }
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.eBlack)
                                }
                            }
                        }
                    
                    Picker("Select transaction type", selection: $transactionVM.transactionType) { // expense, income, transfer, investment
                        ForEach(TransactionType.allCases) { type in
                            Text(type.rawValue.capitalized)
                                .tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    .tint(Color(.secondarySystemBackground))
                    .padding(.horizontal)
                    .padding(.bottom)
                    .frame(width: 250)
                            
                    RecordExpenseBodyView(categoryVM: categoryVM, transactionVM: transactionVM, focusedField: $focusedField)
                    
                    Spacer()
                }
                .offset(y: fieldOffset)
                .animation(.easeInOut(duration: 0.3), value: focusedField)
            }
            .scrollDisabled(true)
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)
        }
        .padding(.top)
        .padding(.horizontal)
        .ignoresSafeArea(.keyboard)
        .dismissKeyboardOnTap()
        .alert(transactionVM.valError?.errorTitle ?? "Error", isPresented: $transactionVM.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(transactionVM.valError?.errorMessage ?? "An unexpected error has occurred. Please try again.")
        }
        .onAppear {
            focusedField = .amount
            
            if transactionVM.category == nil {
                transactionVM.selectedCategories[transactionVM.transactionType] = try? categoryVM.getDefaultCategory(for: transactionVM.transactionType, context: context)
            }
        }
        .onChange(of: transactionVM.transactionType) { _, newValue in
            if transactionVM.selectedCategories[newValue] == nil {
                transactionVM.selectedCategories[newValue] = try? categoryVM.getDefaultCategory(for: newValue, context: context)
            }
        }
        .onDisappear {
            transactionVM.resetForm()
        }
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

struct BlackButtonStyle: ViewModifier {
    let font: Font
    
    func body(content: Content) -> some View {
        content
            .font(font)
            .foregroundStyle(.eWhite)
            .padding(.vertical, 10)
            .padding(.horizontal)
            .background {
                Capsule()
                    .foregroundStyle(.eBlack)
            }
    }
}

extension View {
    func blackButtonStyle(horizontalPadding: CGFloat = 20, font: Font = .headline) -> some View {
        modifier(BlackButtonStyle(font: font))
    }
    
    func dismissKeyboardOnTap() -> some View {
        self
            .contentShape(Rectangle())
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
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

#Preview {
    RecordExpenseView(transactionVM: TransactionViewModel())
        .modelContainer(.preview)
}
