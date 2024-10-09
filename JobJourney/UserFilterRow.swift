//
//  UserFilterRow.swift
//  JobJourney
//
//  Created by Tom Curnow on 09/10/2024.
//

import SwiftUI

struct UserFilterRow: View {
    var filter: Filter
    var delete: (Filter) -> Void
    var rename: (Filter) -> Void
    
    var body: some View {
        NavigationLink(value: filter) {
            Label(filter.name, systemImage: filter.icon)
                .badge(filter.jobsCount)
                .contextMenu {
                    Button {
                        rename(filter)
                    } label: {
                        Label("Rename", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive) {
                        delete(filter)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
                .accessibilityElement()
                .accessibilityLabel(filter.name)
                .accessibilityHint("\(filter.jobsCount) jobs")
        }
    }
}

#Preview {
    UserFilterRow(filter: .all, delete: { _ in }, rename: { _ in })
}
