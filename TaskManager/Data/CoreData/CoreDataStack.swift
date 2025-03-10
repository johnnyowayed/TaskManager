//
//  CoreDataStack.swift
//  TaskManager
//
//  Created by Johnny Owayed on 07/03/2025.
//

import Foundation
import CoreData
import Combine

// MARK: - Single Responsibility Principle (SRP)
// CoreDataStack is responsible only for managing the Core Data stack

final class CoreDataStack {
    // Singleton pattern with lazy initialization
    static let shared = CoreDataStack()
    
    // MARK: - Core Data stack
    
    private lazy var persistentContainer: NSPersistentContainer = {
        // Name should match your .xcdatamodeld file name
        let container = NSPersistentContainer(name: "TaskManager")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                // In a real app, you would implement proper error handling
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        // Merge policy to avoid conflicts
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return container
    }()
    
    // Main context for UI operations
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // Background context for async operations
    func newBackgroundContext() -> NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }
    
    // MARK: - Core Data Saving support
    
    // Save context and return a publisher
    func saveContext(_ context: NSManagedObjectContext) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            do {
                if context.hasChanges {
                    try context.save()
                    promise(.success(()))
                } else {
                    promise(.success(()))
                }
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
    
    // Private init to enforce singleton
    private init() {}
}
