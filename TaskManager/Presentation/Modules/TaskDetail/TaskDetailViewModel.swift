//
//  TaskDetailViewModel.swift
//  TaskManager
//
//  Created by Johnny Owayed on 07/03/2025.
//

import Foundation
import Combine
import UIKit

// MARK: - ViewModel for task details - MVVM pattern
final class TaskDetailViewModel: ObservableObject {
    // MARK: - Published properties
    
    @Published var task: Task?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showDeleteConfirmation = false
    @Published var isDeleted = false
    @Published var isUpdating = false
    
    // MARK: - Dependencies
    
    private let taskId: UUID
    private let getTaskUseCase: GetTasksUseCaseProtocol
    private let updateTaskUseCase: UpdateTaskUseCaseProtocol
    private let deleteTaskUseCase: DeleteTaskUseCaseProtocol
    
    // MARK: - Cancellables
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed properties
    
    var formattedDueDate: String {
        guard let dueDate = task?.dueDate else {
            return "No due date"
        }
        return dueDate.relativeFormatted()
    }
    
    var timeRemaining: String? {
        guard let dueDate = task?.dueDate else {
            return nil
        }
        return dueDate.timeRemaining()
    }
    
    // MARK: - Initialization
    
    init(
        taskId: UUID,
        getTaskUseCase: GetTasksUseCaseProtocol,
        updateTaskUseCase: UpdateTaskUseCaseProtocol,
        deleteTaskUseCase: DeleteTaskUseCaseProtocol
    ) {
        self.taskId = taskId
        self.getTaskUseCase = getTaskUseCase
        self.updateTaskUseCase = updateTaskUseCase
        self.deleteTaskUseCase = deleteTaskUseCase
        
        loadTask()
    }
    
    // MARK: - Public methods
    
    func loadTask() {
        isLoading = true
        
        getTaskUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] tasks in
                    guard let self = self else { return }
                    self.task = tasks.first(where: { $0.id == self.taskId })
                }
            )
            .store(in: &cancellables)
    }
    
    func toggleTaskCompletion() {
        guard let task = task else { return }
        
        isUpdating = true
        let updatedTask = task.copy(isCompleted: !task.isCompleted)
        
        updateTaskUseCase.execute(updatedTask)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isUpdating = false
                    
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] updatedTask in
                    self?.task = updatedTask
                    
                    // Haptic feedback
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                }
            )
            .store(in: &cancellables)
    }
    
    func deleteTask() {
        guard let task = task else { return }
        
        isUpdating = true
        
        deleteTaskUseCase.execute(taskId: task.id)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isUpdating = false
                    
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] _ in
                    self?.isDeleted = true
                    
                    // Haptic feedback
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                }
            )
            .store(in: &cancellables)
    }
}
