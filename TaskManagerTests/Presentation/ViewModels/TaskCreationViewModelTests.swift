//
//  TaskCreationViewModelTests.swift
//  TaskManager
//
//  Created by Johnny Owayed on 07/03/2025.
//

import XCTest
import Combine
@testable import TaskManager

final class TaskCreationViewModelTests: XCTestCase {
    // MARK: - Properties
    
    private var viewModel: TaskCreationViewModel!
    private var mockCreateTaskUseCase: MockCreateTaskUseCase!
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Setup and Teardown
    
    override func setUp() {
        super.setUp()
        mockCreateTaskUseCase = MockCreateTaskUseCase()
        viewModel = TaskCreationViewModel(createTaskUseCase: mockCreateTaskUseCase)
    }
    
    override func tearDown() {
        viewModel = nil
        mockCreateTaskUseCase = nil
        cancellables.removeAll()
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testInitialState() {
        // Then - verify default values
        XCTAssertEqual(viewModel.title, "")
        XCTAssertEqual(viewModel.description, "")
        XCTAssertEqual(viewModel.priority, .medium)
        XCTAssertTrue(viewModel.enableDueDate)
        XCTAssertFalse(viewModel.isTitleValid)
        XCTAssertFalse(viewModel.isFormValid)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isCreating)
        XCTAssertFalse(viewModel.didCreateTask)
    }
    
    func testTitleValidation() {
        // When - set valid title
        viewModel.title = "Valid Task Title"
        
        // Then - form should be valid
        XCTAssertTrue(viewModel.isTitleValid)
        XCTAssertTrue(viewModel.isFormValid)
        
        // When - set empty title
        viewModel.title = ""
        
        // Then - form should be invalid
        XCTAssertFalse(viewModel.isTitleValid)
        XCTAssertFalse(viewModel.isFormValid)
        
        // When - set whitespace-only title
        viewModel.title = "   "
        
        // Then - should be invalid after trimming
        XCTAssertFalse(viewModel.isTitleValid)
        XCTAssertFalse(viewModel.isFormValid)
    }
    
    func testCreateTaskSuccess() {
        // Given
        let expectation = XCTestExpectation(description: "Task creation successful")
        let taskTitle = "New Test Task"
        let taskDescription = "Test Description"
        
        viewModel.title = taskTitle
        viewModel.description = taskDescription
        viewModel.priority = .high
        
        // Mock use case to return success
        let createdTask = Task(
            id: UUID(),
            title: taskTitle,
            description: taskDescription,
            priority: .high,
            dueDate: viewModel.dueDate,
            isCompleted: false
        )
        mockCreateTaskUseCase.mockResult = .success(createdTask)
        
        // Track state changes
        viewModel.$didCreateTask
            .dropFirst() // Skip initial value
            .sink { didCreate in
                if didCreate {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When
        viewModel.createTask()
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertTrue(viewModel.didCreateTask)
        XCTAssertFalse(viewModel.isCreating)
        XCTAssertNil(viewModel.errorMessage)
        
        // Verify use case was called with correct parameters
        XCTAssertEqual(mockCreateTaskUseCase.lastTitle, taskTitle)
        XCTAssertEqual(mockCreateTaskUseCase.lastDescription, taskDescription)
        XCTAssertEqual(mockCreateTaskUseCase.lastPriority, .high)
        XCTAssertEqual(mockCreateTaskUseCase.lastDueDate!.timeIntervalSince1970, viewModel.dueDate.timeIntervalSince1970, accuracy: 1.0)
    }
    
    func testCreateTaskWithoutDueDate() {
        // Given
        let expectation = XCTestExpectation(description: "Task creation without due date")
        let taskTitle = "Task without due date"
        
        viewModel.title = taskTitle
        viewModel.enableDueDate = false
        
        // Mock use case to return success
        let createdTask = Task(
            id: UUID(),
            title: taskTitle,
            dueDate: nil,
            isCompleted: false
        )
        mockCreateTaskUseCase.mockResult = .success(createdTask)
        
        // When
        viewModel.createTask()
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Verify use case was called with nil due date
            XCTAssertEqual(self.mockCreateTaskUseCase.lastTitle, taskTitle)
            XCTAssertNil(self.mockCreateTaskUseCase.lastDueDate)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testCreateTaskFailure() {
        // Given
        let expectation = XCTestExpectation(description: "Task creation failure")
        let expectedError = NSError(domain: "test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to create task"])
        
        viewModel.title = "Task with error"
        mockCreateTaskUseCase.mockResult = .failure(expectedError)
        
        // When
        viewModel.createTask()
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.viewModel.errorMessage, expectedError.localizedDescription)
            XCTAssertFalse(self.viewModel.isCreating)
            XCTAssertFalse(self.viewModel.didCreateTask)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testCreateTaskWithInvalidForm() {
        // Given
        viewModel.title = ""  // Invalid title
        
        // When
        viewModel.createTask()
        
        // Then
        XCTAssertFalse(viewModel.isCreating)
        XCTAssertFalse(viewModel.didCreateTask)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.errorMessage, "Please provide a title for your task")
    }
    
    func testResetForm() {
        // Given
        viewModel.title = "Task Title"
        viewModel.description = "Description"
        viewModel.priority = .high
        viewModel.enableDueDate = false
        viewModel.errorMessage = "Some error"
        viewModel.didCreateTask = true
        
        // When
        viewModel.resetForm()
        
        // Then
        XCTAssertEqual(viewModel.title, "")
        XCTAssertEqual(viewModel.description, "")
        XCTAssertEqual(viewModel.priority, .medium)
        XCTAssertTrue(viewModel.enableDueDate)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.didCreateTask)
    }
}

// MARK: - Mock CreateTaskUseCase for testing

final class MockCreateTaskUseCase: CreateTaskUseCaseProtocol {
    var mockResult: Result<Task, Error> = .success(Task(title: ""))
    
    // Capture parameters for verification
    var lastTitle: String?
    var lastDescription: String?
    var lastPriority: TaskPriority?
    var lastDueDate: Date?
    
    func execute(title: String, description: String?, priority: TaskPriority, dueDate: Date?) -> AnyPublisher<Task, Error> {
        // Save parameters
        self.lastTitle = title
        self.lastDescription = description
        self.lastPriority = priority
        self.lastDueDate = dueDate
        
        // Return mock result
        switch mockResult {
        case .success(let task):
            return Just(task)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        case .failure(let error):
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
    }
}
