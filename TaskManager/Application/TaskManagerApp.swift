//
//  TaskManagerApp.swift
//  TaskManager
//
//  Created by Johnny Owayed on 07/03/2025.
//

import SwiftUI
import CoreData

// MARK: - Main application entry point
@main
struct TaskManagerApp: App {
    // MARK: - Environment
    
    @Environment(\.scenePhase) private var scenePhase
    
    // MARK: - AppStorage for user preferences
    
    @AppStorage("accentColorName") private var accentColorName: String = "blue"
    @AppStorage("isDynamicTypeEnabled") private var isDynamicTypeEnabled: Bool = true
    @AppStorage("isHighContrastEnabled") private var isHighContrastEnabled: Bool = false
    @AppStorage("appThemeMode") private var appThemeMode: String = AppThemeMode.system.rawValue
    
    // MARK: - State
    
    @State private var isFirstLaunch = true
    @State private var showLaunchScreen = true
    
    // MARK: - Properties
    
    // Core Data persistence controller
    private let persistenceController = PersistenceController.shared
    @Environment(\.colorSchemeContrast) var contrast: ColorSchemeContrast

    // MARK: - Computed properties
    
    private var accentColor: Color {
        switch accentColorName {
        case "red":
            return .red
        case "green":
            return .green
        case "purple":
            return .purple
        case "orange":
            return .orange
        case "pink":
            return .pink
        default:
            return .blue
        }
    }
    
    private var themeMode: AppThemeMode {
        return AppThemeMode(rawValue: appThemeMode) ?? .system
    }
    
    // MARK: - Body
    
    var body: some Scene {
        WindowGroup {
            ZStack{
                ContentView()
                    
                    .accentColor(accentColor)
                // Apply theme mode selection if not using system
                    .preferredColorScheme(colorScheme)
                // Apply high contrast if enabled
                    .contrast(isHighContrastEnabled ? 2.0 : 1.0) // 2.0 for increased 1.0 for standard
                // Handle dynamic type if disabled
                    .environment(
                        \.dynamicTypeSize,
                         isDynamicTypeEnabled ? .large : .medium
                    )
                // Inject Core Data context
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .onAppear {
                        if isFirstLaunch {
                            setupAppearance()
                            isFirstLaunch = false
                        }
                    }
                if showLaunchScreen {
//                    LaunchScreen(showLaunchScreen: $showLaunchScreen)
//                        .transition(.opacity)
//                        .zIndex(1) // Ensure launch screen is above content
                }
            }
            
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .background {
                persistenceController.saveContext()
            }
        }
    }
    
    // MARK: - Computed color scheme based on theme mode
    
    private var colorScheme: ColorScheme? {
        switch themeMode {
        case .light:
            return .light
        case .dark:
            return .dark
        case .system:
            return nil  // Follow system setting
        }
    }
    
    // MARK: - Setup methods
    
    private func setupAppearance() {
        // Configure global UI appearance
        UINavigationBar.appearance().largeTitleTextAttributes = [
            .foregroundColor: UIColor(accentColor)
        ]
        
        // Apply theme mode to UIKit components if not using system
        if themeMode != .system {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.overrideUserInterfaceStyle = themeMode.uiInterfaceStyle
            }
        }
    }
}

// MARK: - Main content view
struct ContentView: View {
    var body: some View {
        // Use the dependency injector to get the task list view
        DependencyInjector.shared.provideTaskListView()
    }
}

// MARK: - Core Data Persistence Controller
struct PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init() {
        container = NSPersistentContainer(name: "TaskManager")
        
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        
        // Set merge policy to avoid conflicts
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        // Handle UI Testing setup
        setupForUITesting()
    }
    
    // MARK: - UI Testing Setup
    
    private func setupForUITesting() {
        let arguments = ProcessInfo.processInfo.arguments
        
        if arguments.contains("--uitesting") {
            // Reset Core Data if requested
            if arguments.contains("--reset-data") {
                clearCoreDataStore()
            }
            
            // Add sample data if requested
            if arguments.contains("--sample-data") {
                createSampleData()
            }
        }
    }
    
    private func clearCoreDataStore() {
        let coordinator = container.persistentStoreCoordinator
        
        // Get all stores
        guard let storeURL = coordinator.persistentStores.first?.url else {
            print("No store URL found")
            return
        }
        
        do {
            // Remove the persistent store
            try coordinator.destroyPersistentStore(
                at: storeURL,
                ofType: NSSQLiteStoreType,
                options: nil
            )
            
            print("Successfully destroyed Core Data store")
            
            // Recreate the store
            try coordinator.addPersistentStore(
                ofType: NSSQLiteStoreType,
                configurationName: nil,
                at: storeURL,
                options: nil
            )
            
            print("Successfully recreated Core Data store")
            
            // Reset the context
            container.viewContext.reset()
            
        } catch {
            print("Failed to clear Core Data: \(error)")
        }
    }
    
    private func createSampleData() {
        let context = container.viewContext
        
        // Create sample tasks - adjust properties to match your Task entity
        createTask(title: "Buy groceries", priority: "Medium", isCompleted: false, context: context)
        createTask(title: "Finish project", priority: "High", isCompleted: false, context: context)
        createTask(title: "Call mom", priority: "Low", isCompleted: true, context: context)
        createTask(title: "Schedule dentist appointment", priority: "Medium", isCompleted: false, context: context)
        createTask(title: "Submit tax forms", priority: "High", isCompleted: true, context: context)
        
        // Save context
        do {
            try context.save()
            print("Sample data created successfully")
        } catch {
            print("Failed to create sample data: \(error)")
        }
    }
    
    private func createTask(title: String, priority: String, isCompleted: Bool, context: NSManagedObjectContext) {
        // Adjust the entity name and attributes to match your Core Data model
        let task = NSEntityDescription.insertNewObject(forEntityName: "TaskEntity", into: context) 
        task.setValue(title, forKey: "title")
        task.setValue(priority, forKey: "priority")
        task.setValue(isCompleted, forKey: "isCompleted")
        task.setValue(Date(), forKey: "createdAt")
        task.setValue(UUID(), forKey: "id")
    }
    
    // MARK: - Core Data Saving
    
    func saveContext() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
}


