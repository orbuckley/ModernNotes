//
//  NewFolderView.swift
//  ModernNotes
//
//  Created by Owen Buckley on 12/12/2024.
//
// Create a new file called NewFolderView.swift
import SwiftUI

struct NewFolderView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: NotesViewModel
    
    @State private var folderName: String = ""
    @State private var selectedIcon: String = "folder.fill"
    @State private var selectedColor: String = "blue"
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Folder Name", text: $folderName)
                
                Picker("Icon", selection: $selectedIcon) {
                    Label("Folder", systemImage: "folder.fill")
                        .tag("folder.fill")
                    Label("Star", systemImage: "star.fill")
                        .tag("star.fill")
                    Label("Book", systemImage: "book.fill")
                        .tag("book.fill")
                }
                
                Picker("Color", selection: $selectedColor) {
                    Text("Blue").tag("blue")
                    Text("Purple").tag("purple")
                    Text("Green").tag("green")
                }
            }
            .navigationTitle("New Folder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createFolder()
                    }
                    .disabled(folderName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
    
    private func createFolder() {
        let trimmedName = folderName.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }
        
        viewModel.addFolder(
            name: trimmedName,
            icon: selectedIcon,
            color: selectedColor
        )
        
        dismiss()
    }
}
