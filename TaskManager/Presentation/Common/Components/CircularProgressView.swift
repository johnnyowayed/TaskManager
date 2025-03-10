//
//  CircularProgressView.swift
//  TaskManager
//
//  Created by Johnny Owayed on 07/03/2025.
//

import SwiftUI

// MARK: - Open-Closed Principle (OCP)
// This component is open for extension but closed for modification

struct CircularProgressView: View {
    // MARK: - Properties
    
    let progress: Double
    var lineWidth: CGFloat = 12
    var primaryColor: Color = .green
    var secondaryColor: Color = .gray.opacity(0.3)
    
    // Animation properties
    @State private var animatedProgress: Double = 0
    
    // MARK: - Body
    //
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(lineWidth: lineWidth)
                .foregroundColor(secondaryColor)
            
            // Progress circle
            Circle()
                .trim(from: 0.0, to: CGFloat(min(animatedProgress, 1.0)))
                .stroke(style: StrokeStyle(
                    lineWidth: lineWidth,
                    lineCap: .round
                ))
                .foregroundColor(primaryColor)
                .rotationEffect(Angle(degrees: 270))
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: animatedProgress)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Task progress")
            .accessibilityValue("\(Int(progress * 100))% complete")
            
            // Percentage text
            Text("\(Int(animatedProgress * 100))%")
                .font(.system(.title, design: .rounded).weight(.bold))
                .accessibilityLabel("Progress: \(Int(animatedProgress * 100)) percent")
        }
        .onAppear {
            withAnimation(.spring(response: 1.0, dampingFraction: 0.8)) {
                self.animatedProgress = self.progress
            }
        }
        .onChange(of: progress) { _, newValue in
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                self.animatedProgress = newValue
            }
        }
    }
}

// MARK: - Preview Provider

struct CircularProgressView_Previews: PreviewProvider {
    static var previews: some View {
        CircularProgressView(progress: 0.75)
            .frame(width: 200, height: 200)
            .padding()
    }
}
