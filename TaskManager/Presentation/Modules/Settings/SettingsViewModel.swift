//
//  SettingsViewModel.swift
//  TaskManager
//
//  Created by Johnny Owayed on 07/03/2025.
//

import Foundation
import SwiftUI
import Combine

// Theme mode for the app
enum AppThemeMode: String, CaseIterable, Identifiable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
    
    var id: String { self.rawValue }
    
    var uiInterfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .light: return .light
        case .dark: return .dark
        case .system: return .unspecified
        }
    }
}

// MARK: - Color option for the settings
struct AccentColorOption: Identifiable {
    let id = UUID()
    let name: String
    let displayName: String
    let color: Color
}

// MARK: - ViewModel for app settings
import Foundation
import SwiftUI
import Combine

final class SettingsViewModel: ObservableObject {
    @AppStorage("accentColorName") var accentColorName: String = "blue"
    @AppStorage("isDynamicTypeEnabled") var isDynamicTypeEnabled: Bool = true
    @AppStorage("appThemeMode") var appThemeMode: String = AppThemeMode.system.rawValue
    @AppStorage("isHighContrastEnabled") var isHighContrastEnabled: Bool = false


    var selectedThemeMode: AppThemeMode {
        get {
            AppThemeMode(rawValue: appThemeMode) ?? .system
        }
        set {
            appThemeMode = newValue.rawValue
        }
    }

    let colorOptions: [AccentColorOption] = [
        AccentColorOption(name: "blue", displayName: "Blue", color: .blue),
        AccentColorOption(name: "red", displayName: "Red", color: .red),
        AccentColorOption(name: "green", displayName: "Green", color: .green),
        AccentColorOption(name: "purple", displayName: "Purple", color: .purple),
        AccentColorOption(name: "orange", displayName: "Orange", color: .orange),
        AccentColorOption(name: "pink", displayName: "Pink", color: .pink)
    ]

    var appVersion: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    var buildNumber: String {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    func setAccentColor(_ colorName: String) {
        accentColorName = colorName
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    func setThemeMode(_ mode: AppThemeMode) {
        selectedThemeMode = mode
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    func toggleHighContrast(_ enabled: Bool) {
        isHighContrastEnabled = enabled
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    func resetAllSettings() {
        accentColorName = "blue"
        isDynamicTypeEnabled = true
        selectedThemeMode = .system
        isHighContrastEnabled = false
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}
