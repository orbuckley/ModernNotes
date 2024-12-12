//
//  MarkdownPreviewRow.swift
//  ModernNotes
//
//  Created by Owen Buckley on 12/12/2024.
//
import SwiftUI

struct MarkdownPreviewRow: View {
    let note: Note
    
    // Controls how many lines of preview to show
    var previewLines: Int = 2
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Title and metadata row
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
            
            // Markdown preview with line limit
            Text(note.renderedContent)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(previewLines)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 4)
    }
}

// Preview provider for SwiftUI canvas
struct MarkdownPreviewRow_Previews: PreviewProvider {
    static var previews: some View {
        MarkdownPreviewRow(note: Note(
            title: "Sample Note",
            content: """
            This is a **bold** statement and some *italic* text.
            
            - List item 1
            - List item 2
            
            More text here...
            """
        ))
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
