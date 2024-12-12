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
