//
//  EmptyStateView.swift
//  TaskManager
//
//  Created by Johnny Owayed on 07/03/2025.
//

import SwiftUI

struct EmptyStateView: View {
    // MARK: - Properties
    
    let title: String
    let message: String
    let systemImageName: String
    var action: (() -> Void)?
    var actionTitle: String = "Add Task"
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            // Icon with animation
            Image(systemName: systemImageName)
                .font(.system(size: 60))
                .foregroundColor(.accentColor)
                .symbolEffect(.pulse, options: .repeating)
                .accessibilityHidden(true)
            
            // Title
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            // Message
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            // Action button (optional)
            if let action = action {
                Button(action: action) {
                    Label(actionTitle, systemImage: "plus.circle.fill")
                        .padding()
                        .frame(maxWidth: 200)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
                .padding(.top, 20)
            }
            
            Spacer()
        }
        .padding()
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Preview Provider

struct EmptyStateView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyStateView(
            title: "No Tasks",
            message: "You don't have any tasks yet. Create one to get started!",
            systemImageName: "checklist",
            action: {}
        )
    }
}
