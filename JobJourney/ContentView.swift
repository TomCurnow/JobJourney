//
//  ContentView.swift
//  JobJourney
//
//  Created by Tom Curnow on 21/05/2024.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dataController: DataController
    
    var body: some View {
        List (selection: $dataController.selectedJob) {
            ForEach(dataController.jobsForSelectedFilter()) { job in
                JobRow(job: job)
            }
            .onDelete(perform: delete)
        }
        .navigationTitle("Jobs")
        .searchable(
            text: $dataController.filterText,
            tokens: $dataController.filterTokens,
            suggestedTokens: .constant(dataController.suggestedFilterTokens),
            prompt: "Search, or type # to add tags") { tag in
                Text(tag.tagName)
        }
            .toolbar {
                Menu {
                    Button(dataController.filterEnabled ? "Turn Filter Off" : "Turn Filter On") {
                        dataController.filterEnabled.toggle()
                    }
                    
                    Divider()
                    
                    Menu("Sort By") {
                        Picker("Sort By", selection: $dataController.sortType) {
                            Text("Date Created").tag(SortType.dateCreated)
                            Text("Date Applied").tag(SortType.dateApplied)
                        }
                        
                        Divider()
                        
                        Picker("Sort Order", selection: $dataController.sortNewestFirst) {
                            Text("Newest to Oldest").tag(true)
                            Text("Oldest to Newest").tag(false)
                        }
                    }
                    
                    Picker("Status", selection: $dataController.filterStatus) {
                        Text("All").tag(Status.all)
                        Text("Applied").tag(Status.applied)
                        Text("Not Applied").tag(Status.notApplied)
                    }
                    .disabled(dataController.filterEnabled == false)
                } label: {
                    Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                        .symbolVariant(dataController.filterEnabled ? .fill : .none)
                }
            }
    }
    
    func delete(_ offsets: IndexSet) {
        let jobs = dataController.jobsForSelectedFilter()
        
        for offset in offsets {
            let item = jobs[offset]
            dataController.delete(item)
        }
    }
}

#Preview {
    ContentView()
}
