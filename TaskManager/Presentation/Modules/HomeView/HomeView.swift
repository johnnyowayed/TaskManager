//
//  HomeView.swift
//  TaskManager
//
//  Created by Johnny Owayed on 10/03/2025.
//

import SwiftUI
import Combine

struct HomeView: View {
    // MARK: - Environment
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    // MARK: - ViewModel
    
    @StateObject var viewModel: HomeViewModel
    
    // MARK: - State
    
    @State private var showingAddTask = false
    @State private var showingSettings = false
    
    @State private var showingSnackbar = false
    @State private var deletedTask: Task? = nil
    @State private var snackbarMessage = ""
    @State private var secondsRemaining = 5
    @State private var snackbarTimerCancellable: AnyCancellable?
    @State private var deleteTimerWorkItem: DispatchWorkItem?
    
    // MARK: - Initialization
    init(viewModel: HomeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
           
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color(UIColor.systemBackground)
                    .ignoresSafeArea()
                
                // Content
                VStack(spacing: 0) {
                    // Progress tracker
                    progressHeader
                    
                    // Filter and sort options
                    filterAndSortBar
                    
                    // Main content
                    if viewModel.isLoading && !viewModel.hasCompletedInitialLoad {
                        loadingView
                    } else if viewModel.filteredTasks.isEmpty {
                        emptyStateView
                    } else {
                        taskListView
                    }
                }
                snackbar
            }
            .navigationTitle("Tasks")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showingSettings = true
                    }) {
                        Image(systemName: "gear")
                            .accessibilityLabel("Settings")
                            
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddTask = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                    }
                    .symbolEffect(.pulse, options: .repeating, value: showingAddTask)
                    .accessibilityLabel("Create new task")
                    .accessibilityHint("Double tap to add your first task")
                }
            }
            .sheet(isPresented: $showingAddTask) {
                TaskCreationView(viewModel: DependencyInjector.shared.provideTaskCreationViewModel())
                    .presentationDetents([.medium, .large])
                    .onDisappear {
                        viewModel.loadTasks()
                    }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView(viewModel: SettingsViewModel())
                    .presentationDetents([.medium])
            }
            .onAppear {
                viewModel.loadTasks()
            }
            // Error handling
            .alert(
                "Error",
                isPresented: Binding<Bool>(
                    get: { viewModel.errorMessage != nil },
                    set: { if !$0 { viewModel.errorMessage = nil } }
                ),
                actions: {
                    Button("OK") { viewModel.errorMessage = nil }
                },
                message: {
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                    }
                }
            )
        }
    }
    
    // MARK: - Component Views
    
    private var progressHeader: some View {
        HStack(spacing: 16) {
            // Progress circle
            
            
            // Task counts
            HStack(spacing: 20) {
                Spacer()
                VStack {
                    Text("\(viewModel.pendingTasksCount)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Pending")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                CircularProgressView(progress: viewModel.completionPercentage, primaryColor: .accentColor)
                    .frame(width: 100, height: 100)
                Spacer()
                VStack {
                    Text("\(viewModel.completedTasksCount)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Completed")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
        }
        .padding()
        //        .background(Color(UIColor.secondarySystemBackground))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Task Progress")
        .accessibilityValue("\(Int(viewModel.completionPercentage * 100))% complete, \(viewModel.pendingTasksCount) pending, \(viewModel.completedTasksCount) completed")
    }
    
    private var snackbar: some View {
        VStack {
            Spacer()
            
            if showingSnackbar {
                SnackbarView(
                    message: snackbarMessage,
                    actionLabel: "UNDO",
                    action: undoDelete,
                    secondsRemaining: secondsRemaining
                )
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showingSnackbar)
    }
    
    // Method to handle the soft delete and show snackbar
    func softDeleteTask(_ task: Task) {
        // Cancel any existing timers
        snackbarTimerCancellable?.cancel()
        deleteTimerWorkItem?.cancel()
        
        // Store the task for potential restoration
        deletedTask = task
        
        // Remove from the view immediately
        viewModel.softDeleteTask(task)
        
        // Set up and show the snackbar
        snackbarMessage = "Task '\(task.title)' deleted"
        secondsRemaining = 5
        
        withAnimation {
            showingSnackbar = true
        }
        
        // Create a countdown timer
        snackbarTimerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [self] _ in
                if secondsRemaining > 1 {
                    secondsRemaining -= 1
                } else {
                    // Time's up, finalize the deletion
                    if let taskToDelete = deletedTask {
                        viewModel.permanentlyDeleteTask(taskToDelete)
                    }
                    
                    withAnimation {
                        showingSnackbar = false
                        secondsRemaining = 0
                        deletedTask = nil
                    }
                    
                    // Cancel this timer
                    snackbarTimerCancellable?.cancel()
                    snackbarTimerCancellable = nil
                }
            }
        
        // Create a backup deletion mechanism using DispatchWorkItem
        let workItem = DispatchWorkItem { [weak viewModel] in
            if let taskToDelete = deletedTask {
                viewModel?.permanentlyDeleteTask(taskToDelete)
                
                // Hide the snackbar
                withAnimation {
                    showingSnackbar = false
                    secondsRemaining = 0
                    deletedTask = nil
                }
            }
        }
        
        // Store the work item so we can cancel it if needed
        deleteTimerWorkItem = workItem
        
        // Schedule automatic dismissal and permanent deletion
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.5, execute: workItem)
    }
    
    // Method to handle the undo action
    func undoDelete() {
        guard let taskToRestore = deletedTask else { return }
        
        // Cancel timers
        snackbarTimerCancellable?.cancel()
        snackbarTimerCancellable = nil
        deleteTimerWorkItem?.cancel()
        deleteTimerWorkItem = nil
        
        // Restore the task in the view model
        viewModel.restoreTask(taskToRestore)
        
        // Reset snackbar state
        withAnimation {
            showingSnackbar = false
            deletedTask = nil
        }
    }
    
    private var filterAndSortBar: some View {
        HStack {
            // Filter picker
            Picker("Filter", selection: $viewModel.selectedFilter) {
                ForEach(TaskFilter.allCases) { filter in
                    Text(filter.rawValue).tag(filter)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .accessibilityLabel("Task filter")
            .accessibilityHint("Select to filter tasks by completion status")
                    
            
            Spacer()
            
            // Sort options
            // Option 2: Using a Button-like appearance
            Menu {
                Picker("Sort by", selection: $viewModel.selectedSortOption) {
                    ForEach(TaskSortOption.allCases) { option in
                        Label(option.rawValue, systemImage: sortOptionIcon(for: option))
                            .tag(option)
                    }
                }
            } label: {
                Button(action: {}) {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.caption)
                }
                .foregroundColor(.primary)
                .padding(8)
                .background(Color(UIColor.tertiarySystemBackground))
                .cornerRadius(8)
                .accessibilityLabel("Sort tasks")
                .accessibilityHint("Choose how to sort your task list")
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ForEach(0..<5, id: \.self) { _ in
                ShimmerView()
            }
            Spacer()
        }
        .padding()
    }
    
    private var emptyStateView: some View {
        EmptyStateView(
            title: emptyStateTitle,
            message: emptyStateMessage,
            systemImageName: "checklist",
            action: { showingAddTask = true }
        )
    }
    
    private var taskListView: some View {
        List {
            ForEach(viewModel.filteredTasks) { task in
                NavigationLink {
                    TaskDetailView(
                        viewModel: DependencyInjector.shared.provideTaskDetailViewModel(taskId: task.id)
                    )
                } label: {
                    TaskRow(
                        task: task,
                        onCompletedToggle: { toggledTask in
                            // This makes sure task completion toggles without navigating
                            withAnimation {
                                viewModel.toggleTaskCompletion(toggledTask)
                            }
                        }
                    )
                }
                // Apply these important modifiers
                .buttonStyle(PlainButtonStyle())
                .accessibilityTask(task: task)
                .taskItemTransition()
                .swipeActions(edge: .leading) {
                    Button {
                        withAnimation {
                            viewModel.toggleTaskCompletion(task)
                        }
                    } label: {
                        Label(
                            task.isCompleted ? "Mark as Pending" : "Mark as Complete",
                            systemImage: task.isCompleted ? "arrow.uturn.backward.circle" : "checkmark.circle"
                        )
                    }
                    .tint(task.isCompleted ? .orange : .green)
                    .accessibilityLabel(task.isCompleted ? "Mark as pending" : "Mark as completed")

                }
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        softDeleteTask(task)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    .accessibilityLabel("Delete task")
                }
            }
            .onDelete { indexSet in
                for index in indexSet {
                    let task = viewModel.filteredTasks[index]
                    softDeleteTask(task)
                }
                
            }
            .onMove { source, destination in
                viewModel.selectedSortOption = .order
                viewModel.moveTask(from: source, to: destination)
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            }
        }
        .listStyle(PlainListStyle())
        .springAnimation()
    }
    
    // MARK: - Helper Functions
    
    // Get appropriate icon for sort option
    private func sortOptionIcon(for option: TaskSortOption) -> String {
        switch option {
        case .priority: return "exclamationmark.triangle"
        case .dueDate: return "calendar"
        case .alphabetical: return "textformat.abc"
        case .order: return "arrow.up.and.down"
        }
    }
    
    // Dynamic empty state title based on selected filter
    private var emptyStateTitle: String {
        switch viewModel.selectedFilter {
        case .all:
            return "No Tasks Yet"
        case .pending:
            return "No Pending Tasks"
        case .completed:
            return "No Completed Tasks"
        }
    }
    
    
    
    // Dynamic empty state message based on selected filter
    private var emptyStateMessage: String {
        switch viewModel.selectedFilter {
        case .all:
            return "Add your first task to get started"
        case .pending:
            return "You've completed all your tasks!"
        case .completed:
            return "Complete a task and it will appear here"
        }
    }
}

#Preview {
    // Preview with mock data
    let viewModel = HomeViewModel(
        getTasksUseCase: MockGetTasksUseCase(),
        updateTaskUseCase: MockUpdateTaskUseCase(),
        deleteTaskUseCase: MockDeleteTaskUseCase(),
        reorderTasksUseCase: MockReorderTasksUseCase()
    )
    
    // Add some mock tasks
    viewModel.tasks = [
        Task(title: "Implement SwiftUI task list", priority: .high, dueDate: Date().addingTimeInterval(86400)),
        Task(title: "Add Core Data persistence", priority: .medium, dueDate: Date().addingTimeInterval(172800)),
        Task(title: "Write unit tests", priority: .medium, dueDate: Date().addingTimeInterval(259200)),
        Task(title: "Design app icon", isCompleted: true)
    ]
    
    // Simulate completed initial load
    viewModel.hasCompletedInitialLoad = true
    viewModel.filterAndSortTasks(tasks: viewModel.tasks, filter: .all, sortOption: .priority)
    
    return HomeView(viewModel: viewModel)
}

