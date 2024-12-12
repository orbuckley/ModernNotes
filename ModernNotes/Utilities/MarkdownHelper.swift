//
//  MarkdownHelper.swift
//  ModernNotes
//
//  Created by Owen Buckley on 12/12/2024.
//
import Foundation

// The MarkdownHelper class provides utilities for working with Markdown text,
// including conversion to AttributedString and syntax highlighting
class MarkdownHelper {
    // Intelligently converts plain text to Markdown by analyzing the text structure.
    // This looks for common patterns that might indicate formatting intentions.
    static func convertPlainTextToMarkdown(_ text: String) -> String {
        var lines = text.components(separatedBy: .newlines)
        var inList = false
        
        // Process each line to identify and convert potential formatting
        for i in 0..<lines.count {
            let trimmed = lines[i].trimmingCharacters(in: .whitespaces)
            
            // Convert potential headers (lines followed by blank lines)
            if i < lines.count - 1 && !trimmed.isEmpty &&
               (i == 0 || lines[i-1].isEmpty) &&
               lines[i+1].isEmpty {
                lines[i] = "# " + trimmed
                continue
            }
            
            // Convert potential list items
            if trimmed.starts(with: "-") || trimmed.starts(with: "*") {
                inList = true
                continue // Keep existing list formatting
            } else if trimmed.starts(with: "1") || trimmed.starts(with: "2") {
                // Convert numbered items to proper Markdown list items
                if let firstSpace = trimmed.firstIndex(of: " ") {
                    let restOfLine = trimmed[firstSpace...].trimmingCharacters(in: .whitespaces)
                    lines[i] = "- " + restOfLine
                    inList = true
                    continue
                }
            } else if !trimmed.isEmpty && inList {
                inList = false
            }
            
            // Convert potential emphasis (words in ALL CAPS)
            if !trimmed.isEmpty {
                let words = trimmed.components(separatedBy: " ")
                let convertedWords = words.map { word -> String in
                    if word == word.uppercased() && word.count > 1 {
                        return "**\(word.lowercased())**"
                    }
                    return word
                }
                lines[i] = convertedWords.joined(separator: " ")
            }
        }
        
        return lines.joined(separator: "\n")
    }
    // Convert Markdown text to an AttributedString for display
    static func attributedString(from markdown: String) -> AttributedString {
        do {
            // Convert the markdown to an AttributedString using the built-in parser
            let attributed = try AttributedString(markdown: markdown, options: .init(
                // Allow all supported Markdown features
                allowsExtendedAttributes: true,
                interpretedSyntax: .inlineOnlyPreservingWhitespace,
                failurePolicy: .returnPartiallyParsedIfPossible
            ))
            return attributed
        } catch {
            // If parsing fails, return the plain text
            return AttributedString(markdown)
        }
    }
    
    // Add syntax highlighting to Markdown text
    static func highlightSyntax(in text: String) -> AttributedString {
        var highlighted = AttributedString(text)
        
        // Define regular expressions for different Markdown elements
        let patterns: [(String, UIColor)] = [
            // Headers
            ("^#{1,6}\\s.*$", .systemBlue),
            // Bold
            ("\\*\\*.*?\\*\\*", .systemPurple),
            // Italic
            ("\\*.*?\\*", .systemTeal),
            // Links
            ("\\[.*?\\]\\(.*?\\)", .systemGreen),
            // Code blocks
            ("`.*?`", .systemOrange),
            // Lists
            ("^[\\*\\-\\+]\\s.*$", .systemIndigo)
        ]
        
        // Apply highlighting using regular expressions
        for (pattern, color) in patterns {
            do {
                let regex = try NSRegularExpression(pattern: pattern, options: [.anchorsMatchLines])
                let range = NSRange(text.startIndex..., in: text)
                
                let matches = regex.matches(in: text, options: [], range: range)
                for match in matches {
                    let matchRange = match.range
                    if let range = Range(matchRange, in: text) {
                        let startIndex = highlighted.index(highlighted.startIndex, offsetBy: text.distance(from: text.startIndex, to: range.lowerBound))
                        let endIndex = highlighted.index(highlighted.startIndex, offsetBy: text.distance(from: text.startIndex, to: range.upperBound))
                        highlighted[startIndex..<endIndex].foregroundColor = color
                    }
                }
            } catch {
                print("Regex error: \(error)")
            }
        }
        
        return highlighted
    }
}

// Extension to make the helper work with both iOS and macOS
#if os(iOS)
import UIKit
typealias SystemColor = UIColor
#else
import AppKit
typealias SystemColor = NSColor
#endif
