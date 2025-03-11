# TaskMaster Pro

<div align="center">
  <img src="https://via.placeholder.com/150" alt="TaskMaster Pro Logo"/>
  <p><em>Elevate your productivity with a beautifully designed task management experience</em></p>
  
  ![Swift](https://img.shields.io/badge/Swift-5.10-orange)
  ![iOS](https://img.shields.io/badge/iOS-18.0+-blue)
  ![SwiftUI](https://img.shields.io/badge/SwiftUI-5-green)
  ![License](https://img.shields.io/badge/License-MIT-lightgrey)
</div>

## ✨ Overview

TaskMaster Pro is a feature-rich task management application built with the latest iOS technologies. Designed with a focus on beautiful UI, intuitive UX, and robust architecture, this app showcases advanced SwiftUI implementations while maintaining clean, maintainable code through SOLID principles and the MVVM pattern.

<div align="center">
  <img src="https://via.placeholder.com/200x400" alt="App Screenshot 1"/>
  <img src="https://via.placeholder.com/200x400" alt="App Screenshot 2"/>
  <img src="https://via.placeholder.com/200x400" alt="App Screenshot 3"/>
</div>

## 🌟 Key Features

- **Task Management**: Create, view, edit, and delete tasks with comprehensive details
- **Rich Sorting & Filtering**: Organize tasks by priority, due date, or alphabetically
- **Customizable Themes**: Switch between light and dark modes with customizable accent colors
- **Fluid Animations**: Enjoy polished animations for all interactions
- **Drag & Drop Reordering**: Intuitively reorganize your task list with haptic feedback
- **Gesture Controls**: Quick actions with swipe gestures and contextual feedback
- **Visual Progress Tracking**: Monitor completion with a custom animated progress ring
- **Full Accessibility Support**: VoiceOver compatibility, Dynamic Type, and more
- **Persistent Storage**: Reliable data persistence with Core Data
- **Optimized Performance**: Smooth experience even with large task lists

## 🏗️ Architecture

TaskMaster Pro is built following industry best practices and modern architectural patterns:

### Clean Architecture

The application is structured into distinct layers with clear separation of concerns:

```
TaskMaster Pro/
├── Presentation/ (UI Layer)
│   ├── Views/
│   ├── ViewModels/
│   └── Components/
├── Domain/ (Business Logic)
│   ├── Models/
│   ├── Interfaces/
│   └── UseCases/
└── Data/ (Data Layer)
    ├── Repositories/
    ├── DataSources/
    └── CoreData/
```

### MVVM Pattern

Each screen follows the Model-View-ViewModel pattern:
- **Models**: Core domain entities representing tasks and related data
- **Views**: SwiftUI views focused purely on presentation
- **ViewModels**: Connecting the UI to business logic with reactive properties

### SOLID Principles

The codebase adheres to all SOLID principles:
- **Single Responsibility**: Each class has a single, well-defined purpose
- **Open/Closed**: Modules are open for extension but closed for modification
- **Liskov Substitution**: Subtypes are substitutable for their base types
- **Interface Segregation**: Clients are not forced to depend on interfaces they don't use
- **Dependency Inversion**: High-level modules depend on abstractions, not concrete implementations

## 🎨 UI/UX Highlights

- **SwiftUI 5 Components**: NavigationStack, LazyVStack, and the latest SwiftUI features
- **Custom Animations**: Spring animations, fade effects, and seamless transitions
- **Intuitive Navigation**: Logical flow between task list, creation, details, and settings
- **Empty State Design**: Engaging visuals and prompts when no tasks exist
- **Error Handling**: Graceful error presentation with actionable feedback
- **Shimmer Effects**: Elegant loading states for data retrieval

## 🛠️ Technical Details

- **Swift 5.10**: Latest language features for cleaner, safer code
- **iOS 18+**: Optimized for the latest iOS platform capabilities
- **SwiftUI 5**: Modern declarative UI framework
- **Core Data**: Robust data persistence with efficient queries
- **Combine**: Reactive programming for handling asynchronous events
- **Dependency Injection**: Protocol-based DI for testable code
- **Comprehensive Testing**: UI tests, snapshot tests, and unit tests

## 📱 Device Support

- iPhone (iOS 18.0+)
- iPad (iOS 18.0+)
- Support for both portrait and landscape orientations
- Responsive design for all screen sizes

## 🚀 Getting Started

### Prerequisites
- Xcode 16.0 or later
- iOS 18.0+ device or simulator

### Installation
1. Clone this repository
```bash
git clone https://github.com/johnnyowayed/TaskMaster.git
```

2. Open `TaskMasterPro.xcodeproj` in Xcode

3. Select your target device/simulator and hit Run

## 📋 Implementation Notes

### Core Data Model
The application uses a Core Data stack with the following entity structure:
- `Task` entity with attributes for title, description, priority, due date, and completion status
- Optimized fetch requests with NSPredicates for efficient filtering
- Batch operations for performance with large datasets

### Accessibility
- VoiceOver support with descriptive labels and hints
- Dynamic Type compatibility for all text elements
- Support for reduced motion preferences
- Color contrast considerations for all UI elements

### Testing Strategy
- UI Tests covering critical user flows
- Snapshot tests for UI consistency across device sizes and appearance modes
- Unit tests for business logic and data layer

## 🔮 Future Enhancements

- Cloud synchronization with iCloud
- Recurring tasks functionality
- Rich notifications with action buttons
- Widget support for home screen
- Siri shortcuts integration
- Apple Watch companion app

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Apple's Human Interface Guidelines
- SwiftUI community for inspiration

---

<div align="center">
  <p>Developed with ❤️ by Johnny Owayed</p>
</div>
