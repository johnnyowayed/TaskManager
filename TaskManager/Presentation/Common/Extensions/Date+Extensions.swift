//
//  Date+Extensions.swift
//  TaskManager
//
//  Created by Johnny Owayed on 07/03/2025.
//

import Foundation

extension Date {
    // Get a formatted string for relative dates (Today, Tomorrow, etc.)
    func relativeFormatted() -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(self) {
            return "Today"
        } else if calendar.isDateInTomorrow(self) {
            return "Tomorrow"
        } else if calendar.isDateInYesterday(self) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter.string(from: self)
        }
    }
    
    // Get time remaining as a formatted string
    func timeRemaining() -> String {
        let now = Date()
        if self < now {
            return "Overdue"
        }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .hour, .minute], from: now, to: self)
        
        if let days = components.day, days > 0 {
            return "\(days) day\(days == 1 ? "" : "s") left"
        } else if let hours = components.hour, hours > 0 {
            return "\(hours) hour\(hours == 1 ? "" : "s") left"
        } else if let minutes = components.minute, minutes > 0 {
            return "\(minutes) minute\(minutes == 1 ? "" : "s") left"
        } else {
            return "Due now"
        }
    }
    
    static let snapshotTestDate: Date = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        return dateFormatter.date(from: "2025-03-01 12:00:00")!
    }()
    
    static let snapshotTestDatePlusOneDay: Date = {
        return snapshotTestDate.addingTimeInterval(86400) // Plus one day
    }()
    
    static let snapshotTestDateMinusOneDay: Date = {
        return snapshotTestDate.addingTimeInterval(-86400) // Minus one day
    }()
    
}
