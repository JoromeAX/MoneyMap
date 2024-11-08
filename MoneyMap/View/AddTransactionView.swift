//
//  AddTransactionView.swift
//  MoneyMap
//
//  Created by Roman Khancha on 05.11.2024.
//

import SwiftUI

struct AddTransactionView: View {
    @Environment(\.modelContext) private var context
    @EnvironmentObject var appState: AppState
    @StateObject var viewModel: TransactionViewModel
    @State private var amount: String = ""
    @State private var selectedCategory: Category?
    @State private var date: Date = Date()
    @State private var note: String = ""
    @State private var isExpense: Bool = true
    @State private var showCategorySheet: Bool = false
    @State private var showAddCategoryView: Bool = false
    
    @FocusState private var amountIsFocused: Bool
    
    var body: some View {
        List {
            Picker("Тип транзакции", selection: $isExpense) {
                Text("Расход").tag(true)
                Text("Доход").tag(false)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            TextField("Сумма", text: $amount)
                .keyboardType(.decimalPad)
                .focused($amountIsFocused)
            
            HStack {
                Button("Категории") {
                    viewModel.fetchCategories()
                    showCategorySheet.toggle()
                    amountIsFocused = false
                }
                
                Spacer()
                
                if let selectedCategory {
                    Text(selectedCategory.name.localized)
                        
                    Image(systemName: "circle.fill")
                        .foregroundStyle(Color(hex: selectedCategory.color))
                } else {
                    Text("Выберите категорию")
                }
            }
            
            DatePicker("Дата", selection: $date, displayedComponents: .date)
            
            TextField("Заметка", text: $note)
            
            Button("Сохранить") {
                saveTransaction()
            }
            .disabled(amount.isEmpty || selectedCategory == nil)
            
            Button("Добавить категорию") {
                showAddCategoryView.toggle()
            }
        }
        .onAppear {
            amount = ""
            selectedCategory = nil
            date = Date()
            note = ""
        }
        .fullScreenCover(isPresented: $showCategorySheet) {
            CategorySelectionView(
                viewModel: viewModel, selectedCategory: $selectedCategory, isExpense: isExpense
            )
        }
        .fullScreenCover(isPresented: $showAddCategoryView) {
            AddCategoryView(viewModel: viewModel)
        }
    }
    
    private func saveTransaction() {
        guard let amountValue = Int(amount), let category = selectedCategory else { return }
        
        viewModel.addTransaction(amount: amountValue, date: date, type: isExpense ? .expense : .income, note: note, category: category)
        
        amount = ""
        selectedCategory = nil
        date = Date()
        note = ""
        
        appState.selectedTab = 0
    }
}
