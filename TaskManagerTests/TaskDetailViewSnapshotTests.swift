//
//  TaskDetailViewSnapshotTests.swift
//  TaskManager
//
//  Created by Johnny Owayed on 07/03/2025.
//

import XCTest
import SnapshotTesting
import SwiftUI
import Combine
@testable import TaskManager

final class TaskDetailViewSnapshotTests: XCTestCase {
    // MARK: - Properties
    
    private var viewModel: TaskDetailViewModel!
    private var mockGetTasksUseCase: MockGetTasksUseCase!
    private var mockUpdateTaskUseCase: MockUpdateTaskUseCase!
    private var mockDeleteTaskUseCase: MockDeleteTaskUseCase!
    
    // MARK: - Setup and Teardown
    
    override func setUp() {
        super.setUp()
        mockGetTasksUseCase = MockGetTasksUseCase()
        mockUpdateTaskUseCase = MockUpdateTaskUseCase()
        mockDeleteTaskUseCase = MockDeleteTaskUseCase()
        
        let taskId = UUID(uuidString: "E621E1F8-C36C-495A-93FC-0C247A3E6E5F")!
        viewModel = TaskDetailViewModel(
            taskId: taskId,
            getTaskUseCase: mockGetTasksUseCase,
            updateTaskUseCase: mockUpdateTaskUseCase,
            deleteTaskUseCase: mockDeleteTaskUseCase
        )
    }
    
    override func tearDown() {
        viewModel = nil
        mockGetTasksUseCase = nil
        mockUpdateTaskUseCase = nil
        mockDeleteTaskUseCase = nil
        super.tearDown()
    }
    
    // MARK: - Snapshot Tests
    
    func testTaskDetailView() throws {
        
        viewModel.isLoading = false
        // Given a view model with a task
        let taskId = UUID(uuidString: "E621E1F8-C36C-495A-93FC-0C247A3E6E5F")!
        let task = Task(
            id: taskId,
            title: "Complete iOS exercise",
            description: "Implement a task manager using SwiftUI and Core Data with SOLID principles.",
            priority: .high,
            dueDate: Date.snapshotTestDatePlusOneDay, // Tomorrow
            isCompleted: false,
            createdAt: Date.snapshotTestDate,
            order: 0
        )
        
        viewModel.task = task
        
        // Create the view
        let view = NavigationStack {
            TaskDetailView(viewModel: self.viewModel)
        }
        
        let viewController = view.toViewController()
            viewController.overrideUserInterfaceStyle = .light
        // Then the snapshot should match
        assertSnapshot(of: viewController, as: .image(on: .iPhone13Pro))
    }
    
    func testTaskDetailViewWithCompletedTask() throws {
        // Given a view model with a completed task
        viewModel.isLoading = false
        let taskId = UUID(uuidString: "E621E1F8-C36C-495A-93FC-0C247A3E6E5F")!
        let task = Task(
            id: taskId,
            title: "Completed task",
            description: "This task has been completed.",
            priority: .medium,
            dueDate: nil,
            isCompleted: true,
            createdAt: Date.snapshotTestDateMinusOneDay, // Yesterday
            order: 0
        )
        
        viewModel.task = task
        
        // Create the view
        let view = NavigationStack {
            TaskDetailView(viewModel: self.viewModel)
        }
        
        let viewController = view.toViewController()
            viewController.overrideUserInterfaceStyle = .light
        
        // Then the snapshot should match
        assertSnapshot(of: viewController, as: .image(on: .iPhone13Pro))
    }
    
    func testTaskDetailViewWithMinimalTask() throws {
        // Given a view model with a minimal task (no description, no due date)
        self.viewModel.isLoading = false
        let taskId = UUID(uuidString: "E621E1F8-C36C-495A-93FC-0C247A3E6E5F")!
        let task = Task(
            id: taskId,
            title: "Minimal Task",
            description: nil,
            priority: .low,
            dueDate: nil,
            isCompleted: false,
            createdAt: Date.snapshotTestDate,
            order: 0
        )
        
        viewModel.task = task
        
        // Create the view
        let view = NavigationStack {
            TaskDetailView(viewModel: self.viewModel)
        }
        
        let viewController = view.toViewController()
            viewController.overrideUserInterfaceStyle = .light
        // Then the snapshot should match
        assertSnapshot(of: viewController, as: .image(on: .iPhone13Pro))
    }
    
    func testTaskDetailViewLoading() throws {
        // Given a view model in loading state
        viewModel.isLoading = true
        
        // Create the view
        let view = NavigationStack {
            TaskDetailView(viewModel: self.viewModel)
        }
        
        // Then the snapshot should match
        let viewController = view.toViewController()
        viewController.overrideUserInterfaceStyle = .light
        
        assertSnapshot(of: viewController, as: .image(on: .iPhone13Pro))
    }
    
    func testTaskDetailViewTaskNotFound() throws {
        // Given a view model with no task (task not found)
        viewModel.task = nil
        viewModel.isLoading = false
        
        // Create the view
        let view = NavigationStack {
            TaskDetailView(viewModel: self.viewModel)
        }
        
        let viewController = view.toViewController()
        viewController.overrideUserInterfaceStyle = .light
        
        // Then the snapshot should match
        assertSnapshot(of: viewController, as: .image(on: .iPhone13Pro))
    }
    
