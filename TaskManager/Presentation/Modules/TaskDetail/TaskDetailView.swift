//
//  TaskDetailView.swift
//  TaskManager
//
//  Created by Johnny Owayed on 07/03/2025.
//

import SwiftUI

struct TaskDetailView: View {
    // MARK: - Environment
    
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - ViewModel
    
    @StateObject var viewModel: TaskDetailViewModel
    
    // MARK: - State
    
    @State private var showEditSheet = false
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // Background
            Color(UIColor.systemBackground)
                .ignoresSafeArea()
            
            if viewModel.isLoading {
                loadingView
            } else if let task = viewModel.task {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Task title and completion status
                        titleSection(task: task)
                        
                        // Task metadata (priority, due date)
                        metadataSection(task: task)
                        
                        // Task description (if available)
                        if let description = task.description, !description.isEmpty {
                            descriptionSection(description: description)
                        }
                        
                        // Action buttons
                        actionButtonsSection(task: task)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 16)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: task.isCompleted)
                }
            } else {
                // Task not found view
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 50))
                        .foregroundColor(.secondary)
                        .padding()
                    
                    Text("Task Not Found")
                        .font(.title2)
                    
                    Text("This task may have been deleted or doesn't exist.")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Button("Go Back") {
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                }
                .padding()
            }
        }
        .navigationTitle("Task Details")
        .navigationBarTitleDisplayMode(.inline)
        .overlay {
            if viewModel.isUpdating {
                ProgressView()
                    .padding()
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(8)
                    .shadow(radius: 10)
            }
        }
        .alert(
            "Error",
            isPresented: Binding<Bool>(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            ),
            actions: {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            },
            message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
        )
        .confirmationDialog(
            "Delete Task?",
            isPresented: $viewModel.showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                viewModel.deleteTask()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This action cannot be undone.")
        }
        // Handling task deletion
        .onChange(of: viewModel.isDeleted) { _, isDeleted in
            if isDeleted {
                dismiss()
            }
        }
        // Edit task sheet (placeholder - would be replaced with actual edit view)
        .sheet(isPresented: $showEditSheet) {
            Text("Edit Task View")
                .presentationDetents([.medium, .large])
        }
    }
    
    // MARK: - Component Views
    
    // Loading view
    private var loadingView: some View {
        VStack {
            ProgressView()
                .controlSize(.large)
            Text("Loading task...")
                .foregroundColor(.secondary)
                .padding()
        }
    }
    
    // Title section
    private func titleSection(task: Task) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Title with strikethrough if completed
            Text(task.title)
                .font(.system(.title, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(task.isCompleted ? .secondary : .primary)
                .strikethrough(task.isCompleted)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.trailing, 40)
                .accessibilityLabel("Task Title")
            
            // Completion status button
            Button(action: {
                viewModel.toggleTaskCompletion()
            }) {
                HStack {
                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 24))
                        .foregroundColor(task.isCompleted ? .green : .gray)
                    
                    Text(task.isCompleted ? "Completed" : "Mark as Completed")
                        .font(.headline)
                        .foregroundColor(task.isCompleted ? .green : .primary)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            task.isCompleted
                            ? Color.green.opacity(0.15)
                            : Color(UIColor.secondarySystemBackground)
                        )
                )
            }
            .buttonStyle(.plain)
            .disabled(viewModel.isUpdating)
            .accessibilityLabel(task.isCompleted ? "Mark as not completed" : "Mark as completed")
                    .accessibilityHint("Double tap to change completion status")
                
        }
        .padding(.bottom, 8)
        .accessibilityElement(children: .combine)
            .accessibilityLabel("\(task.title), \(task.isCompleted ? "Completed" : "Not completed")")

    }
    
    // Metadata section
    private func metadataSection(task: Task) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            // Section title
            Text("Details")
                .font(.headline)
                .foregroundColor(.secondary)
            
            // Priority
            detailRow(
                title: "Priority",
                value: task.priority.rawValue,
                iconName: "exclamationmark.triangle",
                iconColor: Color(task.priority.color)
            )
            
            // Due date (if set)
            if let dueDate = task.dueDate {
                detailRow(
                    title: "Due Date",
                    value: dueDate.relativeFormatted(),
                    secondaryValue: dueDate.timeRemaining(),
                    iconName: "calendar",
                    iconColor: .blue
                )
            }
            
            // Creation date
            detailRow(
                title: "Created",
                value: DateFormatter.localizedString(
                    from: task.createdAt,
                    dateStyle: .medium,
                    timeStyle: .short
                ),
                iconName: "clock",
                iconColor: .gray
            )
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    // Description section
    private func descriptionSection(description: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section title
            Text("Description")
                .font(.headline)
                .foregroundColor(.secondary)
            
            // Description text
            Text(description)
                .font(.body)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    // Action buttons section
    private func actionButtonsSection(task: Task) -> some View {
        VStack(spacing: 16) {
            // Delete button
            Button(action: {
                viewModel.showDeleteConfirmation = true
            }) {
                HStack {
                    Image(systemName: "trash")
                    Text("Delete Task")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red.opacity(0.1))
                .foregroundColor(.red)
                .cornerRadius(10)
            }
            .buttonStyle(.plain)
            .disabled(viewModel.isUpdating)
            .accessibilityLabel("Delete task")
                    .accessibilityHint("Double tap to open delete confirmation")
        }
        .padding(.top, 20)
    }
    
    // Helper view for detail rows
    private func detailRow(
        title: String,
        value: String,
        secondaryValue: String? = nil,
        iconName: String,
        iconColor: Color
    ) -> some View {
        HStack(alignment: .center, spacing: 12) {
            // Icon
            Image(systemName: iconName)
                .font(.system(size: 18))
                .foregroundColor(iconColor)
                .frame(width: 28, height: 28)
                .background(iconColor.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                // Title
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // Value
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                // Secondary value (if provided)
                if let secondaryValue = secondaryValue {
                    Text(secondaryValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value) \(secondaryValue ?? "")")
    }
}

// MARK: - Preview Provider

struct TaskDetailView_Previews: PreviewProvider {
    static var previews: some View {
        // Preview with mock implementation
        NavigationStack {
            TaskDetailView(
                viewModel: TaskDetailViewModel(
                    taskId: UUID(),
                    getTaskUseCase: GetTasksUseCase(taskRepository: TaskRepository()),
                    updateTaskUseCase: UpdateTaskUseCase(taskRepository: TaskRepository()),
                    deleteTaskUseCase: DeleteTaskUseCase(taskRepository: TaskRepository())
                )
            )
        }
    }
}
