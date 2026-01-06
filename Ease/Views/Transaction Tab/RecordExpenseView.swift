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
    
    var body: some View {
        VStack {
            DismissButton()
            
            Text("New Transaction")
                .font(.headline).fontWeight(.regular)
            
            TextField("$0.00", value: $transactionVM.amount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
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
            
            RecordExpenseBodyView(categoryVM: categoryVM, transactionVM: transactionVM)
            
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
                    }
                } label: {
                    Text("Save & Add Another")
                        .frame(maxWidth: .infinity)
                        .blackButtonStyle()
                }
            }
            .fixedSize(horizontal: true, vertical: false)
            
            Spacer()
        }
        .overlay(alignment: .top) {
            if !transactionVM.descSuggestions.isEmpty {
                VStack {
                    ForEach(transactionVM.descSuggestions, id: \.self) { desc in
                        Button {
                            transactionVM.desc = desc
                            transactionVM.isSuggestionSelected = true
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
                .frame(maxWidth: .infinity)
                .background {
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundStyle(Color(.secondarySystemBackground))
                        .shadow(color: .eBlack.opacity(0.1), radius: 5, x: 5, y: 5)
                }
                .offset(y: 430)
            }
        }
        .padding()
        .alert(transactionVM.valError?.errorTitle ?? "Error", isPresented: $transactionVM.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(transactionVM.valError?.errorMessage ?? "An unexpected error has occurred. Please try again.")
        }
        .onAppear {
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
}

struct RecordExpenseBodyView: View {
    @Bindable var categoryVM: CategoryViewModel
    @Bindable var transactionVM: TransactionViewModel
    
    @FocusState private var isInputActive: Bool
    
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
                
                TextField(text: $transactionVM.payeeName) {
                    Text("Entity")
                }
            }
            
            CustomDivider()
            
            HStack {
                Image(systemName: "line.3.horizontal")

                TextField("Description", text: $transactionVM.desc)
                    .focused($isInputActive)
                    .font(.headline).fontWeight(.regular)
                    .onChange(of: transactionVM.desc) { _, newValue in
                        transactionVM.getDescSuggestions(for: newValue)
                    }
            }
            
            CustomDivider()
            
            DateRowView(transactionVM: transactionVM)
            
            CustomDivider()
        }
        .padding(.top, 10)
        .padding(.bottom, 25)
        .padding(.horizontal, 10)
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
