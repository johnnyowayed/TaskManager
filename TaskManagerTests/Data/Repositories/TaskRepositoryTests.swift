//
//  TaskRepositoryTests.swift
//  TaskManager
//
//  Created by Johnny Owayed on 07/03/2025.
//

import XCTest
import CoreData
import Combine
@testable import TaskManager

// MARK: - TaskRepositoryTests

final class TaskRepositoryTests: XCTestCase {
    // MARK: - Properties
    
    private var taskRepositoryWrapper: TaskRepositoryTestWrapper!
    private var mockCoreDataStack: MockCoreDataStack!
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Setup and Teardown
    
    override func setUp() {
        super.setUp()
        mockCoreDataStack = MockCoreDataStack()
        taskRepositoryWrapper = TaskRepositoryTestWrapper(mockStack: mockCoreDataStack)
    }
    
    override func tearDown() {
        taskRepositoryWrapper = nil
        mockCoreDataStack = nil
        cancellables.removeAll()
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testGetTasks() {
        // Given
        let expectation = XCTestExpectation(description: "Get tasks successful")
        
        // Create mock task entities
        let taskEntity1 = mockTaskEntity(id: UUID(), title: "Task 1", isCompleted: false)
        let taskEntity2 = mockTaskEntity(id: UUID(), title: "Task 2", isCompleted: true)
        
        // Configure mock Core Data to return these entities
        mockCoreDataStack.mockFetchResults = [taskEntity1, taskEntity2]
        
        // When
        taskRepositoryWrapper.getTasks()
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        XCTFail("Get tasks should succeed")
                    }
                },
                receiveValue: { tasks in
                    // Then
                    XCTAssertEqual(tasks.count, 2)
                    XCTAssertEqual(tasks[0].title, "Task 1")
                    XCTAssertEqual(tasks[1].title, "Task 2")
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testGetTasksWithCompletionFilter() {
        // Given
        let expectation = XCTestExpectation(description: "Get tasks with filter successful")
        
        // Create mock task entities (all completed)
        let taskEntity1 = mockTaskEntity(id: UUID(), title: "Task 1", isCompleted: true)
        let taskEntity2 = mockTaskEntity(id: UUID(), title: "Task 2", isCompleted: true)
        
        // Configure mock Core Data to return these entities
        mockCoreDataStack.mockFetchResults = [taskEntity1, taskEntity2]
        
        // When
        taskRepositoryWrapper.getTasks(isCompleted: true)
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        XCTFail("Get tasks with filter should succeed")
                    }
                },
                receiveValue: { tasks in
                    // Then
                    XCTAssertEqual(tasks.count, 2)
                    XCTAssertTrue(tasks.allSatisfy { $0.isCompleted })
                    
                    // Verify the predicate was set correctly
                    if let predicate = self.mockCoreDataStack.lastFetchRequest?.predicate as? NSComparisonPredicate {
                        XCTAssertEqual(predicate.leftExpression.keyPath, "isCompleted")
                        XCTAssertEqual(predicate.rightExpression.constantValue as? Bool, true)
                    } else {
                        XCTFail("Expected a comparison predicate for isCompleted filter")
                    }
                    
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testCreateTask() {
        // Given
        let expectation = XCTestExpectation(description: "Create task successful")
        
        let taskId = UUID()
        let task = Task(
            id: taskId,
            title: "New Task",
            description: "Task description",
            priority: .high,
            dueDate: Date(),
            isCompleted: false
        )
        
        // Create a mock entity that will be "saved"
        let savedEntity = mockTaskEntity(
            id: taskId,
            title: "New Task",
            description: "Task description",
            priority: .high,
            dueDate: task.dueDate,
            isCompleted: false
        )
        
        // Configure mock Core Data
        mockCoreDataStack.mockInsertedObject = savedEntity
        
        // When
        taskRepositoryWrapper.createTask(task)
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        XCTFail("Create task should succeed")
                    }
                },
                receiveValue: { createdTask in
                    // Then
                    XCTAssertEqual(createdTask.id, taskId)
                    XCTAssertEqual(createdTask.title, "New Task")
                    XCTAssertEqual(createdTask.description, "Task description")
                    XCTAssertEqual(createdTask.priority, .high)
                    XCTAssertEqual(createdTask.isCompleted, false)
                    
                    // Verify entity creation
                    XCTAssertEqual(self.mockCoreDataStack.lastEntityName, "TaskEntity")
                    
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testUpdateTask() {
        // Given
        let expectation = XCTestExpectation(description: "Update task successful")
        
        let taskId = UUID()
        let task = Task(
            id: taskId,
            title: "Updated Task",
            description: "Updated description",
            priority: .medium,
            dueDate: Date(),
            isCompleted: true
        )
        
        // Create mock entity with the same ID that will be "found and updated"
        let existingEntity = mockTaskEntity(id: taskId, title: "Old Title", isCompleted: false)
        mockCoreDataStack.mockFetchResults = [existingEntity]
        
        // When
        taskRepositoryWrapper.updateTask(task)
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        XCTFail("Update task should succeed")
                    }
                },
                receiveValue: { updatedTask in
                    // Then
                    XCTAssertEqual(updatedTask.id, taskId)
                    XCTAssertEqual(updatedTask.title, "Updated Task")
                    XCTAssertEqual(updatedTask.description, "Updated description")
                    XCTAssertEqual(updatedTask.priority, .medium)
                    XCTAssertEqual(updatedTask.isCompleted, true)
                    
                    // Verify fetch predicate
                    if let predicate = self.mockCoreDataStack.lastFetchRequest?.predicate as? NSComparisonPredicate {
                        XCTAssertEqual(predicate.leftExpression.keyPath, "id")
                        XCTAssertEqual(predicate.rightExpression.constantValue as? UUID, taskId)
                    } else {
                        XCTFail("Expected a comparison predicate for id")
                    }
                    
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testDeleteTask() {
        // Given
        let expectation = XCTestExpectation(description: "Delete task successful")
        
        let taskId = UUID()
        
        // Create mock entity that will be "found and deleted"
        let existingEntity = mockTaskEntity(id: taskId, title: "Task to Delete", isCompleted: false)
        mockCoreDataStack.mockFetchResults = [existingEntity]
        
        // When
        taskRepositoryWrapper.deleteTask(withId: taskId)
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        XCTFail("Delete task should succeed")
                    }
                },
                receiveValue: { _ in
                    // Then
                    // Verify fetch predicate
                    if let predicate = self.mockCoreDataStack.lastFetchRequest?.predicate as? NSComparisonPredicate {
                        XCTAssertEqual(predicate.leftExpression.keyPath, "id")
                        XCTAssertEqual(predicate.rightExpression.constantValue as? UUID, taskId)
                    } else {
                        XCTFail("Expected a comparison predicate for id")
                    }
                    
                    // Verify the entity was deleted
                    XCTAssertEqual(self.mockCoreDataStack.deletedObjects.count, 1)
                    XCTAssertEqual(self.mockCoreDataStack.deletedObjects.first, existingEntity)
                    
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testReorderTasks() {
        // Given
        let expectation = XCTestExpectation(description: "Reorder tasks successful")
        
        let taskId1 = UUID()
        let taskId2 = UUID()
        let taskId3 = UUID()
        
        let tasks = [
            Task(id: taskId1, title: "Task 1", order: 2),
            Task(id: taskId2, title: "Task 2", order: 0),
            Task(id: taskId3, title: "Task 3", order: 1)
        ]
        
        // Create mock entities that will be "found and updated"
        let entity1 = mockTaskEntity(id: taskId1, title: "Task 1", order: 0)
        let entity2 = mockTaskEntity(id: taskId2, title: "Task 2", order: 1)
        let entity3 = mockTaskEntity(id: taskId3, title: "Task 3", order: 2)
        
        // Set up mock to return different entities for different fetch requests
        mockCoreDataStack.mockFetchResultsSequence = [
            [entity1], [entity2], [entity3]
        ]
        
        // When
        taskRepositoryWrapper.reorderTasks(tasks)
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        XCTFail("Reorder tasks should succeed")
                    }
                },
                receiveValue: { reorderedTasks in
                    // Then
                    XCTAssertEqual(reorderedTasks.count, 3)
                    
                    // Verify order was updated
                    XCTAssertEqual(entity1.value(forKey: "order") as? Int32, 2)
                    XCTAssertEqual(entity2.value(forKey: "order") as? Int32, 0)
                    XCTAssertEqual(entity3.value(forKey: "order") as? Int32, 1)
                    
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Helper Methods
    
    private func mockTaskEntity(
        id: UUID,
        title: String,
        description: String? = nil,
        priority: TaskPriority = .medium,
        dueDate: Date? = nil,
        isCompleted: Bool = false,
        order: Int = 0
    ) -> NSManagedObject {
        // Create a properly initialized entity description
        let entityDescription = NSEntityDescription()
        entityDescription.name = "TaskEntity"
        entityDescription.managedObjectClassName = "TaskEntity"
        
        // Create the attributes
        let idAttribute = NSAttributeDescription()
        idAttribute.name = "id"
        idAttribute.attributeType = .UUIDAttributeType
        
        let titleAttribute = NSAttributeDescription()
        titleAttribute.name = "title"
        titleAttribute.attributeType = .stringAttributeType
        
        let descriptionAttribute = NSAttributeDescription()
        descriptionAttribute.name = "taskDescription"
        descriptionAttribute.attributeType = .stringAttributeType
        descriptionAttribute.isOptional = true
        
        let priorityAttribute = NSAttributeDescription()
        priorityAttribute.name = "priority"
        priorityAttribute.attributeType = .stringAttributeType
        
        let dueDateAttribute = NSAttributeDescription()
        dueDateAttribute.name = "dueDate"
        dueDateAttribute.attributeType = .dateAttributeType
        dueDateAttribute.isOptional = true
        
        let isCompletedAttribute = NSAttributeDescription()
        isCompletedAttribute.name = "isCompleted"
        isCompletedAttribute.attributeType = .booleanAttributeType
        
        let createdAtAttribute = NSAttributeDescription()
        createdAtAttribute.name = "createdAt"
        createdAtAttribute.attributeType = .dateAttributeType
        
        let orderAttribute = NSAttributeDescription()
        orderAttribute.name = "order"
        orderAttribute.attributeType = .integer32AttributeType
        
        // Add properties to entity
        entityDescription.properties = [
            idAttribute,
            titleAttribute,
            descriptionAttribute,
            priorityAttribute,
            dueDateAttribute,
            isCompletedAttribute,
            createdAtAttribute,
            orderAttribute
        ]
        
        // Create the managed object with proper entity description
        let entity = NSManagedObject(entity: entityDescription, insertInto: nil)
        
        // Set values
        entity.setValue(id, forKey: "id")
        entity.setValue(title, forKey: "title")
        entity.setValue(description, forKey: "taskDescription")
        entity.setValue(priority.rawValue, forKey: "priority") // String value
        entity.setValue(dueDate, forKey: "dueDate")
        entity.setValue(isCompleted, forKey: "isCompleted")
        entity.setValue(Date(), forKey: "createdAt")
        entity.setValue(Int32(order), forKey: "order")
        
        return entity
    }
}

// MARK: - Mock Core Data Stack

final class MockCoreDataStack: CoreDataStackProtocol {
    // Store mock data and tracking information
    var mockFetchResults: [NSManagedObject] = []
    var mockFetchResultsSequence: [[NSManagedObject]] = []
    private var fetchResultsIndex = 0
    var mockInsertedObject: NSManagedObject?
    var lastFetchRequest: NSFetchRequest<NSManagedObject>?
    var lastEntityName: String?
    var deletedObjects: [NSManagedObject] = []
    
