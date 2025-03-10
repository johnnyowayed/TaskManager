//
//  GetTasksUseCaseTests.swift
//  TaskManager
//
//  Created by Johnny Owayed on 07/03/2025.
//

import XCTest
import Combine
@testable import TaskManager

final class GetTasksUseCaseTests: XCTestCase {
    // MARK: - Properties
    
    private var mockTaskRepository: MockTaskRepository!
    private var getTasksUseCase: GetTasksUseCase!
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Setup and Teardown
    
    override func setUp() {
        super.setUp()
        mockTaskRepository = MockTaskRepository()
        getTasksUseCase = GetTasksUseCase(taskRepository: mockTaskRepository)
    }
    
    override func tearDown() {
        mockTaskRepository = nil
        getTasksUseCase = nil
        cancellables.removeAll()
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testGetAllTasksSuccess() {
        // Given
        let expectation = XCTestExpectation(description: "Get all tasks successful")
        
        let mockTasks = [
            Task(id: UUID(), title: "Task 1", priority: .high),
            Task(id: UUID(), title: "Task 2", priority: .medium, isCompleted: true),
            Task(id: UUID(), title: "Task 3", priority: .low)
        ]
        
        // Configure mock repository to return success
        mockTaskRepository.getTasksResult = .success(mockTasks)
        
        // When
        getTasksUseCase.execute()
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        XCTFail("Get tasks should succeed")
                    }
                },
                receiveValue: { tasks in
                    // Then
                    XCTAssertEqual(tasks.count, 3)
                    XCTAssertEqual(tasks[0].title, "Task 1")
                    XCTAssertEqual(tasks[1].title, "Task 2")
                    XCTAssertEqual(tasks[2].title, "Task 3")
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testGetAllTasksFailure() {
        // Given
        let expectation = XCTestExpectation(description: "Get all tasks failure")
        let expectedError = NSError(domain: "test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Repository error"])
        
        // Configure mock repository to return failure
        mockTaskRepository.getTasksResult = .failure(expectedError)
        
        // When
        getTasksUseCase.execute()
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
    
    func testGetCompletedTasksSuccess() {
        // Given
        let expectation = XCTestExpectation(description: "Get completed tasks successful")
        
        let mockTasks = [
            Task(id: UUID(), title: "Task 1", priority: .high, isCompleted: false),
            Task(id: UUID(), title: "Task 2", priority: .medium, isCompleted: true),
            Task(id: UUID(), title: "Task 3", priority: .low, isCompleted: true),
            Task(id: UUID(), title: "Task 4", priority: .high, isCompleted: false)
        ]
        
        // Configure mock repository
        mockTaskRepository.getTasksResult = .success(mockTasks)
        
        // When - Get completed tasks
        getTasksUseCase.execute(isCompleted: true)
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        XCTFail("Get completed tasks should succeed")
                    }
                },
                receiveValue: { tasks in
                    // Then
                    XCTAssertEqual(tasks.count, 2) // Only 2 tasks are completed
                    XCTAssertTrue(tasks.allSatisfy { $0.isCompleted })
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testGetPendingTasksSuccess() {
        // Given
        let expectation = XCTestExpectation(description: "Get pending tasks successful")
        
        let mockTasks = [
            Task(id: UUID(), title: "Task 1", priority: .high, isCompleted: false),
            Task(id: UUID(), title: "Task 2", priority: .medium, isCompleted: true),
            Task(id: UUID(), title: "Task 3", priority: .low, isCompleted: true),
            Task(id: UUID(), title: "Task 4", priority: .high, isCompleted: false)
        ]
        
        // Configure mock repository
        mockTaskRepository.getTasksResult = .success(mockTasks)
        
        // When - Get pending tasks
        getTasksUseCase.execute(isCompleted: false)
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        XCTFail("Get pending tasks should succeed")
                    }
                },
                receiveValue: { tasks in
                    // Then
                    XCTAssertEqual(tasks.count, 2) // Only 2 tasks are pending
                    XCTAssertTrue(tasks.allSatisfy { !$0.isCompleted })
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testEmptyTasksListSuccess() {
        // Given
        let expectation = XCTestExpectation(description: "Get empty tasks list successful")
        
        // Configure mock repository to return empty list
        mockTaskRepository.getTasksResult = .success([])
        
        // When
        getTasksUseCase.execute()
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        XCTFail("Get empty tasks list should succeed")
                    }
                },
                receiveValue: { tasks in
                    // Then
                    XCTAssertTrue(tasks.isEmpty)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
}
