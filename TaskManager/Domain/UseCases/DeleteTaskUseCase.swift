//
//  DeleteTaskUseCase.swift
//  TaskManager
//
//  Created by Johnny Owayed on 07/03/2025.
//

import Foundation
import Combine

/// Protocol for the Delete Task use case
protocol DeleteTaskUseCaseProtocol {
    func execute(taskId: UUID) -> AnyPublisher<Void, Error>
}

/// Implementation of the Delete Task use case
final class DeleteTaskUseCase: DeleteTaskUseCaseProtocol {
    // MARK: - Dependency Injection
    private let taskRepository: TaskRepositoryProtocol
    
    init(taskRepository: TaskRepositoryProtocol) {
        self.taskRepository = taskRepository
    }
    
    func execute(taskId: UUID) -> AnyPublisher<Void, Error> {
        return taskRepository.deleteTask(withId: taskId)
    }
}