    func testTaskDetailViewUpdating() throws {
        // Given a view model with a task in updating state
        viewModel.isLoading = false
        let taskId = UUID(uuidString: "E621E1F8-C36C-495A-93FC-0C247A3E6E5F")!
        let task = Task(
            id: taskId,
            title: "Complete iOS exercise",
            description: "Implement a task manager using SwiftUI and Core Data with SOLID principles.",
            priority: .high,
            dueDate: Date.snapshotTestDatePlusOneDay, // Tomorrow
            isCompleted: false,
            createdAt: Date.snapshotTestDate,
            order: 0
        )
        
        viewModel.task = task
        viewModel.isUpdating = true
        
        // Create the view
        let view = NavigationStack {
            TaskDetailView(viewModel: self.viewModel)
        }
        let viewController = view.toViewController()
        viewController.overrideUserInterfaceStyle = .light
        // Then the snapshot should match
        assertSnapshot(of: viewController, as: .image(on: .iPhone13Pro))
    }
    
    func testTaskDetailViewDarkMode() throws {
        // Given a view model with a task
        viewModel.isLoading = false
        
        let taskId = UUID(uuidString: "E621E1F8-C36C-495A-93FC-0C247A3E6E5F")!
        let task = Task(
            id: taskId,
            title: "Complete iOS exercise",
            description: "Implement a task manager using SwiftUI and Core Data with SOLID principles.",
            priority: .high,
            dueDate: Date.snapshotTestDatePlusOneDay,
            isCompleted: false,
            createdAt: Date.snapshotTestDate,
            order: 0
        )
        
        viewModel.task = task
        
        // Create the view
        let view = NavigationStack {
            TaskDetailView(viewModel: self.viewModel)
        }
        
        let viewController = view.toViewController()
        viewController.overrideUserInterfaceStyle = .dark
        
        // Then the snapshot in dark mode should match
        assertSnapshot(of: viewController, as: .image(on: .iPhone13Pro))
    }
    
    func testTaskDetailViewWithCompletedTaskDarkMode() throws {
        // Given a view model with a completed task
        viewModel.isLoading = false
        let taskId = UUID(uuidString: "E621E1F8-C36C-495A-93FC-0C247A3E6E5F")!
        let task = Task(
            id: taskId,
            title: "Completed task",
            description: "This task has been completed.",
            priority: .medium,
            dueDate: nil,
            isCompleted: true,
            createdAt: Date.snapshotTestDateMinusOneDay, // Yesterday
            order: 0
        )
        
        viewModel.task = task
        
        // Create the view
        let view = NavigationStack {
            TaskDetailView(viewModel: self.viewModel)
        }
        
        let viewController = view.toViewController()
        viewController.overrideUserInterfaceStyle = .dark
        
        // Then the snapshot should match
        assertSnapshot(of: viewController, as: .image(on: .iPhone13Pro))
    }
    
    func testTaskDetailViewWithMinimalTaskDarkMode() throws {
        // Given a view model with a minimal task (no description, no due date)
        viewModel.isLoading = false
        let taskId = UUID(uuidString: "E621E1F8-C36C-495A-93FC-0C247A3E6E5F")!
        let task = Task(
            id: taskId,
            title: "Minimal Task",
            description: nil,
            priority: .low,
            dueDate: nil,
            isCompleted: false,
            createdAt: Date.snapshotTestDate,
            order: 0
        )
        
        viewModel.task = task
        
        // Create the view
        let view = NavigationStack {
            TaskDetailView(viewModel: self.viewModel)
        }
        
        let viewController = view.toViewController()
        viewController.overrideUserInterfaceStyle = .dark
        // Then the snapshot should match
        assertSnapshot(of: viewController, as: .image(on: .iPhone13Pro))
    }
    
    func testTaskDetailViewLoadingDarkMode() throws {
        // Given a view model in loading state
        viewModel.isLoading = true
        
        // Create the view
        let view = NavigationStack {
            TaskDetailView(viewModel: self.viewModel)
        }
        
        // Then the snapshot should match
        let viewController = view.toViewController()
        viewController.overrideUserInterfaceStyle = .dark
        
        assertSnapshot(of: viewController, as: .image(on: .iPhone13Pro))
    }
    
    func testTaskDetailViewTaskNotFoundDarkMode() throws {
        // Given a view model with no task (task not found)
        viewModel.task = nil
        viewModel.isLoading = false
        
        // Create the view
        let view = NavigationStack {
            TaskDetailView(viewModel: self.viewModel)
        }
        
        let viewController = view.toViewController()
        viewController.overrideUserInterfaceStyle = .dark
        
        // Then the snapshot should match
        assertSnapshot(of: viewController, as: .image(on: .iPhone13Pro))
    }
    
    func testTaskDetailViewUpdatingDarkMode() throws {
        // Given a view model with a task in updating state
        viewModel.isLoading = false
        let taskId = UUID(uuidString: "E621E1F8-C36C-495A-93FC-0C247A3E6E5F")!
        let task = Task(
            id: taskId,
            title: "Complete iOS exercise",
            description: "Implement a task manager using SwiftUI and Core Data with SOLID principles.",
            priority: .high,
            dueDate: Date.snapshotTestDatePlusOneDay,
            isCompleted: false,
            createdAt: Date.snapshotTestDate,
            order: 0
        )
        
        viewModel.task = task
        viewModel.isUpdating = true
        
        // Create the view
        let view = NavigationStack {
            TaskDetailView(viewModel: self.viewModel)
        }
        let viewController = view.toViewController()
        viewController.overrideUserInterfaceStyle = .dark
        // Then the snapshot should match
        assertSnapshot(of: viewController, as: .image(on: .iPhone13Pro))
    }
}
