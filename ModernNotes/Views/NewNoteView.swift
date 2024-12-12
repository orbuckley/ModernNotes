//
//  NewNoteView.swift
//  ModernNotes
//
//  Created by Owen Buckley on 12/12/2024.
//
import SwiftUI

struct NewNoteView: View {
    // We need access to our view model to save the new note
    @ObservedObject var viewModel: NotesViewModel
    // Reference to the folder where we'll add the note
    let folder: NoteFolder
    
    // Environment value to dismiss this view when we're done
    @Environment(\.dismiss) private var dismiss
    
    // State variables to hold the user's input
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var isShowingDiscardAlert = false
    
    // Computed property to determine if the save button should be enabled
    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Title", text: $title)
                        .font(.headline)
                    
                    ZStack(alignment: .topLeading) {
                        if content.isEmpty {
                            Text("Write something...")
                                .foregroundStyle(.gray)
                                .padding(.top, 8)
                                .padding(.leading, 5)
                        }
                        
                        TextEditor(text: $content)
                            .frame(minHeight: 200)
                    }
                }
                
                Section {
                    // A preview of how the note will look
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Preview")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        if !title.isEmpty || !content.isEmpty {
                            NotePreview(title: title, content: content)
                        } else {
                            Text("Start typing to see a preview")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("New Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        // Only show alert if user has entered content
                        if !title.isEmpty || !content.isEmpty {
                            isShowingDiscardAlert = true
                        } else {
                            dismiss()
                        }
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveNote()
                    }
                    .disabled(!canSave)
                }
            }
            .alert("Discard Changes?", isPresented: $isShowingDiscardAlert) {
                Button("Discard", role: .destructive) {
                    dismiss()
                }
                Button("Keep Editing", role: .cancel) {}
            } message: {
                Text("Are you sure you want to discard your new note?")
            }
        }
    }
    
    private func saveNote() {
        // Ensure we have at least a title before saving
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }
        
        // Add the note to our folder through the view model
        viewModel.addNote(
            title: trimmedTitle,
            content: content.trimmingCharacters(in: .whitespacesAndNewlines),
            to: folder.id
        )
        
        dismiss()
    }
}

// A preview component to show how the note will look
struct NotePreview: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
            
            if !content.isEmpty {
                Text(content)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
