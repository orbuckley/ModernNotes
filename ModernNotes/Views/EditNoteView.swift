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
    
    // State variables to track edited content
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
    
    // Check if content has been modified
    private var hasChanges: Bool {
        editedTitle != note.title || editedContent != note.content
    }
    
    // Validate if we can save changes
    private var canSave: Bool {
        !editedTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        hasChanges
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Title", text: $editedTitle)
                        .font(.headline)
                    
                    ZStack(alignment: .topLeading) {
                        if editedContent.isEmpty {
                            Text("Write something...")
                                .foregroundStyle(.gray)
                                .padding(.top, 8)
                                .padding(.leading, 5)
                        }
                        
                        TextEditor(text: $editedContent)
                            .frame(minHeight: 200)
                    }
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
                    // Delete button
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
            .alert("Delete Note?", isPresented: $isShowingDeleteAlert) {
                Button("Delete", role: .destructive) {
                    deleteNote()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to delete this note? This action cannot be undone.")
            }
            .alert("Discard Changes?", isPresented: $isShowingDiscardAlert) {
                Button("Discard", role: .destructive) {
                    dismiss()
                }
                Button("Keep Editing", role: .cancel) {}
            } message: {
                Text("Are you sure you want to discard your changes?")
            }
        }
    }
    
    private func saveChanges() {
        let trimmedTitle = editedTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }
        
        viewModel.updateNote(
            note,
            title: trimmedTitle,
            content: editedContent.trimmingCharacters(in: .whitespacesAndNewlines),
            in: folder
        )
        
        dismiss()
    }
    
    private func deleteNote() {
        viewModel.deleteNote(note, from: folder)
        dismiss()
    }
}

// Helper view for displaying note information
struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
        }
    }
}
