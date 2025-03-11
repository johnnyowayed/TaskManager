//
//  TaskCreationView.swift
//  TaskManager
//
//  Created by Johnny Owayed on 07/03/2025.
//

import SwiftUI

struct TaskCreationView: View {
    // MARK: - Environment
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    // MARK: - ViewModel
    
    @ObservedObject var viewModel: TaskCreationViewModel
    
    // MARK: - State
    
    @FocusState private var focusedField: Field?
    
    // Define focusable fields
    private enum Field: Hashable {
        case title
        case description
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            Form {
                // Title Section
                Section {
                    TextField("Task Title", text: $viewModel.title)
                        .focused($focusedField, equals: .title)
                        .font(.body.weight(.medium))
                        .submitLabel(.next)
                        .onSubmit {
                            focusedField = .description
                        }
                        .accessibilityHint("Enter the title of your task")
                } header: {
                    Text("Title")
                        .accessibilityAddTraits(.isHeader)
                } footer: {
                    if !viewModel.isTitleValid && !viewModel.title.isEmpty {
                        Text("Title is required")
                            .foregroundColor(.red)
                    }
                }
                
                // Description Section
                Section {
                    ZStack(alignment: .topLeading) {
                        if viewModel.description.isEmpty {
                            Text("Add details about your task (optional)")
                                .foregroundColor(.secondary)
                                .padding(.top, 8)
                                .padding(.leading, 5)
                                .opacity(focusedField == .description ? 0 : 1)
                        }
                        
                        TextEditor(text: $viewModel.description)
                            .focused($focusedField, equals: .description)
                            .frame(minHeight: 100)
                            .padding(.leading, -5)
                            .accessibilityLabel("Task description")
                            .accessibilityHint("Optional. Enter additional details about your task")
                    }
                } header: {
                    Text("Description")
                        .accessibilityAddTraits(.isHeader)
                }
                
                // Priority Section
                Section {
                    Picker("Task Priority", selection: $viewModel.priority) {
                        ForEach(TaskPriority.allCases) { priority in
                            // Just use the text without trying to add a Circle
                            Text(priority.rawValue)
                                .tag(priority)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .accessibilityLabel("Task priority")
                    .accessibilityHint("Select the importance level of your task")

                    
                    // Show the color separately
                    HStack {
                        Text("Selected priority color:")
                        Circle()
                            .fill(Color(viewModel.priority.color))
                            .frame(width: 16, height: 16)
                    }
                } header: {
                    Text("Priority")
                        .accessibilityAddTraits(.isHeader)
                }
                
                // Due Date Section
                Section {
                    Toggle("Set Due Date", isOn: $viewModel.enableDueDate)
                        .accessibilityHint("Enable to set a deadline for your task")
                    //add color to this date picker
                    
                    if viewModel.enableDueDate {
                        DatePicker(
                            "Due Date",
                            selection: $viewModel.dueDate,
                            in: Date()...,
                            displayedComponents: [.date]
                        )
                        .datePickerStyle(.graphical)
                        .animation(.easeInOut, value: viewModel.enableDueDate)
                        .transition(.opacity)
                        .accentColor(.primary)
                        .accessibilityLabel("Task due date")
                        .accessibilityHint("Select when this task needs to be completed")
                    }
                } header: {
                    Text("Due Date")
                        .accessibilityAddTraits(.isHeader)
                }
            }
            .navigationTitle("Create Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }.tint(Color.primary)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        viewModel.createTask()
                    }
                    .tint(Color.primary)
                    .font(.headline)
                    .disabled(!viewModel.isFormValid || viewModel.isCreating)
                }
                
                ToolbarItem(placement: .keyboard) {
                    Button("Done") {
                        focusedField = nil
                    }
                }
            }
            .alert(
                "Error Creating Task",
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
            .overlay {
                if viewModel.isCreating {
                    ProgressView("Creating task...")
                        .padding()
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(8)
                        .shadow(radius: 10)
                }
            }
            .onAppear {
                // Auto-focus the title field when the view appears
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.focusedField = .title
                }
            }
            .onChange(of: viewModel.didCreateTask) { _, didCreate in
                if didCreate {
                    dismiss()
                }
            }
        }
        .interactiveDismissDisabled(viewModel.isCreating)
    }
}

// MARK: - Preview Provider

struct TaskCreationView_Previews: PreviewProvider {
    static var previews: some View {
        // Mock implementation for preview
        TaskCreationView(
            viewModel: TaskCreationViewModel(
                createTaskUseCase: CreateTaskUseCase(
                    taskRepository: TaskRepository()
                )
            )
        )
    }
}
