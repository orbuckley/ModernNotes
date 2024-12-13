//
//  EditNoteView.swift
//  ModernNotes
//
//  Created by Owen Buckley on 12/12/2024.
//
import SwiftUI

struct EditNoteView: View {
    @ObservedObject var viewModel: NotesViewModel
    let folder: NoteFolder
    let note: Note
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var editedTitle: String
    @State private var editedContent: String
    @State private var isShowingDeleteAlert = false
    @State private var isShowingDiscardAlert = false
    
    // Initialize state with existing note content
    init(viewModel: NotesViewModel, folder: NoteFolder, note: Note) {
        self.viewModel = viewModel
        self.folder = folder
        self.note = note
        _editedTitle = State(initialValue: note.title)
        _editedContent = State(initialValue: note.content)
    }
    
    // Add these computed properties to check for changes and validate save conditions
    private var hasChanges: Bool {
        // Check if either the title or content has been modified
        return editedTitle != note.title || editedContent != note.content
    }
    
    private var canSave: Bool {
        // Ensure we have at least a non-empty title and that some changes have been made
        let trimmedTitle = editedTitle.trimmingCharacters(in: .whitespaces)
        return !trimmedTitle.isEmpty && hasChanges
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Title", text: $editedTitle)
                        .font(.headline)
                    
                    MarkdownEditorView(text: $editedContent)
                        .frame(minHeight: 300)
                }
                
                Section {
                    // Information about the note
                    VStack(alignment: .leading, spacing: 8) {
                        InfoRow(label: "Created", value: note.dateCreated.formatted())
                        InfoRow(label: "Modified", value: note.dateModified.formatted())
                        
                        if note.isUnread {
                            HStack {
                                Text("Status")
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text("Unread")
                                    .foregroundStyle(.blue)
                            }
                        }
                    }
                }
                
                Section {
                    Button(role: .destructive) {
                        isShowingDeleteAlert = true
                    } label: {
                        Label("Delete Note", systemImage: "trash")
                    }
                }
            }
            .navigationTitle("Edit Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        if hasChanges {
                            isShowingDiscardAlert = true
                        } else {
                            dismiss()
                        }
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
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
                Text("Are you sure you want to discard your changes?")
            }
            .alert("Delete Note?", isPresented: $isShowingDeleteAlert) {
                Button("Delete", role: .destructive) {
                    deleteNote()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to delete this note? This action cannot be undone.")
            }
        }
    }
    
    // Add these methods to handle saving and deleting
    private func saveChanges() {
        let trimmedTitle = editedTitle.trimmingCharacters(in: .whitespaces)
        guard !trimmedTitle.isEmpty else { return }
        
        // Call the view model to update the note
        viewModel.updateNote(
            note,
            title: trimmedTitle,
            content: editedContent,
            in: folder
        )
        
        dismiss()
    }
    
    private func deleteNote() {
        viewModel.deleteNote(note, from: folder)
        dismiss()
    }
}
