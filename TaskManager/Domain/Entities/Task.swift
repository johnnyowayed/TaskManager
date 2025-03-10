//
//  Task.swift
//  TaskManager
//
//  Created by Johnny Owayed on 07/03/2025.
//

import Foundation

// MARK: - Single Responsibility Principle (SRP)
// The Task entity is responsible only for representing a task's data structure

// Enum for task priority levels
enum TaskPriority: String, CaseIterable, Identifiable, Codable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    
    var id: String { self.rawValue }
    
    // For UI representation
    var color: String {
        switch self {
        case .low: return "taskPriorityLow"
        case .medium: return "taskPriorityMedium"
        case .high: return "taskPriorityHigh"
        }
    }
}

// Struct for domain entity - follows immutability principle
struct Task: Identifiable, Equatable {
    let id: UUID
    let title: String
    let description: String?
    let priority: TaskPriority
    let dueDate: Date?
    let isCompleted: Bool
    let createdAt: Date
    let order: Int // For custom sorting
    
    // Constructor with default values - usability pattern
    init(
        id: UUID = UUID(),
        title: String,
        description: String? = nil,
        priority: TaskPriority = .medium,
        dueDate: Date? = nil,
        isCompleted: Bool = false,
        createdAt: Date = Date(),
        order: Int = 0
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.priority = priority
        self.dueDate = dueDate
        self.isCompleted = isCompleted
        self.createdAt = createdAt
        self.order = order
    }
    
    // Copy constructor with parameter overrides - immutability pattern
    func copy(
        title: String? = nil,
        description: String? = nil,
        priority: TaskPriority? = nil,
        dueDate: Date? = nil,
        isCompleted: Bool? = nil,
        order: Int? = nil
    ) -> Task {
        return Task(
            id: self.id, // Keep the same ID
            title: title ?? self.title,
            description: description ?? self.description,
            priority: priority ?? self.priority,
            dueDate: dueDate ?? self.dueDate,
            isCompleted: isCompleted ?? self.isCompleted,
            createdAt: self.createdAt, // Keep the same creation date
            order: order ?? self.order
        )
    }
    
    // Marking a task as completed - functional approach
    func markAsCompleted() -> Task {
        return self.copy(isCompleted: true)
    }
    
    // MARK: - Equatable implementation
    static func == (lhs: Task, rhs: Task) -> Bool {
        return lhs.id == rhs.id
    }
}
