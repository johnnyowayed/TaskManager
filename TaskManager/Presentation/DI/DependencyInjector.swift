//
//  DependencyInjector.swift
//  TaskManager
//
//  Created by Johnny Owayed on 07/03/2025.
//

import Foundation
import SwiftUI

// MARK: - Dependency Injection Container
// This is an implementation of the Service Locator pattern that adheres to the Dependency Inversion Principle

final class DependencyInjector {
    // MARK: - Shared instance (Singleton)
    
    static let shared = DependencyInjector()
    
    // MARK: - Data Layer
    
    private lazy var coreDataStack: CoreDataStack = {
        return CoreDataStack.shared
    }()
    
    private lazy var taskRepository: TaskRepositoryProtocol = {
        return TaskRepository(coreDataStack: coreDataStack)
    }()
    
    // MARK: - Domain Layer
    
    private lazy var getTasksUseCase: GetTasksUseCaseProtocol = {
        return GetTasksUseCase(taskRepository: taskRepository)
    }()
    
    private lazy var createTaskUseCase: CreateTaskUseCaseProtocol = {
        return CreateTaskUseCase(taskRepository: taskRepository)
    }()
    
    private lazy var updateTaskUseCase: UpdateTaskUseCaseProtocol = {
        return UpdateTaskUseCase(taskRepository: taskRepository)
    }()
    
    private lazy var deleteTaskUseCase: DeleteTaskUseCaseProtocol = {
        return DeleteTaskUseCase(taskRepository: taskRepository)
    }()
    
    private lazy var reorderTasksUseCase: ReorderTasksUseCaseProtocol = {
        return ReorderTasksUseCase(taskRepository: taskRepository)
    }()
    
    // MARK: - Presentation Layer
    
    func provideTaskListViewModel() -> HomeViewModel {
        return HomeViewModel(
            getTasksUseCase: getTasksUseCase,
            updateTaskUseCase: updateTaskUseCase,
            deleteTaskUseCase: deleteTaskUseCase,
            reorderTasksUseCase: reorderTasksUseCase
        )
    }
    
    func provideTaskCreationViewModel() -> TaskCreationViewModel {
        return TaskCreationViewModel(
            createTaskUseCase: createTaskUseCase
        )
    }
    
    func provideTaskDetailViewModel(taskId: UUID) -> TaskDetailViewModel {
        return TaskDetailViewModel(
            taskId: taskId,
            getTaskUseCase: getTasksUseCase,
            updateTaskUseCase: updateTaskUseCase,
            deleteTaskUseCase: deleteTaskUseCase
        )
    }
    
    // MARK: - View Providers
    
    // TaskList View
    func provideTaskListView() -> some View {
        return HomeView(viewModel: provideTaskListViewModel())
    }
    
    // TaskCreation View
    func provideTaskCreationView() -> some View {
        return TaskCreationView(viewModel: provideTaskCreationViewModel())
    }
    
    // TaskDetail View
    func provideTaskDetailView(taskId: UUID) -> some View {
        return TaskDetailView(viewModel: self.provideTaskDetailViewModel(taskId: taskId))
    }
    
    // MARK: - Private initialization to enforce singleton
    
    private init() {}
}
