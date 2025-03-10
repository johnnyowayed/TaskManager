//
//  TaskCreationViewModel.swift
//  TaskManager
//
//  Created by Johnny Owayed on 07/03/2025.
//

import Foundation
import Combine
import UIKit

// MARK: - ViewModel for task creation - MVVM pattern
final class TaskCreationViewModel: ObservableObject {
    // MARK: - Form state properties
    
    @Published var title: String = ""
    @Published var description: String = ""
    @Published var priority: TaskPriority = .medium
    @Published var dueDate: Date = Date().addingTimeInterval(86400) // Tomorrow by default
    @Published var enableDueDate: Bool = true
    
    // MARK: - Form validation
    
    @Published var isTitleValid: Bool = false
    @Published var isFormValid: Bool = false
    @Published var errorMessage: String?
    @Published var isCreating: Bool = false
    @Published var didCreateTask: Bool = false
    
    // MARK: - Dependencies
    
    private let createTaskUseCase: CreateTaskUseCaseProtocol
    
    // MARK: - Cancellables
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init(createTaskUseCase: CreateTaskUseCaseProtocol) {
        self.createTaskUseCase = createTaskUseCase
        setupValidation()
    }
    
    
    
    // MARK: - Private methods
    
    private func setupValidation() {
        // Validate title (non-empty)
        $title
            .map { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .assign(to: &$isTitleValid)
        
        // Overall form validation
        $isTitleValid
            .assign(to: &$isFormValid)
    }
    
    // MARK: - Public methods
    
    func createTask() {
        guard isFormValid else {
            errorMessage = "Please provide a title for your task"
            return
        }
        
        isCreating = true
        
        // Use the optional dueDate based on enableDueDate toggle
        let taskDueDate = enableDueDate ? dueDate : nil
        
        createTaskUseCase.execute(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.isEmpty ? nil : description,
            priority: priority,
            dueDate: taskDueDate
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                self?.isCreating = false
                
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            },
            receiveValue: { [weak self] _ in
                self?.didCreateTask = true
                
                // Add haptic feedback
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
            }
        )
        .store(in: &cancellables)
    }
    
    // Reset form for a new task
    func resetForm() {
        title = ""
        description = ""
        priority = .medium
        dueDate = Date().addingTimeInterval(86400)
        enableDueDate = true
        errorMessage = nil
        didCreateTask = false
    }
}
