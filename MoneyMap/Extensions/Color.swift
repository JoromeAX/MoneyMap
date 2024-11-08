//
//  Color.swift
//  MoneyMap
//
//  Created by Roman Khancha on 07.11.2024.
//

import SwiftUI

extension Color {
    func toHex() -> String {
        let uiColor = UIColor(self)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let hex = String(
            format: "#%02X%02X%02X",
            Int(red * 255.0),
            Int(green * 255.0),
            Int(blue * 255.0)
        )
        return hex
    }
}

extension Color {
    init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        if hexSanitized.count == 6 {
            let scanner = Scanner(string: hexSanitized)
            var hexInt: UInt64 = 0
            if scanner.scanHexInt64(&hexInt) {
                let red = CGFloat((hexInt & 0xFF0000) >> 16) / 255.0
                let green = CGFloat((hexInt & 0x00FF00) >> 8) / 255.0
                let blue = CGFloat(hexInt & 0x0000FF) / 255.0
                self.init(red: red, green: green, blue: blue)
                return
            }
        }
        self.init(.gray)
    }
}
