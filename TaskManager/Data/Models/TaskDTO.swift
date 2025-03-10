//
//  TaskDTO.swift
//  TaskManager
//
//  Created by Johnny Owayed on 07/03/2025.
//

import Foundation
import CoreData

// MARK: - Data Transfer Object (DTO) pattern
// Separates domain entities from data storage models

/// DTO for Task entity to/from CoreData conversion
struct TaskDTO {
    // MARK: - Core Data to Domain conversion
    
    /// Convert a TaskEntity (CoreData) to a domain Task
    /// - Parameter entity: The Core Data entity
    /// - Returns: A domain Task object
    static func toDomain(entity: NSManagedObject) -> Task? {
        guard
            let id = entity.value(forKey: "id") as? UUID,
            let title = entity.value(forKey: "title") as? String,
            let priorityString = entity.value(forKey: "priority") as? String,
            let priority = TaskPriority(rawValue: priorityString),
            let createdAt = entity.value(forKey: "createdAt") as? Date,
            let isCompleted = entity.value(forKey: "isCompleted") as? Bool
        else {
            return nil
        }
        
        return Task(
            id: id,
            title: title,
            description: entity.value(forKey: "taskDescription") as? String,
            priority: priority,
            dueDate: entity.value(forKey: "dueDate") as? Date,
            isCompleted: isCompleted,
            createdAt: createdAt,
            order: Int(entity.value(forKey: "order") as? Int32 ?? 0)
        )
    }
    
    // MARK: - Domain to Core Data conversion
    
    /// Update a TaskEntity with data from a domain Task
    /// - Parameters:
    ///   - entity: The Core Data entity to update
    ///   - task: The domain Task with the data
    static func updateEntity(_ entity: NSManagedObject, with task: Task) {
        entity.setValue(task.id, forKey: "id")
        entity.setValue(task.title, forKey: "title")
        entity.setValue(task.description, forKey: "taskDescription")
        entity.setValue(task.priority.rawValue, forKey: "priority")
        entity.setValue(task.dueDate, forKey: "dueDate")
        entity.setValue(task.isCompleted, forKey: "isCompleted")
        entity.setValue(task.createdAt, forKey: "createdAt")
        entity.setValue(Int32(task.order), forKey: "order")
    }
}
