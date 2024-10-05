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
                return " on " + appliedDate.formatted(date: .long, time: .shortened)
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
                
                Menu {
                    ForEach(job.jobTags) { tag in
                        Button{
                            job.removeFromTags(tag) // Method dded by xcode
                        } label: {
                            Label(tag.tagName, systemImage: "checkmark")
                        }
                    }
                    
                    let otherTags = dataController.missingTags(from: job)
                    
                    if otherTags.isEmpty == false {
                        Divider()
                        
                        Section("Add Tags") {
                            ForEach(otherTags) { tag in
                                Button(tag.tagName) {
                                    job.addToTags(tag) // Method dded by xcode
                                }
                            }
                        }
                    }
                } label: {
                    Text(job.jobTagsList)
                        .multilineTextAlignment(.leading)
                }
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
        .toolbar {
            Menu {
                Button {
                    job.applied.toggle()
                    job.appliedDate = job.applied ? .now : nil
                    dataController.save()
                } label: {
                    Label(job.applied ? "Mark as Not Applied" : "Mark as Applied", systemImage: "paperplane.circle")
                }
                 
            } label: {
                Label("Actions", systemImage: "ellipsis.circle")
            }
        }
    }
}

#Preview {
    JobView(job: .example)
        .environmentObject(DataController.preview)
}
