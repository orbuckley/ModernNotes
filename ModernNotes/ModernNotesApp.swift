//
//  ModernNotesApp.swift
//  ModernNotes
//
//  Created by Owen Buckley on 12/12/2024.
//
import SwiftUI

@main
struct ModernNotesApp: App {
    // Create a single instance of our view model that we'll share throughout the app
    @StateObject private var notesViewModel = NotesViewModel()
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(notesViewModel)
        }
    }
}
