//
//  HomeViewModel.swift
//  TaskManager
//
//  Created by Johnny Owayed on 07/03/2025.
//

import Foundation
import Combine
import UIKit

// MARK: - Enum for filtering tasks
enum TaskFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case pending = "Pending"
    case completed = "Completed"
    
    var id: String { self.rawValue }
}

// MARK: - Enum for sorting tasks
enum TaskSortOption: String, CaseIterable, Identifiable {
    case priority = "Priority"
    case dueDate = "Due Date"
    case alphabetical = "Alphabetical"
    case order = "Custom"
    
    var id: String { self.rawValue }
}

// MARK: - State class for the view - MVVM pattern
final class HomeViewModel: ObservableObject {
    // MARK: - Published properties for UI binding
    
    @Published var tasks: [Task] = []
    @Published var filteredTasks: [Task] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedFilter: TaskFilter = .all
    @Published var selectedSortOption: TaskSortOption = .order
    @Published var hasCompletedInitialLoad = false
    
    // MARK: - Computed properties
    
    var completedTasksCount: Int {
        tasks.filter { $0.isCompleted }.count
    }
    
    var pendingTasksCount: Int {
        tasks.filter { !$0.isCompleted }.count
    }
    
    var completionPercentage: Double {
        guard !tasks.isEmpty else { return 0.0 }
        return Double(completedTasksCount) / Double(tasks.count)
    }
    
    // MARK: - Dependencies
    
    private let getTasksUseCase: GetTasksUseCaseProtocol
    private let updateTaskUseCase: UpdateTaskUseCaseProtocol
    private let deleteTaskUseCase: DeleteTaskUseCaseProtocol
    private let reorderTasksUseCase: ReorderTasksUseCaseProtocol
    
    // MARK: - Cancellables
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init(getTasksUseCase: GetTasksUseCaseProtocol,
         updateTaskUseCase: UpdateTaskUseCaseProtocol,
         deleteTaskUseCase: DeleteTaskUseCaseProtocol,
         reorderTasksUseCase: ReorderTasksUseCaseProtocol) {
        self.getTasksUseCase = getTasksUseCase
        self.updateTaskUseCase = updateTaskUseCase
        self.deleteTaskUseCase = deleteTaskUseCase
        self.reorderTasksUseCase = reorderTasksUseCase
        
        setupBindings()
    }
    
    // MARK: - Private methods
    
    private func setupBindings() {
        // When filter or sort option changes, refresh filtered tasks
        Publishers.CombineLatest3($tasks, $selectedFilter, $selectedSortOption)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] tasks, filter, sortOption in
                self?.filterAndSortTasks(tasks: tasks, filter: filter, sortOption: sortOption)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public methods for testing and UI updates
    
    func filterAndSortTasks(tasks: [Task], filter: TaskFilter, sortOption: TaskSortOption) {
        // First apply filter
        var result = tasks
        switch filter {
        case .all:
            // No filtering needed
            break
        case .pending:
            result = tasks.filter { !$0.isCompleted }
        case .completed:
            result = tasks.filter { $0.isCompleted }
        }
        
        // Then apply sorting
        switch sortOption {
        case .priority:
            // Sort by priority (high to low)
            result.sort { lhs, rhs in
                let priorityOrder: [TaskPriority] = [.high, .medium, .low]
                let lhsIndex = priorityOrder.firstIndex(of: lhs.priority) ?? 0
                let rhsIndex = priorityOrder.firstIndex(of: rhs.priority) ?? 0
                return lhsIndex < rhsIndex
            }
        case .dueDate:
            // Sort by due date (earliest first, nil dates at the end)
            result.sort { lhs, rhs in
                switch (lhs.dueDate, rhs.dueDate) {
                case (.some(let lhsDate), .some(let rhsDate)):
                    return lhsDate < rhsDate
                case (.some, .none):
                    return true
                case (.none, .some):
                    return false
                case (.none, .none):
                    return lhs.createdAt < rhs.createdAt // Fall back to creation date
                }
            }
        case .alphabetical:
            // Sort alphabetically by title
            result.sort { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        case .order:
            // Sort by custom order
            result.sort { $0.order < $1.order }
        }
        
        filteredTasks = result
    }
    
    func loadTasks() {
        isLoading = true
        errorMessage = nil
        
        getTasksUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self = self else { return }
                    
                    self.isLoading = false
                    self.hasCompletedInitialLoad = true
                    
                    if case .failure(let error) = completion {
                        self.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] tasks in
                    guard let self = self else { return }
                    self.tasks = tasks
                }
            )
            .store(in: &cancellables)
    }
    
    func toggleTaskCompletion(_ task: Task) {
        let updatedTask = task.copy(isCompleted: !task.isCompleted)
        
        updateTaskUseCase.execute(updatedTask)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] updatedTask in
                    guard let self = self else { return }
                    
                    // Update our local task list
                    if let index = self.tasks.firstIndex(where: { $0.id == updatedTask.id }) {
                        self.tasks[index] = updatedTask
                    }
                    
                    // Generate haptic feedback for task completion
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                }
            )
            .store(in: &cancellables)
    }
    
    func deleteTask(_ task: Task) {
        deleteTaskUseCase.execute(taskId: task.id)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] _ in
                    // Remove from our local list
                    self?.tasks.removeAll { $0.id == task.id }
                    
                    // Generate haptic feedback for deletion
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                }
            )
            .store(in: &cancellables)
    }
    
    func moveTask(from source: IndexSet, to destination: Int) {
        // First update the local array (for immediate UI update)
        var updatedTasks = filteredTasks
        updatedTasks.move(fromOffsets: source, toOffset: destination)
        
        // Update order property for each task
        for (index, task) in updatedTasks.enumerated() {
            if let taskIndex = tasks.firstIndex(where: { $0.id == task.id }) {
                tasks[taskIndex] = task.copy(order: index)
            }
        }
        
        // Then get all tasks sorted by order
        let allTasksWithUpdatedOrder = tasks.sorted { $0.order < $1.order }
        
        // Update the backend
        reorderTasksUseCase.execute(tasks: allTasksWithUpdatedOrder)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                        // Reload to get correct order if there was an error
                        self?.loadTasks()
                    }
                },
                receiveValue: { [weak self] updatedTasks in
                    self?.tasks = updatedTasks
                }
            )
            .store(in: &cancellables)
    }
    
    func softDeleteTask(_ task: Task) {
        // Remove from UI immediately
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks.remove(at: index)
            filterAndSortTasks(tasks: tasks, filter: selectedFilter, sortOption: selectedSortOption)
        }
    }
    
    func restoreTask(_ task: Task) {
        // Add task back
        tasks.append(task)
        filterAndSortTasks(tasks: tasks, filter: selectedFilter, sortOption: selectedSortOption)
    }
    
    // Complete the actual deletion when the snackbar disappears without undo
    func permanentlyDeleteTask(_ task: Task) {
        // Call the existing deleteTask method that performs the actual deletion from storage
        deleteTask(task)
        
        // Make sure the task is removed from the filtered tasks if it's still there
        if let index = filteredTasks.firstIndex(where: { $0.id == task.id }) {
            filteredTasks.remove(at: index)
        }
    }
    
    
    // MARK: - Deinitializer to clean up resources
    
    deinit {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }
}
