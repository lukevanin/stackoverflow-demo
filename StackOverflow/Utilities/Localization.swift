//
//  Localization.swift
//  StackOverflow
//
//  Created by Luke Van In on 2021/05/13.
//

import Foundation


/// Helper methods for common localization tasks.
struct Localization {
    
    static let shared = Localization()
    
    private let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        return formatter
    }()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()

    func string(named key: String) -> String {
        NSLocalizedString(key, comment: "")
    }
    
    func formattedString(named key: String, _ arguments: CVarArg ...) -> String {
        return String(format: string(named: key), arguments: arguments)
    }
    
    func formatInteger(_ value: Int) -> String {
        numberFormatter.string(for: NSNumber(value: value)) ?? String(value)
    }
    
    func formatDate(_ value: Date) -> String {
        dateFormatter.string(from: value)
    }
    
    func formatTime(_ value: Date) -> String {
        timeFormatter.string(from: value)
    }
}
