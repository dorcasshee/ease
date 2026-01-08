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
    
    @FocusState private var isAmountFocused: Bool
    
    var body: some View {
        VStack {
            VStack {
                DismissButton()
                
                Text("New Transaction")
                    .font(.headline).fontWeight(.regular)
                
                TextField("$0.00", value: $transactionVM.amount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                    .font(.system(size: 50, weight: .bold))
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.center)
                    .padding()
                    .focused($isAmountFocused)
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            Button {
                                isAmountFocused = false
                            } label: {
                                Image(systemName: "checkmark.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .symbolRenderingMode(.palette)
                                    .foregroundStyle(Color(.systemGray2), Color(.secondarySystemBackground))
                                    .frame(width: 32)
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
                .padding(.horizontal)
                .padding(.bottom)
                .frame(width: 250)
            }
            		
            RecordExpenseBodyView(categoryVM: categoryVM, transactionVM: transactionVM)
            
            Spacer()
        }
        .padding()
        .dismissKeyboardOnTap()
        .alert(transactionVM.valError?.errorTitle ?? "Error", isPresented: $transactionVM.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(transactionVM.valError?.errorMessage ?? "An unexpected error has occurred. Please try again.")
        }
        .onAppear {
            isAmountFocused = true
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

struct CustomDivider: View {
    var body: some View {
        Divider()
            .opacity(0.8)
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

struct RecordExpenseBodyView: View {
    @Environment(\.modelContext) private var context
    
    @Bindable var categoryVM: CategoryViewModel
    @Bindable var transactionVM: TransactionViewModel
    
    @Query private var transactions: [Transaction]
    @Query private var payees: [Payee]
    
    @FocusState private var isPayeeInputActive: Bool
    @FocusState private var isDescInputActive: Bool
    
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
                    .focused($isPayeeInputActive)
                    .autocorrectionDisabled(false)
                    .font(.headline).fontWeight(.regular)
                    .onChange(of: transactionVM.payeeName) { _, newValue in
                        transactionVM.payeeSuggestions = transactionVM.getAutocompleteSuggestions(for: newValue, from: payees.compactMap { $0.name })
                    }
            }
            
            CustomDivider()
            
            HStack {
                Image(systemName: "line.3.horizontal")
                
                TextField("Description", text: $transactionVM.desc)
                    .focused($isDescInputActive)
                    .autocorrectionDisabled(false)
                    .font(.headline).fontWeight(.regular)
                    .onChange(of: transactionVM.desc) { _, newValue in
                        transactionVM.descSuggestions = transactionVM.getAutocompleteSuggestions(for: newValue, from: transactions.compactMap { $0.desc })
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
            if isPayeeInputActive && !transactionVM.payeeSuggestions.isEmpty {
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
                .offset(y: 140)
            }
            
            if isDescInputActive && !transactionVM.descSuggestions.isEmpty {
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
    RecordExpenseView(transactionVM: TransactionViewModel())
        .modelContainer(.preview)
}
