//
//  MainView.swift
//  ModernNotes
//
//  Created by Owen Buckley on 12/12/2024.
//
import SwiftUI

struct MainView: View {
    // StateObject ensures our view model persists across view updates
    @StateObject private var viewModel = NotesViewModel()
    @State private var isAddingFolder = false
    @State private var isAddingNote = false
    @State private var showingSidebar: Bool = true
    
    var body: some View {
        NavigationSplitView {
            // Sidebar containing folders
            SidebarView(
                viewModel: viewModel,
                isAddingFolder: $isAddingFolder,
                isAddingNote: $isAddingNote
            )
        } detail: {
            // Main content area
            if let selectedFolder = viewModel.selectedFolder {
                FolderDetailView(folder: selectedFolder, viewModel: viewModel)
            } else {
                ContentUnavailableView("Select a Folder",
                                    systemImage: "folder.fill")
            }
        }
        .searchable(text: $viewModel.searchText,
                   prompt: "Search notes...")
        // Sheet for adding new folders
        .sheet(isPresented: $isAddingFolder) {
            NewFolderView(viewModel: viewModel)
        }
        // Sheet for adding new notes
        .sheet(isPresented: $isAddingNote) {
            if let selectedFolder = viewModel.selectedFolder {
                NewNoteView(viewModel: viewModel, folder: selectedFolder)
            }
        }
    }
}

// MARK: - SidebarView
struct SidebarView: View {
    @ObservedObject var viewModel: NotesViewModel
    @Binding var isAddingFolder: Bool
    @Binding var isAddingNote: Bool
    
    var body: some View {
        List(selection: $viewModel.selectedFolderId) {
            Section {
                HStack {
                    Label("Unread", systemImage: "tray.fill")
                    Spacer()
                    Text("\(viewModel.totalUnreadCount)")
                        .foregroundStyle(.secondary)
                }
            }
            
            Section("Folders") {
                ForEach(viewModel.filteredFolders) { folder in
                    NavigationLink(value: folder.id) {
                        HStack {
                            Label(folder.name, systemImage: folder.icon)
                                .foregroundStyle(folder.getIconColor())
                            Spacer()
                            Text("\(folder.unreadCount)")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("Notes")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: { isAddingFolder = true }) {
                        Label("New Folder", systemImage: "folder.badge.plus")
                    }
                    Button(action: { isAddingNote = true }) {
                        Label("New Note", systemImage: "square.and.pencil")
                    }
                    .disabled(viewModel.selectedFolder == nil)
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
}

// MARK: - Preview
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
