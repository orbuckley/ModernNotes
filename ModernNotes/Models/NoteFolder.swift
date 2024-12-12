//
//  NoteFolder.swift
//  ModernNotes
//
//  Created by Owen Buckley on 12/12/2024.
//
import Foundation
import SwiftUI

// NoteFolder represents a collection of related notes.
// Like Note, it's Identifiable for SwiftUI lists and Codable for storage.
struct NoteFolder: Identifiable, Codable {
    // Unique identifier for the folder
    var id: UUID
    
    // The name displayed in the folder list
    var name: String
    
    // Collection of notes in this folder
    var notes: [Note]
    
    // SF Symbol name used for the folder's icon
    var icon: String
    
    // The color used for the folder's icon
    var iconColor: String // We store the color as a string and convert it when needed
    
    // Computed property that counts unread notes in this folder
    var unreadCount: Int {
        notes.filter { $0.isUnread }.count
    }
    
    // Creates a new folder
    init(id: UUID = UUID(),
         name: String,
         notes: [Note] = [],
         icon: String = "folder.fill",
         iconColor: String = "blue") {
        self.id = id
        self.name = name
        self.notes = notes
        self.icon = icon
        self.iconColor = iconColor
    }
    
    // Returns the Color object for the icon
    func getIconColor() -> Color {
        switch iconColor {
        case "red":
            return .red
        case "green":
            return .green
        case "blue":
            return .blue
        case "purple":
            return .purple
        default:
            return .blue
        }
    }
    
    // Adds a note to the folder
    mutating func addNote(_ note: Note) {
        notes.append(note)
    }
    
    // Removes a note from the folder
    mutating func removeNote(withId id: UUID) {
        notes.removeAll { $0.id == id }
    }
    
    // Sorts notes by modification date
    func sortedNotes() -> [Note] {
        notes.sorted { $0.dateModified > $1.dateModified }
    }
}

// Extension to add preview data for development
extension NoteFolder {
    static var sampleFolder: NoteFolder {
        NoteFolder(name: "Sample Folder",
                  notes: Note.sampleNotes,
                  icon: "folder.fill",
                  iconColor: "blue")
    }
    
    static var sampleFolders: [NoteFolder] {
        [
            NoteFolder(name: "Personal",
                      notes: [Note.sampleNotes[0]],
                      icon: "person.fill",
                      iconColor: "blue"),
            NoteFolder(name: "Work",
                      notes: [Note.sampleNotes[1]],
                      icon: "briefcase.fill",
                      iconColor: "purple"),
            NoteFolder(name: "Ideas",
                      notes: [Note.sampleNotes[2]],
                      icon: "lightbulb.fill",
                      iconColor: "green")
        ]
    }
}
