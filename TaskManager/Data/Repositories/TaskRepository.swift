//
//  TaskRepository.swift
//  TaskManager
//
//  Created by Johnny Owayed on 07/03/2025.
//

import Foundation
import CoreData
import Combine

// MARK: - Liskov Substitution Principle (LSP)
// This implementation can be substituted anywhere the TaskRepositoryProtocol is used
protocol CoreDataStackProtocol {
    var viewContext: NSManagedObjectContext { get }
    func newBackgroundContext() -> NSManagedObjectContext
    func saveContext(_ context: NSManagedObjectContext) -> AnyPublisher<Void, Error>
}

// Make CoreDataStack conform to this protocol (no change to implementation)
extension CoreDataStack: CoreDataStackProtocol {}
/// CoreData implementation of the TaskRepositoryProtocol
final class TaskRepository: TaskRepositoryProtocol {
    // MARK: - Dependencies
    
    private let coreDataStack: CoreDataStackProtocol
    
    init(coreDataStack: CoreDataStackProtocol = CoreDataStack.shared) {
        self.coreDataStack = coreDataStack
    }
    
    // MARK: - TaskRepositoryProtocol Implementation
    
    func getTasks() -> AnyPublisher<[Task], Error> {
        let request = NSFetchRequest<NSManagedObject>(entityName: "TaskEntity")
        request.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]
        
        return coreDataStack.viewContext.perform { context in
            try context.fetch(request).compactMap { TaskDTO.toDomain(entity: $0) }
        }
    }
    
    func getTasks(isCompleted: Bool) -> AnyPublisher<[Task], Error> {
        let request = NSFetchRequest<NSManagedObject>(entityName: "TaskEntity")
        request.predicate = NSPredicate(format: "isCompleted == %@", NSNumber(value: isCompleted))
        request.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]
        
        return coreDataStack.viewContext.perform { context in
            try context.fetch(request).compactMap { TaskDTO.toDomain(entity: $0) }
        }
    }
    
    func getTask(withId id: UUID) -> AnyPublisher<Task?, Error> {
        let request = NSFetchRequest<NSManagedObject>(entityName: "TaskEntity")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        
        return coreDataStack.viewContext.perform { context in
            let results = try context.fetch(request)
            return results.first.flatMap { TaskDTO.toDomain(entity: $0) }
        }
    }
    
    func createTask(_ task: Task) -> AnyPublisher<Task, Error> {
        let context = coreDataStack.newBackgroundContext()
        
        return context.perform { ctx in
            // Create new entity
            let entity = NSEntityDescription.insertNewObject(
                forEntityName: "TaskEntity",
                into: ctx
            )
            
            // Set the entity values from task
            TaskDTO.updateEntity(entity, with: task)
            
            // Save context
            try ctx.save()
            
            // Ensure we have a valid domain object to return
            guard let savedTask = TaskDTO.toDomain(entity: entity) else {
                throw NSError(domain: "TaskRepository", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to convert entity to domain"])
            }
            
            return savedTask
        }
    }
    
    func updateTask(_ task: Task) -> AnyPublisher<Task, Error> {
        let context = coreDataStack.newBackgroundContext()
        
        return context.perform { ctx -> Task in
            // Find the entity to update
            let request = NSFetchRequest<NSManagedObject>(entityName: "TaskEntity")
            request.predicate = NSPredicate(format: "id == %@", task.id as CVarArg)
            
            let results = try ctx.fetch(request)
            
            guard let entity = results.first else {
                throw NSError(domain: "TaskRepository", code: 3, userInfo: [NSLocalizedDescriptionKey: "Task not found"])
            }
            
            // Update entity values
            TaskDTO.updateEntity(entity, with: task)
            
            // Save changes
            try ctx.save()
            
            // Return updated task
            guard let updatedTask = TaskDTO.toDomain(entity: entity) else {
                throw NSError(domain: "TaskRepository", code: 4, userInfo: [NSLocalizedDescriptionKey: "Failed to convert entity to domain"])
            }
            
            return updatedTask
        }
    }
    
    func deleteTask(withId id: UUID) -> AnyPublisher<Void, Error> {
        let context = coreDataStack.newBackgroundContext()
        
        return context.perform { ctx -> Void in
            // Find the entity to delete
            let request = NSFetchRequest<NSManagedObject>(entityName: "TaskEntity")
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            
            let results = try ctx.fetch(request)
            
            // Delete all matching entities (should be just one)
            for entity in results {
                ctx.delete(entity)
            }
            
            // Save changes
            try ctx.save()
            
            return ()
        }
    }
    
    func reorderTasks(_ tasks: [Task]) -> AnyPublisher<[Task], Error> {
        let context = coreDataStack.newBackgroundContext()
        
        return context.perform { ctx -> [Task] in
            var updatedTasks: [Task] = []
            
            // Update each task with its new order
            for task in tasks {
                let request = NSFetchRequest<NSManagedObject>(entityName: "TaskEntity")
                request.predicate = NSPredicate(format: "id == %@", task.id as CVarArg)
                
                let results = try ctx.fetch(request)
                
                guard let entity = results.first else {
                    continue
                }
                
                // Update order
                TaskDTO.updateEntity(entity, with: task)
                
                if let updatedTask = TaskDTO.toDomain(entity: entity) {
                    updatedTasks.append(updatedTask)
                }
            }
            
            // Save all changes
            try ctx.save()
            
            return updatedTasks
        }
    }
}
