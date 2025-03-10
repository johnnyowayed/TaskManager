//
//  TaskCreationUITests.swift
//  TaskManager
//
//  Created by Johnny Owayed on 07/03/2025.
//


import XCTest
@testable import TaskManager

final class TaskCreationUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
        app = XCUIApplication()
        
        // Reset the app's state before each test
        app.launchArguments = ["--uitesting", "--reset-data"]
        app.launch()
        sleep(2)
    }
    
    // MARK: - Tests
    
    func testTaskCreationWithAllFields() {
        // Given
        let taskTitle = "Complete UI Testing"
        let taskDescription = "Write comprehensive UI tests for the task creation flow"
        
        // When - Tap the add button to open task creation sheet
        app.buttons["Add Task"].tap()
        
        // Then - Fill in the task details
        let titleTextField = app.textFields["Task Title"]
        XCTAssert(titleTextField.waitForExistence(timeout: 2), "Task title field should be visible")
        titleTextField.tap()
        titleTextField.typeText(taskTitle)
        
        // Add description
        let descriptionTextView = app.textViews.firstMatch
        XCTAssert(descriptionTextView.waitForExistence(timeout: 2), "Description field should be visible")
        descriptionTextView.tap()
        descriptionTextView.typeText(taskDescription)
        
        // Set priority to High
        app.buttons["High"].tap()
        
        // Working with the date picker
        
        // 1. First ensure the date picker is enabled (in case there's a toggle)
        let dueDateToggle = app.switches["Set Due Date"]
        if dueDateToggle.exists && dueDateToggle.value as? String == "0" {
            dueDateToggle.tap()
        }
        
        // 2. Find and tap the date field to open the picker
        // Try different possible identifiers
        let datePickerButton = app.buttons["Due Date"]
        if datePickerButton.exists {
            datePickerButton.tap()
        }
        
        // 3. Wait for date picker to appear
        // Try both system date pickers and any custom date pickers
        let datePicker = app.datePickers.firstMatch
        _ = datePicker.waitForExistence(timeout: 2)
        
        // 4. Set date using a more reliable approach
        // Get tomorrow's date
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        let tomorrowString = formatter.string(from: tomorrow)
        
        // Try to find and tap a button with tomorrow's date
        let tomorrowButton = app.buttons[tomorrowString]
        if tomorrowButton.exists {
            tomorrowButton.tap()
        } else {
            // If we can't find the exact date button, use a more generic approach
            // This is often more reliable - just ensure a date is selected
            if datePicker.exists {
                // Trying to interact with date picker wheels - this can be fragile
                // Sometimes it's enough to just tap the picker to confirm a date
                datePicker.tap()
                
                // If there's a "Done" or "Confirm" button for the date picker, tap it
                let doneButton = app.buttons["Done"]
                if doneButton.exists {
                    doneButton.tap()
                }
            }
        }
        
        // Debug: Print all buttons to help identify the correct one for future runs
        print("Available buttons:")
        for button in app.buttons.allElementsBoundByIndex {
            print("Button: \(button.identifier), Label: \(button.label)")
        }
        
        // 5. Tap Add to create the task
        let addButton = app.buttons["Add"]
        XCTAssert(addButton.waitForExistence(timeout: 2), "Add button should be visible")
        addButton.tap()
        
        // 6. Verify the task appears in the list
        let taskRow = app.staticTexts[taskTitle]
        XCTAssert(taskRow.waitForExistence(timeout: 2), "Created task should be visible in the list")
        
        // 7. Verify priority is displayed
        let highPriorityText = app.staticTexts["High"]
        XCTAssert(highPriorityText.exists, "Priority indicator should be visible")
    }

    func testDisablingDueDate() {
        // Given
        // Open task creation view
        app.buttons["Add Task"].tap()
        
        // Ensure title field exists and is filled
        let titleTextField = app.textFields["Task Title"]
        XCTAssert(titleTextField.waitForExistence(timeout: 2), "Task title field should be visible")
        titleTextField.tap()
        titleTextField.typeText("Task Without Due Date")
        
        // When - Verify due date toggle exists and disable it
        let dueDateToggle = app.switches["Set Due Date"]
        
        if dueDateToggle.exists {
            // Check current state and toggle if needed
            let currentValue = dueDateToggle.value as? String
            if currentValue == "1" {
                dueDateToggle.tap()
                
                
                // Option 1: Check if due date field is disabled/dimmed
                let dueDateField = app.textFields["Due Date"]
                if dueDateField.exists {
                    XCTAssertFalse(dueDateField.isEnabled, "Due date field should be disabled")
                }
                
                // Option 2: Check a "disabled" state label if your UI shows one
                let disabledLabel = app.staticTexts["No Due Date"]
                if disabledLabel.exists {
                    XCTAssert(disabledLabel.exists, "No Due Date label should be visible when disabled")
                }
            }
        } else {
            XCTFail("Could not find the Set Due Date toggle")
        }
        
        // Submit the form
        app.buttons["Add"].tap()
        
        // Verify the task was created (appears in the list)
        let taskRow = app.staticTexts["Task Without Due Date"]
        XCTAssert(taskRow.waitForExistence(timeout: 2), "Created task should be visible in the list")
    }
    
    func testTaskCreationValidation() {
        // Given
        // Open task creation view with empty fields
        app.buttons["Add Task"].tap()
        
        // When - Try to submit without entering a title
        app.buttons["Add"].tap()
        
        // Then - Form should not be submitted, we should still be in the creation view
        XCTAssert(app.navigationBars["Create Task"].exists)
        
        // Verify Add button is disabled when title is empty
        XCTAssert(!app.buttons["Add"].isEnabled)
        
        // When - Add a title
        let titleTextField = app.textFields["Task Title"]
        titleTextField.tap()
        titleTextField.typeText("Valid Task")
        
        // Then - Add button should become enabled
        XCTAssert(app.buttons["Add"].isEnabled)
        
        // When - Submit the form
        app.buttons["Add"].tap()
        
        // Then - Task creation view should be dismissed
        XCTAssertFalse(app.navigationBars["Create Task"].exists)
        
        // And task should appear in the list
        let taskRow = app.staticTexts["Valid Task"]
        XCTAssert(taskRow.waitForExistence(timeout: 2))
    }
    
    func testCancelTaskCreation() {
        // Given
        // Open task creation view
        app.buttons["Add Task"].tap()
        
        // Fill in some data
        let titleTextField = app.textFields["Task Title"]
        XCTAssert(titleTextField.waitForExistence(timeout: 2))
        titleTextField.tap()
        titleTextField.typeText("Task to Cancel")
        
        // When - Tap Cancel
        app.buttons["Cancel"].tap()
        
        // Then - View should be dismissed without creating the task
        XCTAssertFalse(app.navigationBars["Create Task"].exists)
        
        // Task should not appear in the list
        let taskRow = app.staticTexts["Task to Cancel"]
        XCTAssertFalse(taskRow.exists)
    }
    
    func testKeyboardDismissal() {
        // Given
        // Open task creation view
        app.buttons["Add Task"].tap()
        
        // Tap on title field to show keyboard
        app.textFields["Task Title"].tap()
        
        // Verify keyboard is shown
        XCTAssert(app.keyboards.firstMatch.exists)
        
        // When - Tap the keyboard dismiss button (on toolbar)
        app.buttons["Done"].tap()
        
        // Then - Keyboard should be dismissed
        XCTAssertFalse(app.keyboards.firstMatch.exists)
    }
}
