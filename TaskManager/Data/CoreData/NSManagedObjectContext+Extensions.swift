//
//  NSManagedObjectContext+Extensions.swift
//  TaskManager
//
//  Created by Johnny Owayed on 07/03/2025.
//

import Foundation
import CoreData
import Combine

// Extension to add Combine support to NSManagedObjectContext
extension NSManagedObjectContext {
    // Perform work on the context and return a publisher
    func perform<T>(_ work: @escaping (NSManagedObjectContext) throws -> T) -> AnyPublisher<T, Error> {
        return Future<T, Error> { promise in
            self.perform {
                do {
                    let result = try work(self)
                    promise(.success(result))
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
}
