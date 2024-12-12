//
//  NotesViewModel.swift
//  ModernNotes
//
//  Created by Owen Buckley on 12/12/2024.
//
import Foundation
import SwiftUI

// The NotesViewModel serves as the brain of our application, managing all data
// and business logic for our notes and folders.
@MainActor
class NotesViewModel: ObservableObject {
    // Published properties automatically notify the UI when they change
    @Published private(set) var folders: [NoteFolder]
    @Published var selectedFolderId: UUID?
    @Published var searchText: String = ""
    
    // Initialize with sample data for now - later we'll load from storage
    init() {
        self.folders = NoteFolder.sampleFolders
    }
    
    // MARK: - Computed Properties
    
    var totalUnreadCount: Int {
        folders.reduce(0) { $0 + $1.unreadCount }
    }
    
    var selectedFolder: NoteFolder? {
        guard let id = selectedFolderId else { return nil }
        return folders.first { $0.id == id }
    }
    
    var filteredFolders: [NoteFolder] {
        if searchText.isEmpty {
            return folders
        }
        return folders.filter { folder in
            folder.name.localizedCaseInsensitiveContains(searchText) ||
            folder.notes.contains { note in
                note.title.localizedCaseInsensitiveContains(searchText) ||
                note.content.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    // MARK: - Folder Management
    
    func addFolder(name: String, icon: String = "folder.fill", color: String = "blue") {
        let newFolder = NoteFolder(name: name, icon: icon, iconColor: color)
        folders.append(newFolder)
        objectWillChange.send()
    }
    
    func deleteFolder(_ folder: NoteFolder) {
        folders.removeAll { $0.id == folder.id }
        if selectedFolderId == folder.id {
            selectedFolderId = nil
        }
    }
    
    // MARK: - Note Management
    
    func addNote(title: String, content: String, to folderId: UUID) {
        guard let folderIndex = folders.firstIndex(where: { $0.id == folderId }) else {
            return
        }
        
        let newNote = Note(title: title, content: content)
        folders[folderIndex].notes.append(newNote)
        objectWillChange.send()
    }
    
    func deleteNote(_ note: Note, from folder: NoteFolder) {
        guard let folderIndex = folders.firstIndex(where: { $0.id == folder.id }) else {
            return
        }
        
        folders[folderIndex].notes.removeAll { $0.id == note.id }
        objectWillChange.send()
    }
    
    func markNoteAsRead(_ note: Note, in folder: NoteFolder) {
        guard let folderIndex = folders.firstIndex(where: { $0.id == folder.id }),
              let noteIndex = folders[folderIndex].notes.firstIndex(where: { $0.id == note.id })
        else {
            return
        }
        
        folders[folderIndex].notes[noteIndex].markAsRead()
        objectWillChange.send()
    }
    
    func updateNote(_ note: Note, title: String, content: String, in folder: NoteFolder) {
        guard let folderIndex = folders.firstIndex(where: { $0.id == folder.id }),
              let noteIndex = folders[folderIndex].notes.firstIndex(where: { $0.id == note.id })
        else {
            return
        }
        
        var updatedNote = note
        updatedNote.title = title
        updatedNote.content = content
        updatedNote.updateModificationDate()
        
        folders[folderIndex].notes[noteIndex] = updatedNote
        objectWillChange.send()
    }
}
