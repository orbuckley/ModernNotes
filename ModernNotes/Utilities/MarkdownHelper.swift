//
//  MarkdownHelper.swift
//  ModernNotes
//
//  Created by Owen Buckley on 12/12/2024.
//
import Foundation
import SwiftUI

class MarkdownHelper {
    // Convert Markdown text to AttributedString for display
    static func attributedString(from markdown: String) -> AttributedString {
        do {
            // Use the built-in Markdown parser with safe options
            return try AttributedString(markdown: markdown, options: AttributedString.MarkdownParsingOptions(
                allowsExtendedAttributes: true,
                interpretedSyntax: .inlineOnlyPreservingWhitespace,
                failurePolicy: .returnPartiallyParsedIfPossible
            ))
        } catch {
            // If parsing fails, return plain text
            return AttributedString(markdown)
        }
    }

    // Apply syntax highlighting to Markdown text
    static func highlightSyntax(in text: String) -> AttributedString {
        // Start with a plain AttributedString
        var attributedString = AttributedString(text)
        
        // Define our syntax patterns and their colors
        let patterns = [
            ("#{1,6}\\s.*$", SystemColor.systemBlue),      // Headers
            ("\\*\\*.*?\\*\\*", SystemColor.systemPurple), // Bold
            ("\\*.*?\\*", SystemColor.systemGreen),        // Italic
            ("`.*?`", SystemColor.systemOrange)            // Code
        ]
        
        // Process each pattern
        for (pattern, color) in patterns {
            do {
                let regex = try NSRegularExpression(pattern: pattern)
                let fullRange = NSRange(text.startIndex..<text.endIndex, in: text)
                
                // Find all matches for this pattern
                let matches = regex.matches(in: text, range: fullRange)
                
                // For each match, create a new AttributedString with the color
                // and replace the corresponding section
                for match in matches {
                    guard let range = Range(match.range, in: text) else { continue }
                    let matchedText = String(text[range])
                    
                    // Create a new AttributedString just for this match
                    var coloredText = AttributedString(matchedText)
                    coloredText.foregroundColor = color
                    
                    // Find where this text appears in our main string
                    if let foundRange = attributedString.range(of: matchedText) {
                        // Replace the text with our colored version
                        attributedString.replaceSubrange(foundRange, with: coloredText)
                    }
                }
            } catch {
                print("Error processing pattern '\(pattern)': \(error)")
            }
        }
        
        return attributedString
    }
    
    static func convertPlainTextToMarkdown(_ text: String) -> String {
        // First, split the text into lines so we can analyze each one
        var lines = text.components(separatedBy: .newlines)
        var markdownText = ""
        var currentLineType = LineType.normal
        
        // Keep track of the previous line to help identify headers and sections
        var previousLineWasEmpty = true
        
        // Process each line of text
        for (index, line) in lines.enumerated() {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            
            // Handle empty lines
            if trimmedLine.isEmpty {
                markdownText += "\n"
                previousLineWasEmpty = true
                currentLineType = .normal
                continue
            }
            
            // Detect and convert different types of text
            if previousLineWasEmpty {
                // If line follows an empty line, it might be a header
                markdownText += "# \(trimmedLine)\n"
                currentLineType = .header
            } else if trimmedLine.first == "-" || trimmedLine.first == "*" {
                // Already a list item, keep it as is
                markdownText += "\(line)\n"
                currentLineType = .list
            } else if let firstChar = trimmedLine.first, firstChar.isNumber,
                      trimmedLine.contains(".") {
                // Convert numbered lists to bullet points
                let parts = trimmedLine.split(separator: ".", maxSplits: 1)
                if parts.count > 1 {
                    markdownText += "- \(parts[1].trimmingCharacters(in: .whitespaces))\n"
                    currentLineType = .list
                }
            } else {
                // Handle emphasis for regular text
                let words = trimmedLine.split(separator: " ")
                let convertedWords = words.map { word -> String in
                    let str = String(word)
                    if str.uppercased() == str && str.count > 1 && str.contains(where: { $0.isLetter }) {
                        // Convert words in ALL CAPS to bold
                        return "**\(str.lowercased())**"
                    }
                    return str
                }
                markdownText += convertedWords.joined(separator: " ") + "\n"
                currentLineType = .normal
            }
            
            previousLineWasEmpty = false
        }
        
        return markdownText.trimmingCharacters(in: .newlines)
    }
    
    // Helper enum to track what kind of line we're processing
    private enum LineType {
        case normal
        case header
        case list
    }
}



// Define SystemColor based on platform
#if os(iOS)
import UIKit
typealias SystemColor = UIColor
#else
import AppKit
typealias SystemColor = NSColor
#endif
