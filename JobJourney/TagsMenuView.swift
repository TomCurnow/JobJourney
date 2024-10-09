//
//  TagsMenuView.swift
//  JobJourney
//
//  Created by Tom Curnow on 09/10/2024.
//

import SwiftUI

struct TagsMenuView: View {
    @EnvironmentObject var dataController: DataController
    @ObservedObject var job: Job

    var body: some View {
        Menu {
            ForEach(job.jobTags) { tag in
                Button {
                    job.removeFromTags(tag) // Method added by xcode
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
}

#Preview {
    TagsMenuView(job: Job.example)
        .environmentObject(DataController(inMemory: true))
}
