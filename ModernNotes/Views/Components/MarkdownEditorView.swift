//
//  MarkdownEditorView.swift
//  ModernNotes
//
//  Created by Owen Buckley on 12/12/2024.
//
import SwiftUI

// A custom editor that provides both Markdown editing and live preview capabilities
struct MarkdownEditorView: View {
    @Binding var text: String
    @State private var isShowingPreview = false
    @State private var selectedTab = 0
    @FocusState private var isEditorFocused: Bool
    
    // Quick formatting tools
    private let formattingTools: [(String, String, String)] = [
        ("B", "**", "**"),      // Bold
        ("I", "*", "*"),        // Italic
        ("```", "`", "`"),      // Code
        ("[]", "[", "](url)"),  // Link
        ("-", "- ", ""),        // List item
        ("##", "## ", "")       // Header
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Toolbar for quick formatting
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(formattingTools, id: \.0) { tool in
                        Button(tool.0) {
                            insertFormatting(prefix: tool.1, suffix: tool.2)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(.systemGray5))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
            
            // Editor/Preview tabs
            Picker("View Mode", selection: $selectedTab) {
                Text("Edit").tag(0)
                Text("Preview").tag(1)
                Text("Split").tag(2)
            }
            .pickerStyle(.segmented)
            .padding()
            
            // Content area
            Group {
                switch selectedTab {
                case 0:  // Edit only
                    markdownEditor
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                case 1:  // Preview only
                    markdownPreview
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                case 2:  // Split view
                    HSplitView {
                        markdownEditor
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        Divider()
                        markdownPreview
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                default:
                    EmptyView()
                }
            }
        }
    }
    
    // The markdown editor with syntax highlighting
    private var markdownEditor: some View {
        TextEditor(text: $text)
            .focused($isEditorFocused)
            .font(.system(.body, design: .monospaced))
            .scrollContentBackground(.hidden)
            .background(Color(.systemBackground))
            .onChange(of: text) { _ in
                // You could add auto-save logic here
            }
    }
    
    // The preview of the rendered markdown
    private var markdownPreview: some View {
        ScrollView {
            Text(attributedText)
                .textSelection(.enabled)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color(.systemBackground))
    }
    
    // Convert the markdown text to attributed string for preview
    private var attributedText: AttributedString {
        MarkdownHelper.attributedString(from: text)
    }
    
    // Insert formatting marks around selected text or at cursor position
    private func insertFormatting(prefix: String, suffix: String) {
        // Get the NSRange of selected text
        guard let textRange = Range(NSRange(location: 0, length: text.utf16.count), in: text) else { return }
        
        // Get the selected range if there is one, otherwise use cursor position
        if let selectedRange = TextRange(textRange) {
            let selectedText = String(text[selectedRange])
            let newText = prefix + selectedText + suffix
            text.replaceSubrange(selectedRange, with: newText)
        } else {
            // If no selection, insert at cursor position
            text.insert(contentsOf: prefix + suffix, at: text.index(text.startIndex, offsetBy: 0))
        }
    }
}

// Preview provider for SwiftUI canvas
struct MarkdownEditorView_Previews: PreviewProvider {
    static var previews: some View {
        MarkdownEditorView(text: .constant("""
        # Sample Markdown
        
        This is a **bold** statement and *italic* text.
        
        - List item 1
        - List item 2
        
        `code snippet`
        
        [Link](https://example.com)
        """))
    }
}
