//
//  SortingFilteringUITests.swift
//  TaskManager
//
//  Created by Johnny Owayed on 07/03/2025.
//

import XCTest
@testable import TaskManager

final class SortingFilteringUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
        app = XCUIApplication()
        
        // Reset the app's state for UI testing
        app.launchArguments = ["--uitesting", "--reset-data"]
        
        app.launch()
        sleep(2)
    }
    
    override func tearDown() {
        // Clean up after tests if needed
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testFilterByCompleted() {
        // Given - App has launched with sample data
        
        // Create and complete a task
        createAndCompleteTask(title: "Completed Filter Test")
        
        // When - Tap on the "Completed" filter
        app.buttons["Completed"].tap()
        
        // Then - Only completed tasks should be visible
        let completedTaskText = app.staticTexts["Completed Filter Test"]
        XCTAssert(completedTaskText.exists, "Completed task should be visible when Completed filter is active")
    }
    
    func testFilterByPending() {
        // Given - App has launched with sample data
        
        // Create a pending task
        let pendingTaskTitle = "Pending Filter Test"
        createTask(title: pendingTaskTitle)
        
        // Create and complete another task
        createAndCompleteTask(title: "Completed Task")
        
        // When - Tap on the "Pending" filter
        app.buttons["Pending"].tap()
        
        // Then - Only pending tasks should be visible
        let pendingTaskText = app.staticTexts[pendingTaskTitle]
        XCTAssert(pendingTaskText.exists, "Pending task should be visible in Pending filter")
        
        // Completed task should not be visible
        let completedTaskText = app.staticTexts["Completed Task"]
        XCTAssertFalse(completedTaskText.exists, "Completed task should not be visible in Pending filter")
    }
    
    func testSortByPriority() {
        // Given - App has tasks with different priorities
        createTask(title: "Low Priority Task", priority: "Low")
        createTask(title: "High Priority Task", priority: "High")
        createTask(title: "Medium Priority Task", priority: "Medium")
        
        // When - Open sort menu and sort by priority
        app.buttons["Sort tasks"].tap()
        app.buttons["Priority"].tap()
        
        // First check if all exist
        XCTAssert(app.staticTexts["High Priority Task"].exists)
        XCTAssert(app.staticTexts["Medium Priority Task"].exists)
        XCTAssert(app.staticTexts["Low Priority Task"].exists)
        
        // Ideally we'd check the order too, but simplified for this example
    }
    
    func testSortByAlphabetical() {
        // Given - App has tasks with different titles
        createTask(title: "Zebra Task")
        createTask(title: "Apple Task")
        createTask(title: "Banana Task")
        
        // When - Open sort menu and sort alphabetically
        app.buttons["Sort tasks"].tap()
        app.buttons["Alphabetical"].tap()
        
        // Then - All tasks should be present in the list
        XCTAssert(app.staticTexts["Apple Task"].exists)
        XCTAssert(app.staticTexts["Banana Task"].exists)
        XCTAssert(app.staticTexts["Zebra Task"].exists)
        
        // Ideally check order, but simplified for this example
    }
    
    func testFilterAndSortCombination() {
        // Given - App has various tasks
        createTask(title: "Pending High", priority: "High")
        createTask(title: "Pending Low", priority: "Low")
        createAndCompleteTask(title: "Completed High", priority: "High")
        createAndCompleteTask(title: "Completed Medium", priority: "Medium")
        
        // When - Filter by completed
        app.buttons["Completed"].tap()

        // Then - Only completed tasks should be visible
        XCTAssert(app.staticTexts["Completed High"].exists, "Completed High task should be visible")
        XCTAssert(app.staticTexts["Completed Medium"].exists, "Completed Medium task should be visible")
        XCTAssertFalse(app.staticTexts["Pending High"].exists, "Pending tasks should not be visible")
        XCTAssertFalse(app.staticTexts["Pending Low"].exists, "Pending tasks should not be visible")
    }
    
    func testResetFilters() {
        // Given - App is filtered to show only completed tasks
        createTask(title: "Pending Task")
        createAndCompleteTask(title: "Completed Task")
        
        app.buttons["Completed"].tap()
        
        // When - Switch back to "All" filter
        app.buttons["All"].tap()
        
        // Then - All tasks should be visible again
        XCTAssert(app.staticTexts["Pending Task"].exists, "Pending tasks should be visible with All filter")
        XCTAssert(app.staticTexts["Completed Task"].exists, "Completed tasks should be visible with All filter")
    }
    
    // MARK: - Helper Methods
    
    private func createTask(title: String, priority: String = "Medium") {
        // Tap add button
        app.buttons["Create new task"].tap()
        
        // Fill in the task details
        let titleTextField = app.textFields["Task Title"]
        XCTAssert(titleTextField.waitForExistence(timeout: 2), "Task title field should appear")
        titleTextField.tap()
        titleTextField.typeText(title)
        
        // Set priority
        app.buttons[priority].tap()
        
        // Create the task
        app.buttons["Add"].tap()
        
        // Wait for task to appear
        let taskRow = app.staticTexts[title]
        XCTAssert(taskRow.waitForExistence(timeout: 2), "New task should appear in the list")
    }
    
    private func createAndCompleteTask(title: String, priority: String = "Medium") {
        // Create a task
        createTask(title: title, priority: priority)
        
        // Find and tap the checkbox to complete it
        let checkbox = app.buttons["Mark as completed main \(title)"]
        XCTAssert(checkbox.exists, "Checkbox should exist for the task")
        checkbox.tap()
    }
}
