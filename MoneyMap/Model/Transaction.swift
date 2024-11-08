//
//  Transaction.swift
//  MoneyMap
//
//  Created by Roman Khancha on 05.11.2024.
//

import Foundation
import SwiftData


@Model
class Transaction {
    @Attribute var id: UUID
    var amount: Int
    var date: Date
    var note: String?
    var category: Category
    
    init(amount: Int, date: Date, note: String?, category: Category) {
        self.id = UUID()
        self.amount = amount
        self.date = date
        self.note = note
        self.category = category
    }
}
