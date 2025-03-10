//
//  GetTasksUseCase.swift
//  TaskManager
//
//  Created by Johnny Owayed on 07/03/2025.
//

import Foundation
import Combine

protocol GetTasksUseCaseProtocol {
    func execute() -> AnyPublisher<[Task], Error>
    func execute(isCompleted: Bool) -> AnyPublisher<[Task], Error>
}

/// Implementation of the Get Tasks use case
final class GetTasksUseCase: GetTasksUseCaseProtocol {
    // MARK: - Dependency Injection
    private let taskRepository: TaskRepositoryProtocol
    
    init(taskRepository: TaskRepositoryProtocol) {
        self.taskRepository = taskRepository
    }
    
    // Execute without filter
    func execute() -> AnyPublisher<[Task], Error> {
        return taskRepository.getTasks()
    }
    
    // Execute with completion status filter
    func execute(isCompleted: Bool) -> AnyPublisher<[Task], Error> {
        return taskRepository.getTasks(isCompleted: isCompleted)
    }
}
