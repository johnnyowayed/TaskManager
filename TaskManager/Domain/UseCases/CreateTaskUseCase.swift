//
//  CreateTaskUseCase.swift
//  TaskManager
//
//  Created by Johnny Owayed on 07/03/2025.
//

import Foundation
import Combine

/// Protocol for the Create Task use case
protocol CreateTaskUseCaseProtocol {
    func execute(title: String, description: String?, priority: TaskPriority, dueDate: Date?) -> AnyPublisher<Task, Error>
}

/// Implementation of the Create Task use case
final class CreateTaskUseCase: CreateTaskUseCaseProtocol {
    // MARK: - Dependency Injection
    private let taskRepository: TaskRepositoryProtocol
    
    init(taskRepository: TaskRepositoryProtocol) {
        self.taskRepository = taskRepository
    }
    
    func execute(title: String, description: String?, priority: TaskPriority, dueDate: Date?) -> AnyPublisher<Task, Error> {
        // Create a new task with provided details
        let newTask = Task(
            title: title,
            description: description,
            priority: priority,
            dueDate: dueDate
        )
        
        // Pass to repository for persistence
        return taskRepository.createTask(newTask)
    }
}
