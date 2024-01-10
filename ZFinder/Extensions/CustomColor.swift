//
//  CustomColor.swift
//  ZFinder
//
//  Created by Shrey Gangwar on 1/10/24.
//

import SwiftUI

enum CustomColor: CaseIterable {
    case red
    case green
    case yellow
    case blue
    case orange
    case purple
    case cyan
    case magenta
    case white
    case gray
    case black
    
    var color: Color {
        switch self {
        case .red:
            return Color(hex: "e6194B")
        case .green:
            return Color(hex: "3cb44b")
        case .yellow:
            return Color(hex: "ffe119")
        case .blue:
            return Color(hex: "4363d8")
        case .orange:
            return Color(hex: "f58231")
        case .purple:
            return Color(hex: "911eb4")
        case .cyan:
            return Color(hex: "42d4f4")
        case .magenta:
            return Color(hex: "f032e6")
        case .white:
            return Color(hex: "ffffff")
        case .gray:
            return Color.gray
        case .black:
            return Color(hex: "000000")
        }
    }
    
    var name: String {
        switch self {
        case .red:
            "red"
        case .green:
            "green"
        case .yellow:
            "yellow"
        case .blue:
            "blue"
        case .orange:
            "orange"
        case .purple:
            "purple"
        case .cyan:
            "cyan"
        case .magenta:
            "magenta"
        case .white:
            "white"
        case .gray:
            "gray"
        case .black:
            "black"
        }
    }
    
    static func createCustomColor(_ color: String) -> CustomColor? {
        switch color.lowercased() {
        case "red":
            return .red
        case "green":
            return .green
        case "yellow":
            return .yellow
        case "blue":
            return .blue
        case "orange":
            return .orange
        case "purple":
            return .purple
        case "cyan":
            return .cyan
        case "magenta":
            return .magenta
        case "white":
            return .white
        case "black":
            return .black
        default:
            return .gray
        }
    }
}


extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
