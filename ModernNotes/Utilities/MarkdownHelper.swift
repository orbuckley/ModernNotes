//
//  MarkdownHelper.swift
//  ModernNotes
//
//  Created by Owen Buckley on 12/12/2024.
//
import Foundation
import SwiftUI

class MarkdownHelper {
    static func attributedString(from markdown: String) -> AttributedString {
        do {
            return try AttributedString(markdown: markdown, options: AttributedString.MarkdownParsingOptions(
                allowsExtendedAttributes: true,
                interpretedSyntax: .inlineOnlyPreservingWhitespace,
                failurePolicy: .returnPartiallyParsedIfPossible
            ))
        } catch {
            return AttributedString(markdown)
        }
    }
    
    static func highlightSyntax(in text: String) -> AttributedString {
        var attributedString = AttributedString(text)
        
        let patterns = [
            ("#{1,6}\\s.*$", SystemColor.systemBlue),      // Headers
            ("\\*\\*.*?\\*\\*", SystemColor.systemPurple), // Bold
            ("\\*.*?\\*", SystemColor.systemGreen),        // Italic
            ("`.*?`", SystemColor.systemOrange)            // Code
        ]
        
        for (pattern, color) in patterns {
            do {
                let regex = try NSRegularExpression(pattern: pattern)
                let fullRange = NSRange(text.startIndex..<text.endIndex, in: text)
                
                let matches = regex.matches(in: text, range: fullRange)
                
                for match in matches {
                    if let range = Range(match.range, in: text) {
                        let matchedText = String(text[range])
                        
                        if let foundRange = attributedString.range(of: matchedText) {
                            attributedString[foundRange].foregroundColor = color
                        }
                    }
                }
            } catch {
                print("Error processing pattern '\(pattern)': \(error)")
            }
        }
        
        return attributedString
    }
}

#if os(iOS)
import UIKit
typealias SystemColor = UIColor
#else
import AppKit
typealias SystemColor = NSColor
#endif
