//
//  CreateTaskUseCaseTests.swift
//  TaskManagerTests
//
//  Created by Johnny Owayed on 07/03/2025.
//

import XCTest
import Combine
@testable import TaskManager

final class CreateTaskUseCaseTests: XCTestCase {
    // MARK: - Properties
    
    private var mockTaskRepository: MockTaskRepository!
    private var createTaskUseCase: CreateTaskUseCase!
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Setup and Teardown
    
    override func setUp() {
        super.setUp()
        mockTaskRepository = MockTaskRepository()
        createTaskUseCase = CreateTaskUseCase(taskRepository: mockTaskRepository)
    }
    
    override func tearDown() {
        mockTaskRepository = nil
        createTaskUseCase = nil
        cancellables.removeAll()
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testCreateTaskSuccess() {
        // Given
        let expectation = XCTestExpectation(description: "Task creation successful")
        let title = "Test Task"
        let description = "Test Description"
        let priority = TaskPriority.medium
        let dueDate = Date().addingTimeInterval(3600) // 1 hour from now
        
        // Create a mock response task
        let responseTask = Task(
            id: UUID(),
            title: title,
            description: description,
            priority: priority,
            dueDate: dueDate,
            isCompleted: false,
            createdAt: Date(),
            order: 0
        )
        
        // Configure mock repository to return success
        mockTaskRepository.createTaskResult = .success(responseTask)
        
        // When
        createTaskUseCase.execute(
            title: title,
            description: description,
            priority: priority,
            dueDate: dueDate
        )
        .sink(
            receiveCompletion: { completion in
                if case .failure = completion {
                    XCTFail("Task creation should succeed")
                }
            },
            receiveValue: { task in
                // Then
                XCTAssertEqual(task.title, title)
                XCTAssertEqual(task.description, description)
                XCTAssertEqual(task.priority, priority)
                XCTAssertEqual(task.dueDate!.timeIntervalSince1970, dueDate.timeIntervalSince1970, accuracy: 1.0)
                XCTAssertFalse(task.isCompleted)
                expectation.fulfill()
            }
        )
        .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testCreateTaskFailure() {
        // Given
        let expectation = XCTestExpectation(description: "Task creation failure")
        let title = "Test Task"
        let expectedError = NSError(domain: "test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Repository error"])
        
        // Configure mock repository to return failure
        mockTaskRepository.createTaskResult = .failure(expectedError)
        
        // When
        createTaskUseCase.execute(title: title, description: nil, priority: .low, dueDate: nil)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        // Then
                        XCTAssertEqual((error as NSError).domain, expectedError.domain)
                        XCTAssertEqual((error as NSError).code, expectedError.code)
                        expectation.fulfill()
                    }
                },
                receiveValue: { _ in
                    XCTFail("Should not receive a value")
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testCreateTaskWithMinimumRequiredFields() {
        // Given
        let expectation = XCTestExpectation(description: "Task creation with minimum fields")
        let title = "Minimal Task"
        
        // Create a mock response task with just the title
        let responseTask = Task(
            id: UUID(),
            title: title,
            description: nil,
            priority: .medium, // Default
            dueDate: nil,
            isCompleted: false,
            createdAt: Date(),
            order: 0
        )
        
        // Configure mock repository to return success
        mockTaskRepository.createTaskResult = .success(responseTask)
        
        // When - Execute with only title
        createTaskUseCase.execute(title: title, description: nil, priority: .low, dueDate: nil)
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        XCTFail("Task creation should succeed with minimal fields")
                    }
                },
                receiveValue: { task in
                    // Then
                    XCTAssertEqual(task.title, title)
                    XCTAssertNil(task.description)
                    XCTAssertEqual(task.priority, .medium) // Default value
                    XCTAssertNil(task.dueDate)
                    XCTAssertFalse(task.isCompleted)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
}

// MARK: - Mock Task Repository for testing

final class MockTaskRepository: TaskRepositoryProtocol {
    var getTasksResult: Result<[Task], Error> = .success([])
    var getTaskResult: Result<Task?, Error> = .success(nil)
    var createTaskResult: Result<Task, Error> = .success(Task(title: ""))
    var updateTaskResult: Result<Task, Error> = .success(Task(title: ""))
    var deleteTaskResult: Result<Void, Error> = .success(())
    var reorderTasksResult: Result<[Task], Error> = .success([])
    
    // Most recent values for verification
    var lastCreatedTask: Task?
    var lastUpdatedTask: Task?
    var lastDeletedId: UUID?
    var lastReorderedTasks: [Task]?
    
    func getTasks() -> AnyPublisher<[Task], Error> {
        return resultPublisher(getTasksResult)
    }
    
    func getTasks(isCompleted: Bool) -> AnyPublisher<[Task], Error> {
        // Filter the mock tasks based on completion status
        return resultPublisher(getTasksResult)
            .map { tasks in tasks.filter { $0.isCompleted == isCompleted } }
            .eraseToAnyPublisher()
    }
    
    func getTask(withId id: UUID) -> AnyPublisher<Task?, Error> {
        return resultPublisher(getTaskResult)
    }
    
    func createTask(_ task: Task) -> AnyPublisher<Task, Error> {
        lastCreatedTask = task
        return resultPublisher(createTaskResult)
    }
    
    func updateTask(_ task: Task) -> AnyPublisher<Task, Error> {
        lastUpdatedTask = task
        return resultPublisher(updateTaskResult)
    }
    
    func deleteTask(withId id: UUID) -> AnyPublisher<Void, Error> {
        lastDeletedId = id
        return resultPublisher(deleteTaskResult)
    }
    
    func reorderTasks(_ tasks: [Task]) -> AnyPublisher<[Task], Error> {
        lastReorderedTasks = tasks
        return resultPublisher(reorderTasksResult)
    }
    
    // Helper to create a publisher from a result
    private func resultPublisher<T>(_ result: Result<T, Error>) -> AnyPublisher<T, Error> {
        return result.publisher.eraseToAnyPublisher()
    }
}
