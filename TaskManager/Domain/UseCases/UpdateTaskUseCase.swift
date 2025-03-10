//
//  UpdateTaskUseCase.swift
//  TaskManager
//
//  Created by Johnny Owayed on 07/03/2025.
//

import Foundation
import Combine

/// Protocol for the Update Task use case
protocol UpdateTaskUseCaseProtocol {
    func execute(_ task: Task) -> AnyPublisher<Task, Error>
    func markAsCompleted(taskId: UUID) -> AnyPublisher<Task, Error>
}

/// Implementation of the Update Task use case
final class UpdateTaskUseCase: UpdateTaskUseCaseProtocol {
    // MARK: - Dependency Injection
    private let taskRepository: TaskRepositoryProtocol
    
    init(taskRepository: TaskRepositoryProtocol) {
        self.taskRepository = taskRepository
    }
    
    func execute(_ task: Task) -> AnyPublisher<Task, Error> {
        return taskRepository.updateTask(task)
    }
    
    func markAsCompleted(taskId: UUID) -> AnyPublisher<Task, Error> {
        // First get the task, then mark it completed, then update
        return taskRepository.getTask(withId: taskId)
            .flatMap { task -> AnyPublisher<Task, Error> in
                guard let task = task else {
                    return Fail(error: NSError(domain: "TaskError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Task not found"]))
                        .eraseToAnyPublisher()
                }
                
                let updatedTask = task.markAsCompleted()
                return self.taskRepository.updateTask(updatedTask)
            }
            .eraseToAnyPublisher()
    }
}