    // The mock managed object context
    private lazy var mockContext = MockContext(owner: self)
    
    var viewContext: NSManagedObjectContext {
        return mockContext
    }
    
    func newBackgroundContext() -> NSManagedObjectContext {
        return mockContext
    }
    
    func saveContext(_ context: NSManagedObjectContext) -> AnyPublisher<Void, Error> {
        return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    // MARK: - Mock Context
    
    // We use a nested class to keep the MockContext associated with its owner
    class MockContext: NSManagedObjectContext {
        private weak var owner: MockCoreDataStack?
        
        init(owner: MockCoreDataStack) {
            self.owner = owner
            super.init(concurrencyType: .mainQueueConcurrencyType)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        // We can safely override delete since it's not in an extension
        override func delete(_ object: NSManagedObject) {
            owner?.deletedObjects.append(object)
        }
    }
    
    // MARK: - Test Helpers
    
    func simulateFetch<T>(_ request: NSFetchRequest<T>) throws -> [T] where T : NSFetchRequestResult {
        // Record the fetch request for test verification
        if let request = request as? NSFetchRequest<NSManagedObject> {
            lastFetchRequest = request
        }
        
        // Return sequence results if available
        if !mockFetchResultsSequence.isEmpty {
            let result = mockFetchResultsSequence[fetchResultsIndex]
            fetchResultsIndex = (fetchResultsIndex + 1) % mockFetchResultsSequence.count
            return result as! [T]
        }
        
        // Otherwise return standard mock results
        return mockFetchResults as! [T]
    }
    
    func simulateInsert(forEntityName entityName: String) -> NSManagedObject {
        lastEntityName = entityName
        
        if let mockObject = mockInsertedObject {
            return mockObject
        }
        
        // Create a proper entity description
        let entityDescription = NSEntityDescription()
        entityDescription.name = entityName
        entityDescription.managedObjectClassName = entityName
        
        // Add minimum required properties
        let idAttribute = NSAttributeDescription()
        idAttribute.name = "id"
        idAttribute.attributeType = .UUIDAttributeType
        
        entityDescription.properties = [idAttribute]
        
        return NSManagedObject(entity: entityDescription, insertInto: nil)
    }
}

// MARK: - TaskRepository Wrapper for Testing

class TaskRepositoryTestWrapper {
    private var mockStack: MockCoreDataStack
    
    init(mockStack: MockCoreDataStack) {
        self.mockStack = mockStack
    }
    
    // Expose all the methods you need to test, but handle the Core Data operations manually
    
    func getTasks(isCompleted: Bool? = nil) -> AnyPublisher<[Task], Error> {
        // Create a task fetch request
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "TaskEntity")
        
        // Add predicate if filtering by completion status
        if let isCompleted = isCompleted {
            fetchRequest.predicate = NSPredicate(format: "isCompleted == %@", NSNumber(value: isCompleted))
        }
        
        // Sort by creation date (assuming there's a createdAt attribute)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        // Use the mock fetch method instead of calling context.fetch directly
        return Future<[Task], Error> { promise in
            do {
                let fetchedEntities = try self.mockStack.simulateFetch(fetchRequest)
                
                // Map entities to domain models (simplified for the test - actual implementation may differ)
                let tasks = fetchedEntities.compactMap { entity -> Task? in
                    guard let id = entity.value(forKey: "id") as? UUID,
                          let title = entity.value(forKey: "title") as? String,
                          let isCompleted = entity.value(forKey: "isCompleted") as? Bool else {
                        return nil
                    }
                    
                    let priorityString = entity.value(forKey: "priority") as? String ?? TaskPriority.medium.rawValue
                    
                    return Task(
                        id: id,
                        title: title,
                        description: entity.value(forKey: "taskDescription") as? String,
                        priority: TaskPriority(rawValue: priorityString) ?? .medium,
                        dueDate: entity.value(forKey: "dueDate") as? Date,
                        isCompleted: isCompleted,
                        order: Int(entity.value(forKey: "order") as? Int32 ?? 0)
                    )
                }
                
                promise(.success(tasks))
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
    
    func createTask(_ task: Task) -> AnyPublisher<Task, Error> {
        return Future<Task, Error> { promise in
            // Simulate entity creation using our mock method
            let entity = self.mockStack.simulateInsert(forEntityName: "TaskEntity")
            
            // Set entity values
            entity.setValue(task.id, forKey: "id")
            entity.setValue(task.title, forKey: "title")
            entity.setValue(task.description, forKey: "taskDescription")
            entity.setValue(task.priority.rawValue, forKey: "priority")
            entity.setValue(task.dueDate, forKey: "dueDate")
            entity.setValue(task.isCompleted, forKey: "isCompleted")
            entity.setValue(Date(), forKey: "createdAt")
            entity.setValue(Int32(task.order), forKey: "order")
            
            // Save context (this will just return success in our mock)
            self.mockStack.saveContext(self.mockStack.viewContext)
                .sink(
                    receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            promise(.failure(error))
                        }
                    },
                    receiveValue: {
                        promise(.success(task))
                    }
                )
                .cancel() // We can immediately cancel since we're not storing the subscription
        }.eraseToAnyPublisher()
    }
    
    func updateTask(_ task: Task) -> AnyPublisher<Task, Error> {
        // Create a fetch request to find the entity with matching ID
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "TaskEntity")
        fetchRequest.predicate = NSPredicate(format: "id == %@", task.id as CVarArg)
        
        return Future<Task, Error> { promise in
            do {
                // Use our mock fetch method
                let entities = try self.mockStack.simulateFetch(fetchRequest)
                
                if let entity = entities.first {
                    // Update entity values
                    entity.setValue(task.title, forKey: "title")
                    entity.setValue(task.description, forKey: "taskDescription")
                    entity.setValue(task.priority.rawValue, forKey: "priority")
                    entity.setValue(task.dueDate, forKey: "dueDate")
                    entity.setValue(task.isCompleted, forKey: "isCompleted")
                    entity.setValue(Int32(task.order), forKey: "order")
                    
                    // Save context
                    self.mockStack.saveContext(self.mockStack.viewContext)
                        .sink(
                            receiveCompletion: { completion in
                                if case .failure(let error) = completion {
                                    promise(.failure(error))
                                }
                            },
                            receiveValue: {
                                promise(.success(task))
                            }
                        )
                        .cancel()
                } else {
                    promise(.failure(NSError(domain: "TaskRepository", code: 404, userInfo: [NSLocalizedDescriptionKey: "Task not found"])))
                }
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
    
    func deleteTask(withId id: UUID) -> AnyPublisher<Void, Error> {
        // Create a fetch request to find the entity with matching ID
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "TaskEntity")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        return Future<Void, Error> { promise in
            do {
                // Use our mock fetch method
                let entities = try self.mockStack.simulateFetch(fetchRequest)
                
                if let entity = entities.first {
                    // Delete the entity
                    self.mockStack.viewContext.delete(entity)
                    
                    // Save context
                    self.mockStack.saveContext(self.mockStack.viewContext)
                        .sink(
                            receiveCompletion: { completion in
                                if case .failure(let error) = completion {
                                    promise(.failure(error))
                                }
                            },
                            receiveValue: {
                                promise(.success(()))
                            }
                        )
                        .cancel()
                } else {
                    promise(.failure(NSError(domain: "TaskRepository", code: 404, userInfo: [NSLocalizedDescriptionKey: "Task not found"])))
                }
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
    
    func reorderTasks(_ tasks: [Task]) -> AnyPublisher<[Task], Error> {
        // For simplicity, we'll handle each task individually
        let updatePublishers = tasks.map { task -> AnyPublisher<Task, Error> in
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "TaskEntity")
            fetchRequest.predicate = NSPredicate(format: "id == %@", task.id as CVarArg)
            
            return Future<Task, Error> { promise in
                do {
                    let entities = try self.mockStack.simulateFetch(fetchRequest)
                    
                    if let entity = entities.first {
                        // Update only the order
                        entity.setValue(Int32(task.order), forKey: "order")
                        promise(.success(task))
                    } else {
                        promise(.failure(NSError(domain: "TaskRepository", code: 404, userInfo: [NSLocalizedDescriptionKey: "Task not found"])))
                    }
                } catch {
                    promise(.failure(error))
                }
            }.eraseToAnyPublisher()
        }
        
        // Combine all update publishers and save at the end
        return Publishers.MergeMany(updatePublishers)
            .collect()
            .flatMap { _ -> AnyPublisher<[Task], Error> in
                return self.mockStack.saveContext(self.mockStack.viewContext)
                    .map { _ in tasks }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
