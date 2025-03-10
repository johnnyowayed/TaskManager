//
//  View+Extension.swift
//  TaskManager
//
//  Created by Johnny Owayed on 07/03/2025.
//

import SwiftUI

// MARK: - View Extensions for Reusable Modifiers

extension View {
    // MARK: - Accessibility
    
    // Add proper accessibility modifiers
    func accessibilityTask(task: Task) -> some View {
        return self.accessibilityElement(children: .combine)
            .accessibilityLabel("\(task.title), \(task.priority.rawValue) priority")
            .accessibilityValue(task.isCompleted ? "Completed" : "Not completed")
            .accessibilityHint("Double tap to view task details")
    }
    
    // MARK: - Haptic Feedback
    
    // Trigger haptic feedback
    func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    // MARK: - Common UI Elements
    
    // Add card-like styling
    func cardStyle() -> some View {
        return self
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
    }
    
    // Add a header style for consistent section headers
    func sectionHeaderStyle() -> some View {
        return self
            .font(.headline)
            .foregroundColor(.secondary)
            .padding(.horizontal)
            .padding(.top, 20)
            .padding(.bottom, 8)
    }
    
    // Animation for adding/removing items
    func taskItemTransition() -> some View {
        return self.transition(
            .asymmetric(
                insertion: .scale.combined(with: .opacity),
                removal: .scale.combined(with: .opacity)
            )
        )
    }
    
    // Animate changes with spring
    func springAnimation() -> some View {
        return withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            self
        }
    }
    
    func toViewController() -> UIViewController {
        let hostingController = UIHostingController(rootView: self)
        hostingController.view.frame = UIScreen.main.bounds
        return hostingController
    }
}
