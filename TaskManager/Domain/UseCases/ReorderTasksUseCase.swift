//
//  ReorderTasksUseCase.swift
//  TaskManager
//
//  Created by Johnny Owayed on 07/03/2025.
//

import Foundation
import Combine

/// Protocol for the Reorder Tasks use case
protocol ReorderTasksUseCaseProtocol {
    func execute(tasks: [Task]) -> AnyPublisher<[Task], Error>
}

/// Implementation of the Reorder Tasks use case
final class ReorderTasksUseCase: ReorderTasksUseCaseProtocol {
    // MARK: - Dependency Injection
    private let taskRepository: TaskRepositoryProtocol
    
    init(taskRepository: TaskRepositoryProtocol) {
        self.taskRepository = taskRepository
    }
    
    func execute(tasks: [Task]) -> AnyPublisher<[Task], Error> {
        // Update the order of tasks based on their position in the array
        let tasksWithUpdatedOrder = tasks.enumerated().map { index, task in
            task.copy(order: index)
        }
        
        return taskRepository.reorderTasks(tasksWithUpdatedOrder)
    }
}
