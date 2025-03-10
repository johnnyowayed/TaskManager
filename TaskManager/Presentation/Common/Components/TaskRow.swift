//
//  TaskRow.swift
//  TaskManager
//
//  Created by Johnny Owayed on 07/03/2025.
//

import SwiftUI

struct TaskRow: View {
    // MARK: - Properties
    
    let task: Task
    var onCompletedToggle: (Task) -> Void
    
    // MARK: - Internal State
    
    @State private var isDeleting = false
    @State private var offset: CGFloat = 0
    
    // MARK: - Constants
    
    private let deleteThreshold: CGFloat = 60
    
    // MARK: - Body
    
    var body: some View {
        HStack {
            // Priority indicator (vertical bar)
            Rectangle()
                .fill(Color(task.priority.color))
                .frame(width: 4)
                .accessibilityHidden(true)
            
            // Checkbox
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    self.onCompletedToggle(task)
                }
            }) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(task.isCompleted ? .gray : .gray)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(task.isCompleted ? "Completed main" : "Mark as completed main \(task.title)")
            
            // Task details
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(task.isCompleted ? .gray : .primary)
                    .strikethrough(task.isCompleted)
                
                HStack(spacing: 8) {
                    // Priority tag
                    Text(task.priority.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color(task.priority.color).opacity(0.2))
                        .cornerRadius(4)
                    
                    // Due date if available
                    if let dueDate = task.dueDate {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.caption)
                            Text(dueDate, style: .date)
                                .font(.caption)
                        }
                        .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.leading, 8)
            
            Spacer()
            
        }
        .contentShape(Rectangle())
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(Color(UIColor.systemBackground))
    }
}

// MARK: - Preview

struct TaskRow_Previews: PreviewProvider {
    static var previews: some View {
        TaskRow(
            task: Task(
                title: "Complete SwiftUI exercise",
                description: "Implement all required features",
                priority: .high,
                dueDate: Date().addingTimeInterval(86400),
                isCompleted: false
            ),
            onCompletedToggle: { _ in }
        )
        .previewLayout(.sizeThatFits)
    }
}
