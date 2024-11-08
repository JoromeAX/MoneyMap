//
//  TransactionViewModel.swift
//  MoneyMap
//
//  Created by Roman Khancha on 05.11.2024.
//

import Foundation
import SwiftData
import Combine
import SwiftUI

class TransactionViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var filteredTransactions: [Transaction] = []
    @Published var incomeCategories: [Category] = []
    @Published var expenseCategories: [Category] = []
    @Published var categories: [Category] = []
    @Published var selectedCategory: Category?
    @Published var selectedDate: Date = Date()
    
    private var modelContext: ModelContext
    
    var totalBalance: Int {
        let income = transactions
            .filter { $0.category.type == .income }
            .reduce(0) { $0 + $1.amount }
        
        let expenses = transactions
            .filter { $0.category.type == .expense }
            .reduce(0) { $0 + $1.amount }
        
        return income - expenses
    }
    
    init(context: ModelContext) {
        self.modelContext = context
        initializeDefaultCategories()
    }
    
    func fetchTransactions() {
        let fetchDescriptor = FetchDescriptor<Transaction>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        do {
            transactions = try modelContext.fetch(fetchDescriptor)
        } catch {
            print("Error fetching transactions: \(error)")
        }
    }
    
    func fetchCategories() {
        let fetchDescriptor = FetchDescriptor<Category>()
        
        do {
            categories = try modelContext.fetch(fetchDescriptor)
            incomeCategories = categories.filter { $0.type == .income }
            expenseCategories = categories.filter { $0.type == .expense }
            print("Fetch categories success")
        } catch {
            print("Error fetching categories: \(error)")
        }
    }
    
    func addTransaction(amount: Int, date: Date, type: TransactionType, note: String?, category: Category) {
        let newTransaction = Transaction(amount: amount, date: date, note: note, category: category)
        
        do {
            modelContext.insert(newTransaction)
            try modelContext.save()
        } catch {
            print("Error adding transaction: \(error)")
        }
        fetchTransactions()
    }
    
    func addCategory(name: String, type: Bool, color: String) {
        let newCategory = Category(name: name, type: type ? .expense : .income, color: color)
        modelContext.insert(newCategory)
        
        do {
            try modelContext.save()
            categories.append(newCategory)
            if type {
                expenseCategories.append(newCategory)
            } else {
                incomeCategories.append(newCategory)
            }
        } catch {
            print("Error saving new category: \(error)")
        }
    }
    
    func deleteTransaction(_ transaction: Transaction) {
        modelContext.delete(transaction)
        
        do {
            try modelContext.save()
            fetchTransactions()
        } catch {
            print("Error deleting transaction: \(error)")
        }
    }
    
    func deleteCategory(_ category: Category) {
        do {
            let transactionsToDelete = transactions.filter { $0.category.id == category.id }
            
            for transaction in transactionsToDelete {
                modelContext.delete(transaction)
            }
            
            try modelContext.save()
            
            fetchTransactions()
            fetchCategories()
            
            modelContext.delete(category)
            
            try modelContext.save()
            
            fetchCategories()
            print("Category and associated transactions successfully deleted.")
        } catch {
            print("Error deleting category and transactions: \(error)")
        }
    }
    
    private func initializeDefaultCategories() {
        let fetchDescriptor = FetchDescriptor<Category>()
        
        let existingCategories = try? modelContext.fetch(fetchDescriptor)
        
        if existingCategories?.isEmpty ?? true {
            let defaultCategories = [
                Category(name: "Продукты", type: .expense, color: "#FF6347"),
                Category(name: "Транспорт", type: .expense, color: "#4682B4"),
                Category(name: "Жилье", type: .expense, color: "#3CB371"),
                Category(name: "Развлечения", type: .expense, color: "#8A2BE2"),
                Category(name: "Здоровье", type: .expense, color: "#FF8C00"),
                Category(name: "Коммунальные услуги", type: .expense, color: "#FFD700"),
                Category(name: "Одежда", type: .expense, color: "#FF69B4"),
                Category(name: "Образование", type: .expense, color: "#40E0D0"),
                Category(name: "Зарплата", type: .income, color: "#32CD32"),
                Category(name: "Подарки", type: .income, color: "#20B2AA"),
                Category(name: "Продажа вещей", type: .income, color: "#4B0082"),
                Category(name: "Инвестиции", type: .income, color: "#8B4513")
            ]
            
            for category in defaultCategories {
                modelContext.insert(category)
            }
            
            do {
                try modelContext.save()
            } catch {
                print("Error saving default categories: \(error)")
            }
        }
    }
}

extension TransactionViewModel {
    
    func filterTransactions(by period: Period) {
        let now = Date()
        switch period {
        case .day:
            filteredTransactions = transactions.filter {
                Calendar.current.isDateInToday($0.date)
            }
        case .week:
            let startOfWeek = Calendar.current.date(byAdding: .day, value: -7, to: now)!
            filteredTransactions = transactions.filter {
                $0.date >= startOfWeek
            }
        case .month:
            let startOfMonth = Calendar.current.date(byAdding: .month, value: -1, to: now)!
            filteredTransactions = transactions.filter {
                $0.date >= startOfMonth
            }
        case .year:
            let startOfYear = Calendar.current.date(byAdding: .year, value: -1, to: now)!
            filteredTransactions = transactions.filter {
                $0.date >= startOfYear
            }
        }
    }
    
    func filteredTransactions(for period: Period, selectedDate: Date, isExpense: Bool) -> [Transaction] {
        let filteredByType = transactions.filter { $0.category.type == (isExpense ? .expense : .income) }
        let calendar = Calendar.current
        
        switch period {
        case .day:
            return filteredByType.filter { calendar.isDate($0.date, inSameDayAs: selectedDate) }
        case .week:
            let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: selectedDate))!
            let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek)!
            return filteredByType.filter { $0.date >= startOfWeek && $0.date <= endOfWeek }
        case .month:
            let range = calendar.range(of: .day, in: .month, for: selectedDate)!
            let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedDate))!
            let endOfMonth = calendar.date(byAdding: .day, value: range.count - 1, to: startOfMonth)!
            return filteredByType.filter { $0.date >= startOfMonth && $0.date <= endOfMonth }
        case .year:
            let startOfYear = calendar.date(from: calendar.dateComponents([.year], from: selectedDate))!
            let endOfYear = calendar.date(byAdding: .day, value: 364, to: startOfYear)!
            return filteredByType.filter { $0.date >= startOfYear && $0.date <= endOfYear }
        }
    }
    
    func amountTransactions(for period: Period, selectedDate: Date, category: Transaction? = nil, isExpense: Bool) -> Int {
        let filtered = filteredTransactions(for: period, selectedDate: selectedDate, isExpense: isExpense)
        let categoryFiltered = category == nil ? filtered : filtered.filter { $0.category == category?.category }
        
        return categoryFiltered.reduce(0) { $0 + $1.amount }
    }
}

enum Period: String, CaseIterable {
    case day = "День"
    case week = "Неделя"
    case month = "Месяц"
    case year = "Год"
    
    var localized: String {
        NSLocalizedString(self.rawValue, comment: "")
    }
}
