//
//  SettingsView.swift
//  TaskManager
//
//  Created by Johnny Owayed on 07/03/2025.
//

// Presentation/Modules/Settings/SettingsView.swift

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel: SettingsViewModel
    @State private var showingResetConfirmation = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    themeOptions
                } header: {
                    Text("Appearance")
                        .accessibilityAddTraits(.isHeader)
                }
                
                Section {
                    accessibilityOptions
                } header: {
                    Text("Accessibility")
                        .accessibilityAddTraits(.isHeader)
                }
                
                Section {
                    appInfo
                } header: {
                    Text("About")
                        .accessibilityAddTraits(.isHeader)
                }
                
                Section {
                    Button(role: .destructive) {
                        showingResetConfirmation = true
                    } label: {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                                .foregroundColor(.red)
                            Text("Reset All Settings")
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }.tint(Color.primary)
                }
            }
            .confirmationDialog(
                "Reset Settings?",
                isPresented: $showingResetConfirmation,
                titleVisibility: .visible
            ) {
                Button("Reset", role: .destructive) {
                    viewModel.resetAllSettings()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will reset all app settings to their default values.")
            }
        }
    }
    
    private var themeOptions: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Theme Mode")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Picker("App Theme", selection: Binding(
                    get: { viewModel.selectedThemeMode },
                    set: { viewModel.setThemeMode($0) }
                )) {
                    ForEach(AppThemeMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .accessibilityLabel("App theme mode")
                .accessibilityHint("Select system, light, or dark appearance")
                
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Accent Color")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(viewModel.colorOptions) { option in
                            Button {
                                viewModel.setAccentColor(option.name)
                            } label: {
                                Circle()
                                    .fill(option.color)
                                    .frame(width: 44, height: 44)
                                    .overlay(
                                        Circle()
                                            .strokeBorder(Color.primary.opacity(0.2), lineWidth: 1)
                                    )
                                    .overlay(
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(.white)
                                            .opacity(viewModel.accentColorName == option.name ? 1 : 0)
                                    )
                                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                                    .accessibilityLabel("\(option.displayName) accent color")
                                    .accessibilityHint("Double tap to use \(option.displayName) as the app accent color")
                                    .accessibilityAddTraits(viewModel.accentColorName == option.name ? [.isSelected] : [])
                            }
                            .buttonStyle(.plain)
                            .scaleEffect(viewModel.accentColorName == option.name ? 1.1 : 1.0)
                            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: viewModel.accentColorName)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
        }
    }
    
    private var accessibilityOptions: some View {
        Group {
            Toggle(isOn: $viewModel.isDynamicTypeEnabled) {
                HStack {
                    Image(systemName: "textformat.size")
                        .foregroundColor(.primary)
                        .frame(width: 24)
                    Text("Dynamic Type")
                }
            }
            .toggleStyle(SwitchToggleStyle())
            .accessibilityHint("Enable to adapt text size to your system settings")
            
            Toggle(isOn: $viewModel.isHighContrastEnabled) {
                HStack {
                    Image(systemName: "circle.lefthalf.fill")
                        .foregroundColor(.primary)
                        .frame(width: 24)
                    Text("High Contrast")
                }
            }
            .toggleStyle(SwitchToggleStyle())
            .accessibilityHint("Enable for increased color contrast using system accessibility settings")
            .onChange(of: viewModel.isHighContrastEnabled) { oldValue, newValue in
                viewModel.toggleHighContrast(newValue)
            }
            
            // Optional: Add a description text below the toggle for better user understanding
            if viewModel.isHighContrastEnabled {
                Text("High contrast mode increases visual distinction between interface elements.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.leading, 28) // Align with the toggle text
            }
        }
    }
    
    private var appInfo: some View {
        Group {
            HStack {
                Text("Version")
                Spacer()
                Text("\(viewModel.appVersion) (\(viewModel.buildNumber))")
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("© 2025 Task Manager")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
        }
    }
}

#Preview {
    SettingsView(viewModel: SettingsViewModel())
}
