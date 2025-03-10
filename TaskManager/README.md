# TaskManager

TaskManager is an iOS application that serves as an interactive task manager, showcasing advanced UI/UX skills with SwiftUI. The app features a visually appealing design, smooth animations, intuitive navigation, and accessibility support, all while adhering to Apple’s Human Interface Guidelines (HIG) and leveraging the latest iOS tools (iOS 18, Swift 5.10, SwiftUI 5).

## Features

### Core Features
- **Task Creation**: Add tasks with a title (required), description (optional), priority (Low, Medium, High), and due date (via a date picker).
- **Task List**: Display tasks in a dynamic, filterable list with sorting options (by priority, due date, or alphabetically) and filtering by status (All, Completed, Pending).
- **Task Details**: Show a detailed view for each task with options to mark it as completed or delete it.
- **Persistent Storage**: Use Core Data to save tasks locally, ensuring data persists across app restarts.

### UI/UX Design
- **SwiftUI**: Build the entire UI using SwiftUI 5 with modern components (e.g., NavigationStack, List, Button) and a responsive layout optimized for iPhone and iPad.
- **Theming**: Support light and dark modes with dynamic system colors and allow users to customize the accent color via a settings view.
- **Animations**: Animate task addition/removal with a fade-and-scale effect, use a spring animation when opening the task details view, and add a subtle pulse effect to the “Add Task” button when tapped.
- **Navigation**: Use NavigationStack for the home view (task list), task creation view, task details view, and settings view.

### Advanced UI Features
- **Drag-and-Drop**: Enable reordering of tasks in the list with haptic feedback (using onMove).
- **Swipe Gestures**: Support swipe-to-delete and swipe-to-complete actions with an undo option via Snackbar or Alert.
- **Custom Progress Indicator**: Design an animated circular progress ring showing the percentage of completed tasks, updating smoothly with withAnimation.
- **Empty State**: Create an engaging empty state UI with an illustration (e.g., SF Symbols) and a motivational message when no tasks exist.

### Accessibility
- Ensure all UI elements have proper accessibility labels and hints for VoiceOver.
- Support Dynamic Type for text scaling.
- Provide high-contrast mode compatibility.
- Enable keyboard navigation for task creation and list interaction.

### Performance and Polish
- Optimize list rendering with LazyVStack for smooth scrolling with 100+ tasks.
- Use @StateObject and @FetchRequest efficiently to minimize redraws.
- Implement a placeholder shimmer effect while Core Data loads initially.

### Testing
- Write UI tests using XCTest to verify task creation flow, sorting/filtering functionality, and animation triggers.
- Add snapshot tests (e.g., with SwiftUI Snapshot Testing) to validate UI across light/dark modes.

## Setup Instructions

### Prerequisites
- Xcode 15 or later
- iOS 18 SDK
- Swift 5.10

### Installation
1. Clone the repository:
    ```sh
    git clone https://github.com/johnnyowayed/TaskManager.git
    cd TaskManager
    ```

2. Open the project in Xcode:
    ```sh
    open TaskManager.xcodeproj
    ```

3. Build and run the project on a simulator or a physical device running iOS 18.

### Core Data Setup
The project uses Core Data for persistent storage. The Core Data model is included in the project and will be automatically set up when you run the app.

### Running Tests
The project includes UI tests and snapshot tests. To run the tests:
1. Select the `TaskManager` scheme in Xcode.
2. Press `Cmd+U` to run all tests.

## Design Rationale
The design of TaskManager follows Apple's Human Interface Guidelines (HIG) to ensure a consistent and intuitive user experience. The app leverages the latest SwiftUI components and iOS tools to provide a modern and responsive interface. Accessibility features are integrated to make the app usable for all users, including those with disabilities.

## License
This project is licensed under the MIT License. See the `LICENSE` file for details.

// help me push my code to my repository
// git add .
// git commit -m "message"
// git push origin main

