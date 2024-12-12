//
//  ModernNotesApp.swift
//  ModernNotes
//
//  Created by Owen Buckley on 12/12/2024.
//

import SwiftUI

@main
struct ModernNotesApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
