//
//  CategorySelectionView.swift
//  MoneyMap
//
//  Created by Roman Khancha on 06.11.2024.
//

import SwiftUI

struct CategorySelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel: TransactionViewModel
    @Binding var selectedCategory: Category?
    @State var isExpense: Bool
    
    var body: some View {
        NavigationView {
            List(isExpense ? viewModel.expenseCategories : viewModel.incomeCategories) { category in
                Button(action: {
                    selectedCategory = category
                    dismiss()
                }) {
                    HStack {
                        Text(category.name.localized)
                        
                        Image(systemName: "circle.fill")
                            .foregroundStyle(Color(hex: category.color))
                    }
                }
                .foregroundStyle(Color.primary)
            }
            .navigationTitle("Выберите категорию")
            .navigationBarItems(trailing: Button("Закрыть") {
                selectedCategory = nil
                dismiss()
            })
        }
    }
}
