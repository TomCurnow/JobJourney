//
//  JobView.swift
//  JobJourney
//
//  Created by Tom Curnow on 03/06/2024.
//

import SwiftUI

struct JobView: View {
    @EnvironmentObject var dataController: DataController
    @ObservedObject var job: Job
    
    private var appliedDateText: String {
        if job.applied {
            if let appliedDate = job.appliedDate {
                return appliedDate.formatted(date: .long, time: .shortened)
            }
        }
        return ""
    }
    
    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading) {
                    TextField("Title", text: $job.jobTitle, prompt: Text("Enter the job title here."))
                    Text("**Created** \(job.jobCreationDate.formatted(date: .long, time: .shortened))")
                        .foregroundStyle(.secondary)
                    Text("**Status** \(job.jobAppliedStatus)\(appliedDateText)")
                        .foregroundStyle(.secondary)
                }
                
                TagsMenuView(job: job)
            }
            
            Section {
                VStack(alignment: .leading) {
                    Text("Basic Information")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    
                    TextField("Details", text: $job.jobDetails, prompt: Text("Enter the job details here"), axis: .vertical)
                }
            }
        }
        .disabled(job.isDeleted)
        // Calls queusave everytime the job object is modified
        .onReceive(job.objectWillChange) { _ in
            dataController.queueSave()
        }
        // Immediately calls a send on pressing enter having filled a text field
        .onSubmit(dataController.save)
        .toolbar {JobViewToolbar(job: job)}
    }
}

#Preview {
    JobView(job: .example)
        .environmentObject(DataController.preview)
}
