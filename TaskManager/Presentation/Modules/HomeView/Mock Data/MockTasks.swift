//
//  MockTasks.swift
//  TaskManager
//
//  Created by Johnny Owayed on 10/03/2025.
//

import Combine
import Foundation

class MockGetTasksUseCase: GetTasksUseCaseProtocol {
    func execute() -> AnyPublisher<[Task], Error> {
        return Just([]).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    func execute(isCompleted: Bool) -> AnyPublisher<[Task], Error> {
        return Just([]).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
}

class MockUpdateTaskUseCase: UpdateTaskUseCaseProtocol {
    func execute(_ task: Task) -> AnyPublisher<Task, Error> {
        return Just(task).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    func markAsCompleted(taskId: UUID) -> AnyPublisher<Task, Error> {
        return Just(Task(id: taskId, title: "", isCompleted: true))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

class MockDeleteTaskUseCase: DeleteTaskUseCaseProtocol {
    func execute(taskId: UUID) -> AnyPublisher<Void, Error> {
        return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
}

class MockReorderTasksUseCase: ReorderTasksUseCaseProtocol {
    func execute(tasks: [Task]) -> AnyPublisher<[Task], Error> {
        return Just(tasks).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
}
