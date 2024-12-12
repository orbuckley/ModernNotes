//
//  FolderDetailView.swift
//  ModernNotes
//
//  Created by Owen Buckley on 12/12/2024.
//
import SwiftUI

struct FolderDetailView: View {
    let folder: NoteFolder
    @ObservedObject var viewModel: NotesViewModel
    @State private var selectedNote: Note?
    @State private var isEditingNote = false
    
    var body: some View {
        List {
            ForEach(folder.sortedNotes()) { note in
                MarkdownPreviewRow(note: note)
                    .onTapGesture {
                        selectedNote = note
                        isEditingNote = true
                    }
            }
            .onDelete { indexSet in
                for index in indexSet {
                    let note = folder.sortedNotes()[index]
                    viewModel.deleteNote(note, from: folder)
                }
            }
        }
        .navigationTitle(folder.name)
        .sheet(isPresented: $isEditingNote) {
            if let note = selectedNote {
                EditNoteView(
                    viewModel: viewModel,
                    folder: folder,
                    note: note
                )
            }
        }
    }
}

struct NoteRow: View {
    let note: Note
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(note.title)
                    .font(.headline)
                
                if note.isUnread {
                    Circle()
                        .fill(.blue)
                        .frame(width: 8, height: 8)
                }
                
                Spacer()
                
                Text(note.timeAgoModified())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Text(note.content)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .padding(.vertical, 4)
    }
}
