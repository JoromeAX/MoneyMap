//
//  AddCategoryView.swift
//  MoneyMap
//
//  Created by Roman Khancha on 06.11.2024.
//

import SwiftUI

struct AddCategoryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @StateObject var viewModel: TransactionViewModel
    @State private var categoryName: String = ""
    @State private var isExpense: Bool = true
    @State private var selectedColor: Color = .white
    @State private var showDeleteAlert: Bool = false
    @State private var categoryToDelete: Category?
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Имя категории", text: $categoryName)
                
                Picker("Тип категории", selection: $isExpense) {
                    Text("Расход").tag(true)
                    Text("Доход").tag(false)
                }
                .pickerStyle(SegmentedPickerStyle())
                
                ColorPicker("Выберите цвет", selection: $selectedColor)
                
                Section(header: Text("Существующие категории")) {
                    List(isExpense ? viewModel.expenseCategories : viewModel.incomeCategories) { category in
                        HStack {
                            Text(category.name.localized)
                                
                            Image(systemName: "circle.fill")
                                .foregroundStyle(Color(hex: category.color))
                            
                            Spacer()
                            
                            Button(action: {
                                categoryToDelete = category
                                showDeleteAlert.toggle()
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Новая категория")
            .navigationBarItems(
                leading: Button("Отмена") {
                    dismiss()
                },
                trailing: Button("Сохранить") {
                    let hexColor = selectedColor.toHex()
                    viewModel.addCategory(name: categoryName, type: isExpense, color: hexColor)
                    dismiss()
                }
                    .disabled(categoryName.isEmpty)
            )
            .onAppear {
                viewModel.fetchCategories()
            }
            .alert(isPresented: $showDeleteAlert) {
                Alert(
                    title: Text("Удалить категорию"),
                    message: Text("Удалив категорию, вы также удалите все транзакции, связанные с ней. Вы уверены?"),
                    primaryButton: .destructive(Text("Удалить")) {
                        if let categoryToDelete = categoryToDelete {
                            viewModel.deleteCategory(categoryToDelete)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
}
