//
//  JobViewToolbar.swift
//  JobJourney
//
//  Created by Tom Curnow on 09/10/2024.
//

import SwiftUI

struct JobViewToolbar: View {
    @EnvironmentObject var dataController: DataController
    @ObservedObject var job: Job
    
    var body: some View {
        Menu {
            Button {
                job.applied.toggle()
                job.appliedDate = job.applied ? .now : nil
                dataController.save()
            } label: {
                Label(job.applied ? "Mark as Not Applied" : "Mark as Applied", systemImage: "paperplane.circle")
            }
            
            Divider()
            
            Section("Tags") {
                TagsMenuView(job: job)
            }
             
        } label: {
            Label("Actions", systemImage: "ellipsis.circle")
        }
    }
}

#Preview {
    JobViewToolbar(job: Job.example)
        .environmentObject(DataController(inMemory: true))
}
