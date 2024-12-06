//
//  JobRow.swift
//  JobJourney
//
//  Created by Tom Curnow on 30/05/2024.
//

import SwiftUI

struct JobRow: View {
    @EnvironmentObject var dataController: DataController
    @ObservedObject var job: Job
    
    var body: some View {
        NavigationLink(value: job) {
            HStack {
                VStack(alignment: .leading) {
                    Text(job.jobTitle)
                        .font(.headline)
                        .lineLimit(1)
                    
                    Text(job.jobCompanyName)
                        .font(.subheadline)
                    
                    Text(job.jobTagsList)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text(job.jobCreationDate.formatted(date: .numeric, time: .omitted))
                        .accessibilityLabel(job.jobCreationDate.formatted(date: .abbreviated, time: .omitted))
                        .font(.subheadline)
                }
                .foregroundStyle(.secondary)
            }
        }
        .accessibilityIdentifier(job.jobTitle)
    }
}

#Preview {
    JobRow(job: Job.example)
        .environmentObject(DataController.preview)
}
