//
//  AuxillaryViews.swift
//  Focustomize
//
//  Created by Taj C on 11/25/24.
//

import SwiftUI

// MARK: - Supporting Views
struct ColorButton: View {
    let color: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: 30, height: 30)
                    .overlay(Circle().stroke(color.opacity(0.8), lineWidth: 3))

                ZStack {
                    if isSelected {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 12, height: 12)
                            .transition(.scale) // Transition
                    }
                }
                .animation(.easeInOut(duration: 0.15), value: isSelected) // Faster animation
            }
        }
        .help(tooltipForColor(color))
        .buttonStyle(.plain)
    }
}

struct ColorGroupSection: View {
    let title: String
    let colors: [String]
    @Binding var selectedColor: String
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 11)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(colors, id: \.self) { color in
                    ColorButton(
                        color: getColor(for: color),
                        isSelected: selectedColor == color
                    ) {
                        withAnimation {
                            selectedColor = color
                        }
                    }
                }
            }
        }
    }
}
