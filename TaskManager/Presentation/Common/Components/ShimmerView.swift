//
//  ShimmerView.swift
//  TaskManager
//
//  Created by Johnny Owayed on 07/03/2025.
//

import SwiftUI

// MARK: - Shimmer effect for loading state
struct ShimmerView: View {
    // MARK: - Properties
    
    @State private var isAnimating = false
    
    // Customization
    var height: CGFloat = 80
    var cornerRadius: CGFloat = 8
    
    // MARK: - Body
    
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    gradient: Gradient(
                        colors: [
                            Color.gray.opacity(0.2),
                            Color.gray.opacity(0.05),
                            Color.gray.opacity(0.2)
                        ]
                    ),
                    startPoint: isAnimating ? .leading : .trailing,
                    endPoint: isAnimating ? .trailing : .leading
                )
            )
            .frame(height: height)
            .cornerRadius(cornerRadius)
            .onAppear {
                withAnimation(
                    Animation.linear(duration: 1.5)
                    .repeatForever(autoreverses: false)
                ) {
                    isAnimating.toggle()
                }
            }
            .accessibilityHidden(true) // Hide from VoiceOver since it's a loading placeholder
    }
}
