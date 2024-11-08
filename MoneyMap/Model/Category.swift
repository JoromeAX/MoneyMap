//
//  Category.swift
//  MoneyMap
//
//  Created by Roman Khancha on 05.11.2024.
//

import Foundation
import SwiftData

@Model
class Category {
    @Attribute(.unique) var name: String
    var type: TransactionType
    var color: String

    init(name: String, type: TransactionType, color: String = "#FFFFFF") {
        self.name = name
        self.type = type
        self.color = color
    }
}

enum TransactionType: String, Codable {
    case expense
    case income
}
