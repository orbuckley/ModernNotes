//
//  InfoView.swift
//  ModernNotes
//
//  Created by Owen Buckley on 13/12/2024.
//
import SwiftUI  // This import is crucial for using SwiftUI's View protocol

struct InfoRow: View {    // Now 'View' will be recognized
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
