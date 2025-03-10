//
//  TaskRepositoryProtocol.swift
//  TaskManager
//
//  Created by Johnny Owayed on 07/03/2025.
//

import Foundation
import Combine

// MARK: - Interface Segregation Principle (ISP)
// The repository interface defines specific methods for task operations
// MARK: - Dependency Inversion Principle (DIP)
// High-level modules depend on abstractions, not concrete implementations

/// Protocol defining the contract for task data operations
protocol TaskRepositoryProtocol {
    // CRUD operations returning publishers (Combine)
    
    /// Get all tasks
    /// - Returns: A publisher that emits an array of tasks or an error
    func getTasks() -> AnyPublisher<[Task], Error>
    
    /// Get tasks filtered by completion status
    /// - Parameter isCompleted: Whether to fetch completed or incomplete tasks
    /// - Returns: A publisher that emits an array of filtered tasks or an error
    func getTasks(isCompleted: Bool) -> AnyPublisher<[Task], Error>
    
    /// Get a specific task by ID
    /// - Parameter id: The ID of the task to fetch
    /// - Returns: A publisher that emits the task or an error if not found
    func getTask(withId id: UUID) -> AnyPublisher<Task?, Error>
    
    /// Create a new task
    /// - Parameter task: The task to create
    /// - Returns: A publisher that emits the created task or an error
    func createTask(_ task: Task) -> AnyPublisher<Task, Error>
    
    /// Update an existing task
    /// - Parameter task: The task with updated properties
    /// - Returns: A publisher that emits the updated task or an error
    func updateTask(_ task: Task) -> AnyPublisher<Task, Error>
    
    /// Delete a task
    /// - Parameter id: The ID of the task to delete
    /// - Returns: A publisher that emits a completion or an error
    func deleteTask(withId id: UUID) -> AnyPublisher<Void, Error>
    
    /// Update the order of tasks
    /// - Parameter tasks: Array of tasks with updated order property
    /// - Returns: A publisher that emits an array of reordered tasks or an error
    func reorderTasks(_ tasks: [Task]) -> AnyPublisher<[Task], Error>
}
