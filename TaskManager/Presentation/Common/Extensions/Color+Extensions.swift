//
//  Color+Extensions.swift
//  TaskManager
//
//  Created by Johnny Owayed on 07/03/2025.
//
import SwiftUI

extension Color {
    // SwiftUI colors for task priorities
    static let taskPriorityLow = Color("taskPriorityLow", bundle: nil)
    static let taskPriorityMedium = Color("taskPriorityMedium", bundle: nil)
    static let taskPriorityHigh = Color("taskPriorityHigh", bundle: nil)
    
    // If custom colors aren't defined in the asset catalog, we'll use fallbacks
    init(_ name: String) {
        // Check if the color exists in the asset catalog
        if UIColor(named: name) != nil {
            self.init(name, bundle: nil)
        } else {
            // Fallback colors
            switch name {
            case "taskPriorityLow":
                self = Color(.systemBlue)
            case "taskPriorityMedium":
                self = Color(.systemOrange)
            case "taskPriorityHigh":
                self = Color(.systemRed)
            default:
                self = Color(.label)
            }
        }
    }
}
