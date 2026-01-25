//
//  Colors.swift
//  Focustomize
//
//  Created by Taj C on 11/25/24.
//

import SwiftUI

func getColor(for colorName: String) -> Color {
    switch colorName {
    // GROUP 1
    case "systemRedColor": return .red
    case "systemOrangeColor": return .orange
    case "systemYellowColor": return .yellow
    case "systemGreenColor": return .green
    case "systemMintColor": return .mint
    case "systemTealColor": return .teal
    case "systemCyanColor": return .cyan
    case "systemBlueColor": return .blue
    case "systemIndigoColor": return .indigo
    case "systemPurpleColor": return .purple
    case "systemPinkColor": return .pink
    // GROUP 2
    case "systemBrownColor": return .brown
    case "systemGrayColor": return .gray
    case "systemGray2Color": return .gray.opacity(0.8)
    case "systemGray3Color": return .gray.opacity(0.7)
    case "systemGray4Color": return .gray.opacity(0.6)
    case "systemGray5Color": return .gray.opacity(0.5)
    case "systemGray6Color": return .gray.opacity(0.4)
    // GROUP 3
    case "redColor": return Color(.red)
    case "orangeColor": return Color(.orange)
    case "yellowColor": return Color(.yellow)
    case "greenColor": return Color(.green)
    case "cyanColor": return Color(.cyan)
    case "blueColor": return Color(.blue)
    case "purpleColor": return Color(.purple)
    case "magentaColor": return Color(.magenta)
    // GROUP 4
    case "brownColor": return Color(.brown)
    case "whiteColor": return Color(.white)
    case "lightGrayColor": return Color(.lightGray)
    case "grayColor": return Color(.gray)
    case "darkGrayColor": return Color(.darkGray)
    case "blackColor": return Color(.black)
    case "clearColor": return .white.opacity(0.01)
    default: return .clear
    }
}

func tooltipForColor(_ color: Color) -> String {
    let colorMap: [Color: String] = [
        // System Colors - Group 1
        .red: "systemRedColor",
        .orange: "systemOrangeColor",
        .yellow: "systemYellowColor",
        .green: "systemGreenColor",
        .mint: "systemMintColor",
        .teal: "systemTealColor",
        .cyan: "systemCyanColor",
        .blue: "systemBlueColor",
        .indigo: "systemIndigoColor",
        .purple: "systemPurpleColor",
        .pink: "systemPinkColor",
        
        // System Colors - Group 2
        .brown: "systemBrownColor",
        .gray: "systemGrayColor",
        Color.gray.opacity(0.8): "systemGray2Color",
        Color.gray.opacity(0.7): "systemGray3Color",
        Color.gray.opacity(0.6): "systemGray4Color",
        Color.gray.opacity(0.5): "systemGray5Color",
        Color.gray.opacity(0.4): "systemGray6Color",
        
        // Named Colors - Group 3 & 4
        Color(.red): "redColor",
        Color(.orange): "orangeColor",
        Color(.yellow): "yellowColor",
        Color(.green): "greenColor",
        Color(.cyan): "cyanColor",
        Color(.blue): "blueColor",
        Color(.purple): "purpleColor",
        Color(.magenta): "magentaColor",
        Color(.brown): "brownColor",
        Color(.white): "whiteColor",
        Color(.lightGray): "lightGrayColor",
        Color(.gray): "grayColor",
        Color(.darkGray): "darkGrayColor",
        Color(.black): "blackColor",
        .white.opacity(0.01): "clearColor"
    ]
    
    guard let colorName = colorMap[color] else {
        return "Unknown Color"
    }
    
    // Reuse existing tooltip logic
    switch colorName {
    // System Colors - Group 1
    case "systemRedColor": return "System Red"
    case "systemOrangeColor": return "System Orange"
    case "systemYellowColor": return "System Yellow"
    case "systemGreenColor": return "System Green"
    case "systemMintColor": return "System Mint"
    case "systemTealColor": return "System Teal"
    case "systemCyanColor": return "System Cyan"
    case "systemBlueColor": return "System Blue"
    case "systemIndigoColor": return "System Indigo"
    case "systemPurpleColor": return "System Purple"
    case "systemPinkColor": return "System Pink"
    
    // System Colors - Group 2
    case "systemBrownColor": return "System Brown"
    case "systemGrayColor": return "System Gray"
    case "systemGray2Color": return "System Gray 2 (iOS & watchOS)"
    case "systemGray3Color": return "System Gray 3 (iOS & watchOS)"
    case "systemGray4Color": return "System Gray 4 (iOS & watchOS)"
    case "systemGray5Color": return "System Gray 5 (iOS & watchOS)"
    case "systemGray6Color": return "System Gray 6 (iOS & watchOS)"
    
    // Named Colors - Group 3 & 4
    case "redColor": return "Red"
    case "orangeColor": return "Orange"
    case "yellowColor": return "Yellow"
    case "greenColor": return "Green"
    case "cyanColor": return "Cyan"
    case "blueColor": return "Blue"
    case "purpleColor": return "Purple"
    case "magentaColor": return "Magenta"
    case "brownColor": return "Brown"
    case "whiteColor": return "White"
    case "lightGrayColor": return "Light Gray"
    case "grayColor": return "Gray"
    case "darkGrayColor": return "Dark Gray"
    case "blackColor": return "Black"
    case "clearColor": return "Clear"
    default: return "Unknown Color"
    }
}
