//
//  Note.swift
//  ModernNotes
//
//  Created by Owen Buckley on 12/12/2024.
//
import Foundation
import SwiftUI

// The Note struct represents a single note in our application.
// We make it identifiable so we can use it in SwiftUI lists and collections.
// We make it codable so we can easily save and load notes from storage.
struct Note: Identifiable, Codable {
    // A unique identifier for each note
    var id: UUID
    
    // The title of the note, shown in lists and headers
    var title: String
    
    // The main content of the note in Markdown format
    var content: String
    
    // Computed property to get the rendered Markdown content
    var renderedContent: AttributedString {
        MarkdownHelper.attributedString(from: content)
    }
    
    // Returns a plain text preview of the content (first few lines)
    var contentPreview: String {
        let lines = content.components(separatedBy: .newlines)
        let firstLines = lines.prefix(2).joined(separator: "\n")
        return firstLines.count < content.count ? firstLines + "..." : firstLines
    }
    
    // When the note was created
    var dateCreated: Date
    
    // When the note was last modified
    var dateModified: Date
    
    // Indicates if the note needs attention/hasn't been read
    var isUnread: Bool
    
    // Creates a new note with default values
    init(id: UUID = UUID(),
         title: String,
         content: String = "",
         isUnread: Bool = true) {
        self.id = id
        self.title = title
        self.content = content
        self.dateCreated = Date()
        self.dateModified = Date()
        self.isUnread = isUnread
    }
    
    // Updates the modification date when the note is changed
    mutating func updateModificationDate() {
        self.dateModified = Date()
    }
    
    // Marks the note as read
    mutating func markAsRead() {
        self.isUnread = false
        self.updateModificationDate()
    }
    
    // Returns a formatted string of how long ago the note was modified
    func timeAgoModified() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: dateModified, relativeTo: Date())
    }
}

// Extension to add preview data for development
extension Note {
    static var sampleNote: Note {
        Note(title: "Sample Note",
             content: "This is a sample note for preview purposes.")
    }
    
    static var sampleNotes: [Note] {
        [
            Note(title: "Shopping List",
                 content: "1. Groceries\n2. Household items"),
            Note(title: "Project Ideas",
                 content: "New app concepts to explore..."),
            Note(title: "Meeting Notes",
                 content: "Discussion points from team meeting...")
        ]
    }
}
