//
//  MarkdownEditorView.swift
//  ModernNotes
//
//  Created by Owen Buckley on 12/12/2024.
//
import SwiftUI

struct MarkdownEditorView: View {
    @Binding var text: String
    @State private var selectedTab = 0
    @FocusState private var isEditorFocused: Bool
    
    private let formattingTools: [(String, String, String)] = [
        ("B", "**", "**"),
        ("I", "*", "*"),
        ("```", "`", "`"),
        ("Link", "[", "](url)"),
        ("List", "- ", ""),
        ("Header", "# ", "")
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Formatting toolbar
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
            
            // Mode selector
            Picker("View Mode", selection: $selectedTab) {
                Text("Edit").tag(0)
                Text("Preview").tag(1)
                Text("Split").tag(2)
            }
            .pickerStyle(.segmented)
            .padding()
            
            if selectedTab == 0 {
                // Edit mode
                TextEditor(text: $text)
                    .focused($isEditorFocused)
                    .font(.system(.body, design: .monospaced))
            } else if selectedTab == 1 {
                // Preview mode
                ScrollView {
                    Text(MarkdownHelper.attributedString(from: text))
                        .textSelection(.enabled)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else {
                // Split view
                GeometryReader { geometry in
                    HStack(spacing: 0) {
                        TextEditor(text: $text)
                            .focused($isEditorFocused)
                            .font(.system(.body, design: .monospaced))
                            .frame(width: geometry.size.width / 2)
                        
                        Divider()
                        
                        ScrollView {
                            Text(MarkdownHelper.attributedString(from: text))
                                .textSelection(.enabled)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(width: geometry.size.width / 2)
                    }
                }
            }
        }
    }
    
    private func insertFormatting(prefix: String, suffix: String) {
        guard isEditorFocused else { return }
        
        // Insert formatting at current position
        text.append(prefix + suffix)
        
        // Optional: Handle cursor positioning
        // This would require more complex text handling
    }
}
